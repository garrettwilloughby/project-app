# Account-wide, run-once setup: the S3 bucket that holds Terraform state for
# every environment of terraform/main, plus the account's budget alerts.
# This folder keeps its own state locally (terraform.tfstate, gitignored) because
# it can't store state in a bucket that doesn't exist yet. If that file is ever
# lost, `terraform import` the bucket back in; the bucket itself is protected below.

terraform {
  required_version = ">= 1.10"
  required_providers {
    aws   = { source = "hashicorp/aws", version = "~> 6.0" }
    local = { source = "hashicorp/local", version = "~> 2.5" }
  }
}

provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = { Project = "bonsai", ManagedBy = "terraform" }
  }
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "tfstate" {
  # Bucket names are global across all of AWS; the account ID makes this one unique.
  # One bucket for the account: each environment's state is a separate file in it.
  bucket = "bonsai-tfstate-${data.aws_caller_identity.current.account_id}"

  lifecycle {
    prevent_destroy = true
  }
}

# Versioning lets you recover an older state file if one gets corrupted.
resource "aws_s3_bucket_versioning" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  rule {
    id     = "expire-old-state-versions"
    status = "Enabled"
    filter {}
    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256" # SSE-S3: free, unlike a customer-managed KMS key
    }
  }
}

resource "aws_s3_bucket_public_access_block" "tfstate" {
  bucket                  = aws_s3_bucket.tfstate.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# State can contain secrets, so refuse any request not made over HTTPS.
resource "aws_s3_bucket_policy" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "DenyInsecureTransport"
      Effect    = "Deny"
      Principal = "*"
      Action    = "s3:*"
      Resource  = [aws_s3_bucket.tfstate.arn, "${aws_s3_bucket.tfstate.arn}/*"]
      Condition = { Bool = { "aws:SecureTransport" = "false" } }
    }]
  })
  depends_on = [aws_s3_bucket_public_access_block.tfstate]
}

# Writes the backend settings for each environment of terraform/main
# (backend-dev.hcl, ...), so the bucket name (which contains your account ID)
# never has to be committed.
resource "local_file" "main_backend" {
  for_each        = toset(var.environments)
  filename        = "${path.module}/../main/backend-${each.key}.hcl"
  file_permission = "0644"
  content         = <<-EOT
    bucket       = "${aws_s3_bucket.tfstate.id}"
    key          = "main/${each.key}/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  EOT
}

output "state_bucket" {
  value = aws_s3_bucket.tfstate.id
}
