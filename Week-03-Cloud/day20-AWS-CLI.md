# Day 20 — AWS CLI: Setup & Basic Commands

![Day](https://img.shields.io/badge/Day-20-yellow?style=flat-square)
![Topic](https://img.shields.io/badge/Topic-AWS%20CLI-orange?style=flat-square)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen?style=flat-square)

> 📅 Date: April 08, 2026
> ⏱️ Time Spent: 3+ hrs
> 🎯 Goal: Install AWS CLI, configure IAM access keys, and control EC2, S3, and VPC entirely from the terminal — no browser needed

---

## 📌 What I Learned Today

### 1. What is AWS CLI?

**AWS CLI (Command Line Interface)** lets you control all of AWS from your terminal — no browser, no clicking around the console.

**Without CLI:**
```
Open browser → Login → Navigate to service → Click 10 times → Done
```

**With CLI:**
```bash
aws s3 cp index.html s3://my-bucket/    # Done in 1 second ⚡
```

> 💡 In real DevOps jobs, nobody clicks around the AWS console —
> everything is automated via CLI, scripts, and tools like Terraform.
> This is where you start thinking like a real DevOps engineer!

---

### 2. How AWS CLI Works

```
Your Terminal
     ↓
AWS CLI (installed on your machine)
     ↓
AWS API (authenticates with your credentials)
     ↓
AWS Services (EC2, S3, VPC...)
```

### 3. IAM User vs Root User

| | Root User | IAM User |
|--|-----------|----------|
| Access | Full God-mode | Scoped permissions |
| Use for CLI | ❌ Never | ✅ Always |
| Safe? | ❌ Dangerous | ✅ Recommended |

> ⚠️ Always use IAM user credentials for CLI — never root!

---

### 4. AWS CLI Configuration Fields

| Config | What it is |
|--------|-----------|
| Access Key ID | Like a username for API access |
| Secret Access Key | Like a password — shown only once! |
| Region | Default region (`ap-south-1` for Mumbai) |
| Output format | `json`, `table`, or `text` |

---

## 🛠️ Steps I Performed

### Step 1 — Installed AWS CLI v2 on Ubuntu

```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Verify
aws --version
# Output: aws-cli/2.x.x
```

> 💡 AWS CLI installs globally — can run from anywhere in terminal, not tied to any folder

---

### Step 2 — Created IAM Access Keys

- IAM → Users → `devops-user` → Security credentials tab
- Access keys → **Create access key** → Use case: CLI
- Downloaded `.csv` file safely

> ⚠️ Secret Access Key is shown **only once** — must store it securely immediately!

---

### Step 3 — Configured AWS CLI

```bash
aws configure
```

Entered:
```
AWS Access Key ID:     [Access Key ID]
AWS Secret Access Key: [Secret Access Key]
Default region name:   ap-south-1
Default output format: table
```

Verified config was saved:
```bash
cat ~/.aws/credentials
cat ~/.aws/config
```

---

### Step 4 — Basic CLI Commands

#### Identity Check
```bash
aws sts get-caller-identity
```
✔ Confirmed IAM user: `devops-user`

---

#### S3 Commands

```bash
# List all buckets
aws s3 ls

# List objects inside bucket
aws s3 ls s3://devops-day18-pradeep001

# Upload file to S3
aws s3 cp cli-test.html s3://devops-day18-pradeep001/

# Verify upload
aws s3 ls s3://devops-day18-pradeep001
```

✔ Output showed both files:
```
index.html
cli-test.html
```

---

#### EC2 Commands

```bash
# Full details
aws ec2 describe-instances --output table

# Filtered — clean output
aws ec2 describe-instances \
  --query "Reservations[*].Instances[*].[InstanceId,State.Name,InstanceType]" \
  --output table
```

✔ Output:
```
i-00d434a731f9d8953 | stopped | t3.micro
```

> 💡 `--query` filters only the fields you need — makes CLI output much cleaner!

---

#### VPC & Subnet Commands

```bash
# List all VPCs
aws ec2 describe-vpcs --output table

# List all subnets
aws ec2 describe-subnets --output table
```

✔ Both showed the resources created on Day 19

---

### Step 5 — Start/Stop EC2 via CLI

```bash
# Check instance state
aws ec2 describe-instances \
  --query "Reservations[*].Instances[*].[InstanceId,State.Name,Tags[?Key=='Name'].Value|[0]]" \
  --output table
```
✔ Output: `i-00d434a731f9d8953 | stopped | devops-server`

```bash
# Start instance
aws ec2 start-instances --instance-ids i-00d434a731f9d8953
```
✔ State: `pending → running`

```bash
# Verify running
aws ec2 describe-instances \
  --instance-ids i-00d434a731f9d8953 \
  --query "Reservations[*].Instances[*].[InstanceId,State.Name]" \
  --output table
```
✔ Output: `running`

```bash
# Stop instance
aws ec2 stop-instances --instance-ids i-00d434a731f9d8953
```
✔ State: `running → stopping`

---

## 💡 Key Concepts I Understood Today

- AWS CLI = direct AWS API control from terminal — no browser needed
- `aws configure` stores credentials in `~/.aws/credentials`
- Always use IAM user credentials — never root access keys
- Secret Access Key shown only once — save it immediately
- `aws sts get-caller-identity` = quick way to verify who you're logged in as
- `--query` flag filters output to only what you need
- `--output table` makes output human-readable
- CLI can do everything the console can — and faster
- This is the foundation of DevOps automation

---

## ❌ Mistakes I Made (and Learned From)

| Mistake | Error | What I Learned |
|---------|-------|----------------|
| Typed wrong bucket name `devops-days-pradeep001` | `NoSuchBucket` error | Bucket names must be exact — even one character off fails |
| Used double quotes with `!` in echo | `event not found` bash error | `!` breaks inside double quotes in bash — always use single quotes |
| Initial confusion about CLI vs Console | — | CLI = direct AWS API calls — same actions, just faster and scriptable |

---

## 📚 Resources I Used Today

- [AWS CLI Docs](https://docs.aws.amazon.com/cli/)
- [AWS CLI Command Reference](https://awscli.amazonaws.com/v2/documentation/api/latest/index.html)

---

## ✅ Tomorrow → Day 21: Review + Mini Project — Static Site on S3
