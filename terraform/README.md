# terraform

| Folder       | What                                                                                                               | State                                                   |
| ------------ | ------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------- |
| `bootstrap/` | Account-wide, run once: the S3 bucket that stores state for `main/`, and the account's budget alerts               | Local file (gitignored)                                 |
| `main/`      | Everything per environment: VPC, RDS, Lambda, API Gateway, Cognito, S3 + CloudFront. Names end in `-dev` / `-prod` | The bootstrap bucket, at `main/<env>/terraform.tfstate` |

## First-time setup

```sh
cd terraform/bootstrap
cp example.tfvars terraform.tfvars   # set alert_email
terraform init
terraform plan       # the bucket + its settings, the budget, and main/backend-dev.hcl
terraform apply

cd ../main
terraform init -backend-config=backend-dev.hcl
terraform plan  -var-file=dev.tfvars
terraform apply -var-file=dev.tfvars
```

## Switching environments

Each environment has its own state file, so switch both the backend and the variables together:

```sh
terraform init -reconfigure -backend-config=backend-prod.hcl
terraform plan -var-file=prod.tfvars
```

Mixing them up (prod variables against dev state) would make Terraform try to rename everything, so always read the plan. To add prod, put `"prod"` in `environments` in `bootstrap/` and apply it to get `backend-prod.hcl`, then create `main/prod.tfvars`.
