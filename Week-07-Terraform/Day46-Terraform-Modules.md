# Day 46 — Terraform: Modules & Reusable Infrastructure

![Day](https://img.shields.io/badge/Day-46-yellow?style=flat-square)
![Topic](https://img.shields.io/badge/Topic-Terraform%20Modules-orange?style=flat-square)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen?style=flat-square)

> 📅 Date: May 23, 2026
> ⏱️ Time Spent: 3+ hrs
> 🎯 Goal: Build reusable Terraform modules for EC2, Security Group, and S3 — chain module outputs as inputs, and explore the Terraform Registry

---

## 📌 What I Learned Today

### 1. What Problem Do Modules Solve?

**Without modules:**
```hcl
# Every project copy-pastes the same code 😰
resource "aws_security_group" "sg" { ... }
resource "aws_instance" "server" { ... }
```

**With modules:**
```hcl
module "web_server" {
  source      = "./modules/ec2"
  environment = "dev"
}
# Write once → reuse everywhere ✅
```

> 💡 Modules = functions for Terraform.
> Write once, test once, trust everywhere!
> Every professional Terraform codebase uses modules!

---

### 2. Module Structure

```
modules/
├── ec2/
│   ├── main.tf       ← resources
│   ├── variables.tf  ← inputs
│   └── outputs.tf    ← outputs
├── security-group/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
└── s3/
    ├── main.tf
    ├── variables.tf
    └── outputs.tf
```

---

### 3. Module Concepts

| Concept | Meaning |
|---------|---------|
| Root module | Directory where you run `terraform` |
| Child module | Module called from root |
| `source` | Path or URL of the module |
| Module inputs | Variables passed to the module |
| Module outputs | Values exposed by the module |

---

### 4. Module Sources

```hcl
source = "./modules/ec2"                        # local
source = "terraform-aws-modules/vpc/aws"        # Terraform Registry
source = "github.com/org/repo//modules/ec2"     # GitHub
```

---

### 5. Chaining Modules

```
Security Group Module
        ↓ outputs security_group_id
EC2 Module ← receives security_group_ids as input
```

This is how real infrastructure is composed — modules talking to each other!

---

## 🛠️ Steps I Performed

### Setup

```bash
mkdir ~/day46-terraform
cd ~/day46-terraform
mkdir -p modules/ec2 modules/security-group modules/s3
```

---

### Part A — EC2 Module

**`modules/ec2/variables.tf`:**
```hcl
variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "ami_id" {
  type    = string
  default = "ami-0f58b397bc5c1f2e8"
}

variable "environment" {
  type = string
}

variable "security_group_ids" {
  type    = list(string)
  default = []
}

variable "tags" {
  type    = map(string)
  default = {}
}
```

**`modules/ec2/main.tf`:**
```hcl
resource "aws_instance" "this" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  vpc_security_group_ids = var.security_group_ids

  tags = merge({
    Name        = "ec2-${var.environment}"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }, var.tags)
}
```

**`modules/ec2/outputs.tf`:**
```hcl
output "instance_id" {
  value = aws_instance.this.id
}

output "public_ip" {
  value = aws_instance.this.public_ip
}

output "private_ip" {
  value = aws_instance.this.private_ip
}
```

---

### Part B — Security Group Module

**`modules/security-group/variables.tf`:**
```hcl
variable "name" {
  type = string
}

variable "environment" {
  type = string
}

variable "allowed_ports" {
  type    = list(number)
  default = [22, 80, 443]
}
```

**`modules/security-group/main.tf`:**
```hcl
resource "aws_security_group" "this" {
  name        = "${var.name}-${var.environment}"
  description = "Security group for ${var.environment}"

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

  tags = {
    Name        = "${var.name}-${var.environment}"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
```

**`modules/security-group/outputs.tf`:**
```hcl
output "security_group_id" {
  value = aws_security_group.this.id
}

output "security_group_name" {
  value = aws_security_group.this.name
}
```

---

### Part C — S3 Module

**`modules/s3/variables.tf`:**
```hcl
variable "bucket_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "enable_versioning" {
  type    = bool
  default = true
}
```

**`modules/s3/main.tf`:**
```hcl
resource "aws_s3_bucket" "this" {
  bucket = "${var.bucket_name}-${var.environment}"

  tags = {
    Name        = var.bucket_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}
```

**`modules/s3/outputs.tf`:**
```hcl
output "bucket_name" {
  value = aws_s3_bucket.this.bucket
}

output "bucket_arn" {
  value = aws_s3_bucket.this.arn
}
```

---

### Part D — Root Module

**`main.tf`:**
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
  region = "ap-south-1"
}

# Security Group module
module "web_sg" {
  source        = "./modules/security-group"
  name          = "web-sg"
  environment   = var.environment
  allowed_ports = [22, 80]
}

# EC2 module — uses SG module output as input!
module "web_server" {
  source             = "./modules/ec2"
  instance_type      = var.instance_type
  environment        = var.environment
  security_group_ids = [module.web_sg.security_group_id]
  tags = {
    Day     = "46"
    Project = "90-days-devops"
  }
}

# S3 module
module "app_storage" {
  source            = "./modules/s3"
  bucket_name       = "devops-day46-pradeep"
  environment       = var.environment
  enable_versioning = true
}
```

**`variables.tf`:**
```hcl
variable "environment" {
  type    = string
  default = "dev"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}
```

**`outputs.tf`:**
```hcl
output "web_server_ip" {
  value = module.web_server.public_ip
}

output "web_sg_id" {
  value = module.web_sg.security_group_id
}

output "storage_bucket" {
  value = module.app_storage.bucket_name
}
```

---

### Part E — Deployed

```bash
terraform init      # downloads providers + initializes modules
terraform validate  # ✅ Success! The configuration is valid.
terraform plan      # preview: 4 resources to add
terraform apply     # ✅ All resources created via modules!
terraform output    # shows web_server_ip, web_sg_id, storage_bucket
```

---

### Part F — Terraform Registry Module

**`registry-example.tf`:**
```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "devops-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["ap-south-1a", "ap-south-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = false

  tags = {
    Environment = "dev"
    Day         = "46"
  }
}
```

```bash
terraform init   # downloads VPC module from registry into .terraform/modules/
terraform plan
# Plan: 17 to add! (VPC + subnets + IGW + route tables + NACLs)
# Did NOT apply — just explored the module
```

---

### Cleanup

```bash
rm registry-example.tf
terraform destroy   # ✅ EC2 + SG + S3 destroyed

# Verify nothing remains
terraform plan -destroy
# No changes. No objects need to be destroyed. ✅
```

---

## 💡 Key Concepts I Understood Today

- Module = reusable block of Terraform code — directory with main.tf + variables.tf + outputs.tf
- Root module = where you run terraform, child module = what you call
- `source = "./modules/ec2"` = local module, `source = "hashicorp/vpc/aws"` = registry module
- Module inputs defined in `variables.tf` — passed from calling module
- Module outputs defined in `outputs.tf` — accessible as `module.name.output_name`
- Modules can chain: SG module output → EC2 module input
- `terraform init` downloads registry modules into `.terraform/modules/`
- Registry modules (like VPC) can create 17+ resources with minimal config
- Bucket name pattern: `"${var.bucket_name}-${var.environment}"` = env-specific names
- `merge()` in module = combine default tags with custom tags passed from root
- `version = "~> 5.0"` on registry module = accept 5.x but not 6.x

---

## 📁 Final Project Structure

```
day46-terraform/
├── main.tf           ← calls all modules
├── variables.tf      ← root variables
├── outputs.tf        ← root outputs (from modules)
└── modules/
    ├── ec2/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── security-group/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── s3/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

---

## 📚 Resources I Used Today

- [Terraform Modules Docs](https://developer.hashicorp.com/terraform/language/modules)
- [Terraform Registry](https://registry.terraform.io/)
- [AWS VPC Module](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws)

---

## ✅ Tomorrow → Day 47: Terraform — Workspaces & Environments
