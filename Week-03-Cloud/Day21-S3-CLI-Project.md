# Day 21 — Review + Mini Project: Deploy Static Website to S3 via CLI

![Day](https://img.shields.io/badge/Day-21-yellow?style=flat-square)
![Topic](https://img.shields.io/badge/Topic-Mini%20Project%20S3%20CLI-orange?style=flat-square)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen?style=flat-square)

> 📅 Date: April 08, 2026
> ⏱️ Time Spent: 3+ hrs
> 🎯 Goal: Combine everything from Week 3 — deploy a static portfolio website to AWS S3 using only the CLI, with a shell script for automation. No AWS Console!

---

## 📌 What I Built Today

This is the **Week 3 capstone project** — combining all concepts from Days 17–20:

```
Day 17 (EC2) + Day 18 (S3) + Day 19 (VPC) + Day 20 (CLI)
                        ↓
     Deploy a static portfolio website to S3 using ONLY CLI
                 Automate it with a shell script
```

> 💡 This is the first real DevOps project — not just practice.
> Infrastructure setup + deployment + automation, all from the terminal!

---

## 🏗️ Project Overview

| Item | Value |
|------|-------|
| Bucket | `devops-day21-pradeep-001` |
| Region | `ap-south-1` (Mumbai) |
| Website | Personal DevOps portfolio page |
| Deploy method | AWS CLI only — zero console clicks |
| Automation | `deploy.sh` shell script |

---

## 🛠️ Steps I Performed

### Step 1 — Created Project Folder

```bash
mkdir ~/90-Days-Of-DevOps/Week-03-Cloud/Day21-Project
cd ~/90-Days-Of-DevOps/Week-03-Cloud/Day21-Project
```

---

### Step 2 — Created Website File

```bash
nano index.html
```

Built a personal DevOps portfolio page with:
- Name and intro
- Skills grid: AWS, Linux, DevOps, Docker (coming soon)
- Hosted on S3 footer note

---

### Step 3 — Created S3 Bucket via CLI

```bash
aws s3api create-bucket \
  --bucket devops-day21-pradeep-001 \
  --region ap-south-1 \
  --create-bucket-configuration LocationConstraint=ap-south-1
```

> 💡 `--create-bucket-configuration LocationConstraint` is required for all regions except `us-east-1`

---

### Step 4 — Disabled Block Public Access via CLI

```bash
aws s3api put-public-access-block \
  --bucket devops-day21-pradeep-001 \
  --public-access-block-configuration \
  "BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false"
```

> 💡 Must be done before adding public bucket policy — AWS blocks public policies by default

---

### Step 5 — Uploaded File to S3

```bash
aws s3 cp index.html s3://devops-day21-pradeep-001/
```

---

### Step 6 — Enabled Static Website Hosting via CLI

```bash
aws s3api put-bucket-website \
  --bucket devops-day21-pradeep-001 \
  --website-configuration '{
    "IndexDocument": {"Suffix": "index.html"},
    "ErrorDocument": {"Key": "index.html"}
  }'
```

---

### Step 7 — Added Bucket Policy via CLI

```bash
aws s3api put-bucket-policy \
  --bucket devops-day21-pradeep-001 \
  --policy '{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "PublicReadGetObject",
        "Effect": "Allow",
        "Principal": "*",
        "Action": "s3:GetObject",
        "Resource": "arn:aws:s3:::devops-day21-pradeep-001/*"
      }
    ]
  }'
```

---

### Step 8 — Accessed Live Website

```bash
echo "http://devops-day21-pradeep-001.s3-website.ap-south-1.amazonaws.com"
```

🌍 **Website live and accessible in browser!** ✅

---

### Step 9 — Created Automation Deploy Script

```bash
nano deploy.sh
```

```bash
#!/bin/bash

BUCKET="devops-day21-pradeep-001"
REGION="ap-south-1"

echo "🚀 Deploying full project..."

aws s3 sync . s3://$BUCKET/ --exclude ".git/*"

echo "✅ Deployment complete!"
echo "🌍 Live at: http://$BUCKET.s3-website.$REGION.amazonaws.com"
```

```bash
chmod +x deploy.sh
./deploy.sh
```

> 💡 Used `aws s3 sync` instead of `aws s3 cp` — sync is smarter:
> it only uploads files that have **changed**, skipping unchanged ones.
> Much better for real deployments!

---

## 🔄 aws s3 cp vs aws s3 sync

| Command | What it does | Best for |
|---------|-------------|----------|
| `aws s3 cp` | Copies one file | Single file upload |
| `aws s3 sync` | Syncs entire folder, skips unchanged files | Full project deployment |

---

## 💡 Key Concepts I Understood Today

- Complete DevOps workflow: infrastructure + deployment + automation
- `aws s3api create-bucket` needs `LocationConstraint` for non-us-east-1 regions
- Block public access must be disabled BEFORE adding public bucket policy
- `aws s3 sync` is better than `aws s3 cp` for deploying projects
- Shell scripts (`deploy.sh`) turn multi-step deployments into one command
- `chmod +x` makes a script executable
- `--exclude ".git/*"` prevents git internals from being uploaded to S3
- Everything done on Day 18 via console → now done 100% via CLI

---

## ❌ Mistakes I Made (and Learned From)

| Mistake | Error | What I Learned |
|---------|-------|----------------|
| Ran `aws s3 cp index.html` from wrong directory | `path does not exist` | Always check directory with `pwd` and `ls` before running CLI commands |
| Used `cd ~` multiple times unnecessarily | Wasted time | Stay inside project folder for consistency |
| Initially used `aws s3 cp` for deployment | Had to re-run for each file | Switched to `aws s3 sync` — uploads entire folder in one command |

---

## 📚 Resources I Used Today

- [AWS S3 CLI Reference](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/s3/index.html)
- [AWS S3api CLI Reference](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/s3api/index.html)

---

## 🌍 Live Project

[http://devops-day21-pradeep-001.s3-website.ap-south-1.amazonaws.com](http://devops-day21-pradeep-001.s3-website.ap-south-1.amazonaws.com)

---

## ✅ Week 3 Complete!

| Day | Topic | Status |
|-----|-------|--------|
| Day 17 | EC2 — Launch, SSH, Security Groups | ✅ |
| Day 18 | S3 — Buckets, Policies, Static Website | ✅ |
| Day 19 | VPC — Subnets, IGW, Route Tables | ✅ |
| Day 20 | AWS CLI — Setup & Basic Commands | ✅ |
| Day 21 | Mini Project — S3 Static Site via CLI | ✅ |

---

## ✅ Tomorrow → Day 22: Load Balancers + Auto Scaling (Week 4 begins!)
