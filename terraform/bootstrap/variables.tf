variable "alert_email" {
  description = "Where budget alerts go. Set in terraform.tfvars (gitignored)."
  type        = string
}

variable "monthly_budget_usd" {
  type    = number
  default = 15
}

variable "environments" {
  description = "Environments of terraform/main to write a backend-<env>.hcl for. Add \"prod\" when it's time."
  type        = list(string)
  default     = ["dev"]
}
