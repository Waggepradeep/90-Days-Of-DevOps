# Day 45 — Terraform: State & Remote Backend (S3)

![Day](https://img.shields.io/badge/Day-45-yellow?style=flat-square)
![Topic](https://img.shields.io/badge/Topic-Terraform%20State%20%2B%20Remote%20Backend-orange?style=flat-square)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen?style=flat-square)

> 📅 Date: May 23, 2026
> ⏱️ Time Spent: 3+ hrs
> 🎯 Goal: Configure S3 remote backend for Terraform state, use DynamoDB for state locking, and master advanced state management commands

---

## 📌 What I Learned Today

### 1. What Problem Does Remote State Solve?

**Local state (Days 43–44):**
```
terraform.tfstate → only on YOUR laptop
Teammate applies → their state ≠ yours → conflict 💥
Laptop dies → state gone → Terraform lost everything 😱
Two people apply at same time → corrupted state 💀
```

**Remote backend (S3 + DynamoDB):**
```
terraform.tfstate → S3 (shared, versioned, backed up) ✅
DynamoDB → state locking (one apply at a time) ✅
Team of 10 → all share same state, no conflicts ✅
```

> 💡 Remote backend = foundation of team Terraform usage.
> No real DevOps team uses local state in production!

---

### 2. Remote Backend Architecture

```
Developer A                   Developer B
terraform apply               terraform apply
       ↓                             ↓
DynamoDB Lock ←─── BLOCKED until A finishes ───→ DynamoDB Lock
       ↓
S3 Bucket (terraform.tfstate)
       ↓
Real AWS Infrastructure
```

---

### 3. Backend Configuration

```hcl
backend "s3" {
  bucket         = "my-state-bucket"   # S3 bucket storing state
  key            = "dev/terraform.tfstate"  # path inside bucket
  region         = "ap-south-1"
  dynamodb_table = "terraform-locks"   # locking table
  encrypt        = true                # encrypt state at rest
}
```

---

### 4. State Commands

| Command | Purpose |
|---------|---------|
| `terraform state list` | List all tracked resources |
| `terraform state show` | Show resource details |
| `terraform state mv` | Rename resource in state |
| `terraform state rm` | Remove from state (stays in AWS!) |
| `terraform state pull` | Download remote state locally |
| `terraform refresh` | Sync state with real infrastructure |
| `terraform import` | Import existing AWS resource into state |

---

### 5. Chicken-and-Egg Problem

> ⚠️ You can't use S3 as a backend to store state for the S3 bucket itself!
> Solution: Create backend resources (S3 + DynamoDB) in a SEPARATE Terraform config first,
> then configure the main project to use them as backend.

---

## 🛠️ Steps I Performed

### Setup

```bash
mkdir ~/day45-terraform/backend-setup
mkdir ~/day45-terraform
```

---

### Part A — Created Backend Infrastructure

**`~/day45-terraform/backend-setup/main.tf`:**

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

# S3 bucket for state storage
resource "aws_s3_bucket" "terraform_state" {
  bucket = "devops-terraform-state-pradeep-day45"
  tags = {
    Name    = "terraform-state-bucket"
    Purpose = "Terraform Remote State"
  }
}

# Enable versioning — keeps history of state files for recovery
resource "aws_s3_bucket_versioning" "state_versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Block all public access on state bucket
resource "aws_s3_bucket_public_access_block" "state_public_access" {
  bucket                  = aws_s3_bucket.terraform_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# DynamoDB table for state locking
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-state-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name    = "terraform-state-locks"
    Purpose = "Terraform State Locking"
  }
}

output "state_bucket_name" {
  value = aws_s3_bucket.terraform_state.bucket
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.terraform_locks.name
}
```

```bash
cd ~/day45-terraform/backend-setup
terraform init
terraform apply   # ✅ S3 + DynamoDB created
```

---

### Part B — Main Project with Remote Backend

**`~/day45-terraform/main.tf`:**

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "devops-terraform-state-pradeep-day45"
    key            = "dev/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "devops_server" {
  ami           = "ami-0f58b397bc5c1f2e8"
  instance_type = "t3.micro"
  tags = {
    Name      = "devops-remote-state-server"
    Day       = "45"
    ManagedBy = "Terraform"
  }
}

resource "aws_s3_bucket" "app_bucket" {
  bucket = "devops-app-bucket-pradeep-day45"
  tags = {
    Name = "app-bucket"
    Day  = "45"
  }
}
```

```bash
cd ~/day45-terraform
terraform init
# ✅ Successfully configured the backend "s3"!
# State now stored remotely in S3!

terraform plan
terraform apply   # ✅ Resources created, state in S3
```

---

### Part C — Verified Remote State

```bash
# Pull state from S3
terraform state pull

# List tracked resources
terraform state list
# aws_instance.devops_server
# aws_s3_bucket.app_bucket

# Verify state file in S3
aws s3 ls s3://devops-terraform-state-pradeep-day45/dev/
# terraform.tfstate ✅

# Pretty print raw state JSON
terraform state pull | python3 -m json.tool
```

---

### Part D — State Commands Deep Dive

```bash
# Show resource details
terraform state show aws_instance.devops_server

# Rename resource in state
terraform state mv \
  aws_instance.devops_server \
  aws_instance.devops_web_server
# ✅ Resource renamed in state — EC2 NOT recreated!

# Remove from state (stays in AWS!)
terraform state rm aws_s3_bucket.app_bucket
# ✅ Removed from tracking — bucket still exists in AWS

# Import back into state
terraform import aws_s3_bucket.app_bucket devops-app-bucket-pradeep-day45
# ✅ Resource reconnected to Terraform state

# Sync state with real infrastructure
terraform refresh
```

---

### Part E — State Locking Test

**Terminal 1:**
```bash
terraform apply
```

**Terminal 2 (simultaneously):**
```bash
terraform apply
# Error: Error acquiring the state lock
# Lock Info: ID=xxx, Operation=OperationTypeApply
# ✅ DynamoDB locking worked — state corruption prevented!
```

---

### Part F — State Inspection

```bash
terraform show         # human-readable state
terraform output       # display outputs
terraform state pull | python3 -m json.tool  # raw JSON
```

---

### Cleanup

```bash
# 1. Destroy main project resources
cd ~/day45-terraform
terraform destroy   # ✅ EC2 + app bucket destroyed

# 2. Empty versioned S3 bucket (simple delete not enough!)
aws s3api delete-objects  # delete object versions + delete markers

# 3. Destroy backend infrastructure
cd ~/day45-terraform/backend-setup
terraform destroy   # ✅ State bucket + DynamoDB destroyed
```

---

## 💡 Key Concepts I Understood Today

- Remote backend = state stored in S3, shared across team, versioned, backed up
- DynamoDB locking = prevents two people applying simultaneously → no state corruption
- `encrypt = true` = state file encrypted at rest in S3 — always use this!
- `key` in backend = path inside S3 bucket (use `env/terraform.tfstate` pattern)
- `terraform state mv` = renames resource in state only — AWS resource NOT recreated
- `terraform state rm` = removes from Terraform tracking only — resource stays in AWS!
- `terraform import` = reconnect existing AWS resource to Terraform state
- `terraform refresh` = sync state with actual infrastructure (detect drift)
- After `state mv` → must update `main.tf` resource name to match — or Terraform tries to recreate!
- Versioned S3 buckets = can't delete until ALL versions + delete markers are removed
- Chicken-and-egg: create backend resources in separate Terraform config first!
- `terraform state pull | python3 -m json.tool` = inspect raw state JSON — useful for debugging

---

## ❌ Mistakes I Made (and Learned From)

| Mistake | Error | What I Learned |
|---------|-------|----------------|
| Used `terraform state mv` but didn't update `main.tf` | Terraform planned to destroy old + create new resource | After renaming in state, MUST update resource name in `.tf` file to match |
| Tried `terraform destroy` on versioned S3 bucket without emptying it | Bucket deletion failed | Versioned S3 buckets keep delete markers — must delete all versions + markers before bucket can be destroyed |

---

## 🏗️ Remote Backend Architecture Summary

```
Team Developer
      ↓
terraform apply
      ↓
DynamoDB (lock acquired)
      ↓
S3 (read/write terraform.tfstate)
      ↓
AWS Infrastructure created/updated
      ↓
S3 (state updated)
      ↓
DynamoDB (lock released)
```

---

## 📚 Resources I Used Today

- [Terraform S3 Backend Docs](https://developer.hashicorp.com/terraform/language/settings/backends/s3)
- [Terraform State Docs](https://developer.hashicorp.com/terraform/language/state)

---

## ✅ Tomorrow → Day 46: Terraform — Modules & Reusable Infrastructure
