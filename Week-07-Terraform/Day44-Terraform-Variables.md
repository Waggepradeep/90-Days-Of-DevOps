# Day 44 — Terraform: Variables & Outputs

![Day](https://img.shields.io/badge/Day-44-yellow?style=flat-square)
![Topic](https://img.shields.io/badge/Topic-Terraform%20Variables%20%2B%20Outputs-orange?style=flat-square)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen?style=flat-square)

> 📅 Date: May 23, 2026
> ⏱️ Time Spent: 3+ hrs
> 🎯 Goal: Make Terraform configs reusable using variables, locals, dynamic blocks, count, outputs, tfvars files, and sensitive variable handling

---

## 📌 What I Learned Today

### 1. What Problem Do Variables Solve?

**Day 43 — hardcoded:**
```hcl
instance_type = "t3.micro"     # hardcoded 😰
region        = "ap-south-1"   # hardcoded 😰
bucket        = "devops-pradeep-day43"  # hardcoded 😰
```

**Day 44 — variables:**
```hcl
instance_type = var.instance_type   # flexible ✅
region        = var.aws_region      # flexible ✅
```

```bash
terraform apply -var="environment=staging"  # override at runtime!
```

> 💡 Variables = parameters for your Terraform config.
> Same code → multiple environments → different values!

---

### 2. Variable Types

| Type | Example |
|------|---------|
| `string` | `"t3.micro"` |
| `number` | `3` |
| `bool` | `true` |
| `list(number)` | `[22, 80, 443]` |
| `map(string)` | `{Project = "devops", Owner = "Pradeep"}` |

---

### 3. Variable Priority (Highest → Lowest)

```
1. -var flag at CLI              → highest
2. terraform.tfvars file         → common approach
3. *.auto.tfvars file            → auto-loaded
4. Default in variable block     → lowest
```

---

### 4. Key Terraform Features Used Today

| Feature | Purpose |
|---------|---------|
| `locals` | Computed/reusable values derived from other values |
| `merge()` | Combine two maps into one |
| `dynamic block` | Generate repeated config blocks automatically |
| `count` | Create multiple identical resources |
| `sensitive = true` | Hide secret values from plan/apply output |
| Ternary operator | `condition ? true_val : false_val` |

---

### 5. Locals vs Variables

```
variable = input from outside (user provides)
locals   = computed internally (derived from other values)

locals {
  bucket_name = "devops-${var.environment}-pradeep"
  # computed from variable — can't be overridden from CLI
}
```

---

## 🛠️ Steps I Performed

### Setup

```bash
mkdir ~/day44-terraform
cd ~/day44-terraform
```

---

### Part A — variables.tf

```hcl
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "instance_count" {
  description = "Number of EC2 instances"
  type        = number
  default     = 1
}

variable "enable_versioning" {
  description = "Enable S3 bucket versioning"
  type        = bool
  default     = true
}

variable "allowed_ports" {
  description = "Ports to allow in security group"
  type        = list(number)
  default     = [22, 80, 443]
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    Project = "90-days-devops"
    Owner   = "Pradeep"
    Day     = "44"
  }
}
```

---

### Part B — main.tf

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.5.0"
}

provider "aws" {
  region = var.aws_region   # uses variable, not hardcoded!
}

locals {
  common_tags = merge(var.common_tags, {
    Environment = var.environment
    ManagedBy   = "Terraform"
  })
  bucket_name = "devops-terraform-${var.environment}-pradeep-day44"
}

# S3 Bucket
resource "aws_s3_bucket" "devops_bucket" {
  bucket = local.bucket_name   # dynamic name from locals
  tags   = local.common_tags
}

# S3 Versioning — conditional with ternary
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.devops_bucket.id
  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}

# Security Group — dynamic block generates ingress rules
resource "aws_security_group" "devops_sg" {
  name        = "devops-sg-${var.environment}"
  description = "Security group for ${var.environment} environment"

  dynamic "ingress" {
    for_each = var.allowed_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}

# EC2 — count creates multiple instances
resource "aws_instance" "devops_server" {
  ami                    = "ami-0f58b397bc5c1f2e8"
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.devops_sg.id]
  count                  = var.instance_count

  tags = merge(local.common_tags, {
    Name = "devops-server-${var.environment}-${count.index + 1}"
  })
}
```

---

### Part C — outputs.tf

```hcl
output "bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.devops_bucket.bucket
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.devops_bucket.arn
}

output "instance_ids" {
  description = "IDs of EC2 instances"
  value       = aws_instance.devops_server[*].id
}

output "instance_public_ips" {
  description = "Public IPs of EC2 instances"
  value       = aws_instance.devops_server[*].public_ip
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.devops_sg.id
}

output "environment" {
  description = "Current environment"
  value       = var.environment
}
```

---

### Part D — terraform.tfvars

```hcl
aws_region        = "ap-south-1"
environment       = "dev"
instance_type     = "t3.micro"
instance_count    = 1
enable_versioning = true
allowed_ports     = [22, 80]
common_tags = {
  Project = "90-days-devops"
  Owner   = "Pradeep"
  Day     = "44"
}
```

---

### Part E — Deployed & Tested

```bash
terraform init
terraform validate   # ✅ Success!
terraform fmt
terraform plan
terraform apply      # Type: yes ✅

# View outputs
terraform output
terraform output bucket_name
terraform output instance_public_ips

# State commands
terraform state list
terraform state show aws_instance.devops_server[0]
```

---

### Part F — Variable Overrides

```bash
# Single override
terraform plan -var="environment=staging"

# Multiple overrides
terraform plan \
  -var="environment=staging" \
  -var="instance_type=t3.small" \
  -var="instance_count=2"
```

**`staging.tfvars`:**
```hcl
environment    = "staging"
instance_type  = "t3.micro"
instance_count = 2
allowed_ports  = [22, 80, 443]
```

```bash
terraform plan -var-file="staging.tfvars"
```

---

### Part G — Sensitive Variables

**`sensitive.tf`:**
```hcl
variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

output "db_password_length" {
  value     = length(var.db_password)
  sensitive = true
}
```

```bash
terraform plan -var="db_password=mysecretpassword"
# Output shows: (sensitive value) — never shows actual password ✅
```

---

### Part H — Infrastructure Change Types

Observed two types of changes:

**In-place update (`~`):**
```
~ update in-place   ← changing EC2 tags
```

**Destroy + Recreate (`-/+`):**
```
-/+ destroy and then create replacement   ← changing bucket name
```

> 💡 Some changes (like name) force resource recreation.
> Terraform tells you BEFORE applying — always read the plan!

---

### Cleanup

```bash
terraform destroy -var="db_password=mysecretpassword"
# Type: yes ✅

# Verify
terraform state list    # empty ✅
aws s3 ls               # bucket gone ✅
aws ec2 describe-instances --region ap-south-1 \
  --query "Reservations[*].Instances[*].[InstanceId,State.Name]" \
  --output table         # terminated ✅
```

---

## 💡 Key Concepts I Understood Today

- Variables = parameters — make Terraform reusable across environments
- `locals` = computed values derived from other values — can't be overridden from CLI
- `merge()` = combine two maps — perfect for building common + specific tags
- `dynamic block` = auto-generates repeated config — used for security group ports
- `count` = creates multiple identical resources — indexed as `resource[0]`, `resource[1]`
- `count.index + 1` = human-friendly numbering (1-based instead of 0-based)
- Ternary: `condition ? true_val : false_val` — works in Terraform like any language
- `terraform.tfvars` = auto-loaded variable file — no need to specify with `-var-file`
- `-var-file="staging.tfvars"` = load environment-specific values
- `sensitive = true` = hides value in plan/apply output — must also mark output as sensitive
- In-place update (`~`) vs Destroy+Recreate (`-/+`) — know the difference before applying!
- `terraform output <name>` = retrieve specific output value — useful in CI/CD scripts

---

## ❌ Mistakes I Made (and Learned From)

| Mistake | Error | What I Learned |
|---------|-------|----------------|
| Output referenced sensitive variable without `sensitive = true` | `Output refers to sensitive values` | Any output using a sensitive variable must also be marked `sensitive = true` |

---

## 📁 Project Structure

```
day44-terraform/
├── main.tf           ← providers + resources
├── variables.tf      ← variable definitions
├── outputs.tf        ← output values
├── sensitive.tf      ← sensitive variable demo
├── terraform.tfvars  ← default variable values
├── staging.tfvars    ← staging environment values
└── .gitignore
```

---

## 📚 Resources I Used Today

- [Terraform Variables Docs](https://developer.hashicorp.com/terraform/language/values/variables)
- [Terraform Outputs Docs](https://developer.hashicorp.com/terraform/language/values/outputs)
- [Terraform Locals Docs](https://developer.hashicorp.com/terraform/language/values/locals)

---

## ✅ Tomorrow → Day 45: Terraform — State & Remote Backend (S3)
