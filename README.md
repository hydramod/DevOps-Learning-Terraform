# Terraform AWS Project

Managing AWS resources with a small, module-first project structure. The repo demonstrates provider setup, variables, modules, planning and applying changes, and importing existing infrastructure into state.

## Contents

- [Quick start](#quick-start)
- [Repository layout](#repository-layout)
- [Configuration and variables](#configuration-and-variables)
- [Common workflows](#common-workflows)
- [Troubleshooting](#troubleshooting)

## Quick start

### Prereqs

- Terraform v1.5+
- AWS CLI configured (`aws configure`) or environment credentials (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN` if using SSO)
- An AWS region you'll deploy to (this repo uses `us-east-1` in `provider.tf`)

### Clone and initialize

```bash
git clone <this-repo>
cd DevOps-Learning-Terraform
terraform init -reconfigure
```

### Set variables

Edit `terraform.tfvars` (example already provided):

```hcl
instance_type = "t3.micro"
```

If your module expects more inputs (e.g., `ami`, `subnet_id`), add them here:

```hcl
ami        = "ami-xxxxxxxx"
subnet_id  = "subnet-xxxxxxxx"
```

### Plan and apply

```bash
terraform validate
terraform plan
terraform apply
```

### Destroy when done

```bash
terraform destroy
```

## Repository layout

```
DevOps-Learning-Terraform/
├─ modules/
│  └─ ec2/
│     ├─ main.tf               # EC2 instance resources
│     └─ variables.tf          # module input variables
├─ main.tf                      # root module: calls modules/ec2
├─ provider.tf                  # provider and required_providers
├─ variables.tf                 # root variables (if used) and outputs
├─ .gitignore                   # ignore Terraform artifacts
└─ README.md
```

The root `main.tf` instantiates the `modules/ec2` module.

Module code in `modules/ec2` holds the actual `aws_instance` resources such as `terra-ec2-test` and (optionally) an import resource.

## Configuration and variables

- **Provider**: `provider "aws" { region = "us-east-1" }` in `provider.tf`. If you change regions, make sure your AMI and subnet belong to the same region.

- **Variables**:
  - Root variables are set in `variables.tf` and values go in `terraform.tfvars`.
  - Module inputs are declared in `modules/ec2/variables.tf`.

- **Outputs**:
  - You can expose IDs or attributes from the module using outputs in the module and then wire them to root outputs if needed.

## Common workflows

### 1. Create a new instance via the module

```bash
terraform plan
terraform apply
```

### 2. Import an existing instance into the module

If the module defines a resource named `aws_instance.import`, import with the module path:

```bash
terraform import module.ec2.aws_instance.import <instance_id>
```

**Tip**: if the configuration for `aws_instance.import` does not match the live instance, plan will propose changes. Either update the config to match reality or add a temporary lifecycle rule while reconciling:

```hcl
lifecycle {
  ignore_changes = [ami, subnet_id, vpc_security_group_ids, user_data, tags]
}
```

### 3. Use import blocks (Terraform 1.5+)

Instead of a separate CLI import, add at root:

```hcl
import {
  to = module.ec2.aws_instance.import
  id = "<instance_id>"
}
```

Then run `terraform apply`. Terraform will import and then plan changes.

### 4. Refresh state against real infrastructure

Terraform v1.2+:

```bash
terraform apply -refresh-only
```

## Troubleshooting

### No subnets found for the default VPC

Specify `subnet_id` explicitly, or recreate default subnets in the target region. Ensure AMI, subnet, and provider are all in the same region.

### S3 backend 301 region mismatch

If you later switch to an S3 remote backend, the backend's region must match the bucket's actual region. Otherwise you'll see a redirect error. You can either point to the correct region or create a new bucket in your chosen region and migrate state.

### Import error: resource address does not exist

If the resource lives in a module, include the module path in the address, for example:

```bash
module.ec2.aws_instance.import
```