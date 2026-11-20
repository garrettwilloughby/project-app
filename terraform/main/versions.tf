terraform {
  # 1.10+ for S3-native state locking (use_lockfile), so no DynamoDB lock table.
  required_version = ">= 1.10"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 6.0" }
  }

  # Partial config: the rest comes from backend-<env>.hcl, written by terraform/bootstrap.
  #   terraform init -backend-config=backend-dev.hcl
  backend "s3" {}
}

provider "aws" {
  region = var.region
  default_tags {
    tags = { Project = "bonsai", Environment = var.environment, ManagedBy = "terraform" }
  }
}
