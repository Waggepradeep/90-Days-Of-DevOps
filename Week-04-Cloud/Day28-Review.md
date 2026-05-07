# Day 28 — Week 4 Review + Polish S3 Project

![Day](https://img.shields.io/badge/Day-28-yellow?style=flat-square)
![Topic](https://img.shields.io/badge/Topic-Review%20%2B%20Portfolio%20Polish-orange?style=flat-square)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen?style=flat-square)

> 📅 Date: April 11, 2026
> ⏱️ Time Spent: 3+ hrs
> 🎯 Goal: Review all Week 4 concepts, upgrade the Day 21 S3 static site into a real portfolio page, and push all notes to GitHub

---

## 📋 Week 4 Review — What I Learned

### Day 22 — Load Balancers + Auto Scaling
- ALB = distributes HTTP traffic across multiple EC2 instances
- ASG = automatically adds/removes EC2s based on demand (min/desired/max)
- Launch Template = blueprint ASG uses to launch instances
- User data = runs automatically on instance launch — no manual setup
- Always delete ASG before ALB — otherwise ASG relaunches instances

### Day 23 — RDS + DynamoDB
- RDS = managed SQL (MySQL/PostgreSQL) — for structured, relational data
- DynamoDB = managed NoSQL — for fast key-value lookups at any scale
- Partition key in DynamoDB = critical — determines data distribution
- RDS needs DB Subnet Group across 2+ AZs before creation

### Day 24 — CloudWatch + SNS + Logging
- 3 pillars: Metrics (numbers) + Alerting (alarms) + Logging (text)
- CloudWatch alarm triggers only on state change (OK → In Alarm)
- CloudWatch Agent ships app logs — must install manually via `.deb` on Ubuntu
- `CloudWatchAgentServerPolicy` = IAM policy needed for log shipping

### Day 25 — Route 53 + DNS
- A record = domain → IPv4, Alias record = domain → AWS resource
- S3 bucket name MUST match domain name for Alias record to work
- NXDOMAIN = DNS record not found
- Hosted zone ≠ working domain — need purchased domain for public DNS

### Day 26 — Lambda + Serverless
- Lambda = run code without servers — pay per execution only
- `lambda_handler(event, context)` = entry point for every function
- Cold start = slight delay when Lambda not recently used
- `KeyError: 'Records'` = S3 trigger code tested manually without S3 event structure

### Day 27 — Cloud Security
- Principle of least privilege = give only permissions needed
- Never delete access key before creating a new one — CLI stops working
- CloudTrail = logs every AWS API call — who/when/what
- S3 website bucket needs public access ON, all other buckets OFF
- Secrets Manager > hardcoding credentials anywhere

---

## 🛠️ What I Built Today — Polished Portfolio Site

Upgraded the basic Day 21 S3 site into a **real DevOps portfolio page**.

### What Changed

| Before (Day 21) | After (Day 28) |
|----------------|----------------|
| Basic centered card | Full portfolio layout |
| Single h1 + 2 lines | Header + Skills + Projects + Journey + Footer |
| No projects section | 3 projects with tech tags + Live/Soon buttons |
| No journey tracker | Week progress tracker (W1–W12) |
| No GitHub link | Footer with GitHub link |

---

### Deployed via CLI

```bash
cd ~/day21-project
./deploy.sh
```

Output:
```
🚀 Deploying full project...
✅ Deployment complete!
🌍 Live at: http://devops-day21-pradeep-001.s3-website.ap-south-1.amazonaws.com
```

---

### Live Portfolio Sections

**Header:**
- Name + role + location
- Skill badges: AWS, Linux, DevOps, Docker (coming), Terraform (coming)

**Skills Grid:**
- AWS Cloud — EC2, S3, VPC, IAM, RDS, Lambda, CloudWatch, Route 53, ALB, Auto Scaling
- Linux — Ubuntu, permissions, processes, networking, bash scripting
- Git & GitHub — Branching, merging, GitHub Actions CI/CD
- CLI & Automation — AWS CLI, bash scripts, deploy automation, S3 sync

**Projects:**
- 🚀 S3 Static Portfolio Site → Live button
- 🔧 CI/CD Pipeline → Soon (Day 68)
- ☸️ K8s Microservice → Soon (Day 42)

**90 Days Journey Tracker:**
- W1–2 Linux + Git ✅ (green)
- W3–4 AWS Cloud ✅ (green)
- W5–6 Docker + K8s 🔄 (blue — in progress)
- W7–8 Terraform ⬜
- W9–10 CI/CD ⬜
- W11–12 Monitoring ⬜

**Footer:**
- Hosted on AWS S3 · Deployed via AWS CLI · Part of 90 Days of DevOps · GitHub ↗

---

## 💡 Key Takeaways from Week 4

- Week 4 took cloud knowledge from basics to production-level services
- Every service learned has a real-world use case in DevOps jobs
- Security is not a separate concern — it's built into every service
- CLI > Console for speed, automation, and real DevOps workflows
- A portfolio page that's actually live on AWS is more impressive than a screenshot

---

## 🌍 Live Project

[http://devops-day21-pradeep-001.s3-website.ap-south-1.amazonaws.com](http://devops-day21-pradeep-001.s3-website.ap-south-1.amazonaws.com)

---

## ✅ Phase 1 Complete!

| Week | Topic | Status |
|------|-------|--------|
| Week 1–2 | Linux + Git + GitHub | ✅ |
| Week 3 | AWS Cloud Basics (EC2, S3, VPC, CLI) | ✅ |
| Week 4 | AWS Advanced (ALB, RDS, CloudWatch, Lambda, Security) | ✅ |

---

## ✅ Tomorrow → Day 29: Docker Intro — Phase 2 Begins! 🐳
