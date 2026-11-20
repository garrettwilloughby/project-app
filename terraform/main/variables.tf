variable "environment" {
  description = "Which environment this is. Set by dev.tfvars / prod.tfvars."
  type        = string

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "environment must be \"dev\" or \"prod\"."
  }
}

variable "region" {
  type    = string
  default = "us-east-1"
}
