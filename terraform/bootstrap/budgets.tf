# A budget tracks spending for the whole AWS account, not one environment,
# so it lives here instead of in terraform/main (where dev and prod would each
# create one, both counting the same spending).
resource "aws_budgets_budget" "monthly" {
  name         = "bonsai-monthly"
  budget_type  = "COST"
  limit_amount = tostring(var.monthly_budget_usd)
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  # Count usage before credits. With the default (credits included), the $100
  # of Free Tier credits would hide all spending and no alert would fire until
  # the credits ran out.
  cost_types {
    include_credit = false
    include_refund = false
  }

  # Early warning: $5 of real usage this month.
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 5
    threshold_type             = "ABSOLUTE_VALUE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.alert_email]
  }

  # On pace to pass the full budget this month.
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = [var.alert_email]
  }

  # Actually passed it.
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.alert_email]
  }
}
