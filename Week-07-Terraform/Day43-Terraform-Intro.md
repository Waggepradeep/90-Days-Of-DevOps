# Day 43 — Terraform: Providers & Resources

![Day](https://img.shields.io/badge/Day-43-yellow?style=flat-square)
![Topic](https://img.shields.io/badge/Topic-Terraform%20Basics%20%2B%20IaC-orange?style=flat-square)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen?style=flat-square)

> 📅 Date: May 23, 2026
> ⏱️ Time Spent: 3+ hrs
> 🎯 Goal: Install Terraform, configure AWS provider, create S3 + EC2 + Security Group using IaC, understand state management, and perform safe infrastructure cleanup

---

## 📌 What I Learned Today

### 1. What Problem Does Terraform Solve?

**Without Terraform:**
```
Create 10 EC2s + VPC + subnets + SGs + RDS → 2 hours clicking console
One mistake → start over 😰
Next week → do it again for staging → repeat everything 😰
6 months later → what did I create? No record 😱
```

**With Terraform:**
```bash
terraform apply   # creates everything in minutes ✅
terraform destroy # removes everything cleanly ✅
terraform apply   # recreates IDENTICAL infrastructure ✅
# Version-controlled, reproducible, shareable
```

> 💡 Terraform = Infrastructure as Code (IaC).
> You write code that DESCRIBES your infrastructure.
> Terraform figures out HOW to create it!

---

### 2. Terraform Workflow

```
Write .tf files
      ↓
terraform init    → download providers/plugins
      ↓
terraform validate → syntax check
      ↓
terraform fmt     → auto-format code
      ↓
terraform plan    → preview changes (safe — nothing created yet)
      ↓
terraform apply   → create actual infrastructure
      ↓
terraform destroy → tear everything down cleanly
```

---

### 3. Core Concepts

#### Provider
Plugin that lets Terraform talk to a platform:
```hcl
provider "aws" {
  region = "ap-south-1"
}
```

#### Resource
Actual infrastructure to create:
```hcl
resource "aws_instance" "devops_server" {
  ami           = "ami-0f58b397bc5c1f2e8"
  instance_type = "t3.micro"
}
```
Format: `resource "PROVIDER_TYPE" "LOCAL_NAME"`

#### State File
Terraform's memory of what it created:
```
terraform.tfstate = tracks all created resources + their IDs
```

#### Declarative vs Imperative

| | AWS CLI (Imperative) | Terraform (Declarative) |
|--|---------------------|------------------------|
| Approach | Tell HOW step by step | Describe WHAT you want |
| State tracking | ❌ No memory | ✅ State file |
| Idempotent | ❌ Run twice = duplicates | ✅ Run twice = no change |
| Multi-cloud | ❌ AWS only | ✅ Any cloud |
| Incremental | ❌ Full recreate | ✅ Only changes diff |

---

### 4. Project File Structure

```
day43-terraform/
├── main.tf        ← providers + resources
├── variables.tf   ← input variables
├── outputs.tf     ← output values
├── .gitignore     ← ignore state files
└── terraform.tfstate  ← auto-generated (never commit!)
```

---

## 🛠️ Steps I Performed

### Part A — Installed Terraform

```bash
wget -O- https://apt.releases.hashicorp.com/gpg | \
  sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
  https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
  sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt update
sudo apt install terraform -y

terraform version
# Terraform v1.15.4 ✅
```

---

### Part B — Project Setup

```bash
mkdir ~/day43-terraform
cd ~/day43-terraform
nano .gitignore
```

**`.gitignore`:**
```
.terraform/
terraform.tfstate
terraform.tfstate.backup
*.tfvars
.terraform.lock.hcl
```

> ⚠️ Never commit `terraform.tfstate` to Git — it contains resource IDs and sensitive data!

---

### Part C — main.tf (Provider + Resources)

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

# S3 Bucket
resource "aws_s3_bucket" "devops_bucket" {
  bucket = "devops-terraform-pradeep-day43"

  tags = {
    Name        = "devops-terraform-bucket"
    Environment = "learning"
    Day         = "43"
    Project     = "90-days-devops"
  }
}

# S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "devops_bucket_versioning" {
  bucket = aws_s3_bucket.devops_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Security Group
resource "aws_security_group" "devops_sg" {
  name        = "devops-terraform-sg"
  description = "Security group created by Terraform"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "devops-terraform-sg"
  }
}

# EC2 Instance
resource "aws_instance" "devops_server" {
  ami                    = "ami-0f58b397bc5c1f2e8"
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.devops_sg.id]

  tags = {
    Name        = "devops-terraform-server"
    Environment = "learning"
    Day         = "43"
  }
}
```

---

### Part D — variables.tf + outputs.tf

**`variables.tf`:**
```hcl
variable "instance_type" {
  default = "t3.micro"
}

variable "instance_name" {
  default = "terraform-demo"
}
```

**`outputs.tf`:**
```hcl
output "instance_public_ip" {
  value = aws_instance.devops_server.public_ip
}

output "bucket_name" {
  value = aws_s3_bucket.devops_bucket.bucket
}
```

---

### Part E — Terraform Workflow

```bash
# Initialize — download AWS provider plugin
terraform init
# ✅ Terraform has been successfully initialized!

# Syntax + config check
terraform validate
# ✅ Success! The configuration is valid.

# Auto-format code
terraform fmt

# Preview — what will be created?
terraform plan
# Plan: 4 to add, 0 to change, 0 to destroy.

# Save plan to file
terraform plan -out=tfplan
terraform show tfplan

# Apply — create infrastructure!
terraform apply
# Type: yes
# ✅ Apply complete! Resources: 4 added.
```

Resources created:
- `aws_s3_bucket.devops_bucket` ✅
- `aws_s3_bucket_versioning.devops_bucket_versioning` ✅
- `aws_security_group.devops_sg` ✅
- `aws_instance.devops_server` ✅

---

### Part F — State Management

```bash
# Show full state
terraform show

# List all tracked resources
terraform state list
# aws_instance.devops_server
# aws_s3_bucket.devops_bucket
# aws_s3_bucket_versioning.devops_bucket_versioning
# aws_security_group.devops_sg

# Show specific resource details
terraform state show aws_instance.devops_server
terraform state show aws_s3_bucket.devops_bucket
```

---

### Part G — Incremental Update

Changed EC2 tag in `main.tf`:
```hcl
Name = "devops-terraform-server-v2"  # was "devops-terraform-server"
```

```bash
terraform plan
# Plan: 0 to add, 1 to change, 0 to destroy. ← only tag changes!

terraform apply
# ✅ Apply complete! Resources: 1 changed.
```

> 💡 Terraform only updates the DIFF — doesn't recreate everything!
> This is the power of declarative IaC!

---

### Part H — Destroy + Verify

```bash
terraform destroy
# Type: yes
# ✅ Destroy complete! Resources: 4 destroyed.

# Verify state is empty
terraform state list
# (no output) ✅

# Verify S3 gone
aws s3 ls
# devops-terraform-pradeep-day43 → gone ✅

# Verify EC2 terminated
aws ec2 describe-instances \
  --region ap-south-1 \
  --query "Reservations[*].Instances[*].[InstanceId,State.Name]" \
  --output table
# Terraform EC2 → terminated ✅
```

---

## 💡 Key Concepts I Understood Today

- Terraform = IaC tool — describe desired infrastructure, Terraform creates it
- `terraform init` = downloads provider plugins — must run first in every project
- `terraform plan` = safe preview — shows exactly what will change, nothing created
- `terraform apply` = creates actual infrastructure — asks for `yes` confirmation
- `terraform destroy` = removes ALL Terraform-managed resources cleanly
- State file (`terraform.tfstate`) = Terraform's memory — never edit manually, never commit to Git
- Declarative = describe WHAT, not HOW — Terraform figures out the steps
- Incremental updates = Terraform only changes what's different, not recreate everything
- `terraform fmt` = auto-formats .tf files — always run before committing
- `terraform validate` = checks syntax + config before applying
- `terraform plan -out=tfplan` = save plan → use in CI/CD pipelines for exact reproducibility
- Resource references: `aws_s3_bucket.devops_bucket.id` → reference one resource from another
- Always add `.terraform/` and `terraform.tfstate` to `.gitignore`!

---

## 📁 Complete `main.tf` Resource Reference

| Resource | Type | What it creates |
|----------|------|----------------|
| `aws_s3_bucket.devops_bucket` | S3 | Storage bucket |
| `aws_s3_bucket_versioning` | S3 | Versioning on bucket |
| `aws_security_group.devops_sg` | EC2 | Firewall rules |
| `aws_instance.devops_server` | EC2 | Virtual machine |

---

## 📚 Resources I Used Today

- [Terraform Docs](https://developer.hashicorp.com/terraform/docs)
- [AWS Provider Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

---

## ✅ Tomorrow → Day 44: Terraform — Variables & Outputs
