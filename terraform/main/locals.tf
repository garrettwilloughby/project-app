locals {
  # Prefix for resource names, e.g. "bonsai-dev-web" or "bonsai-prod-db".
  name = "bonsai-${var.environment}"
}
