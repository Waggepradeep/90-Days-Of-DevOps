# Day 15 — AWS Overview + Free Tier Setup

![Day](https://img.shields.io/badge/Day-15-yellow?style=flat-square)
![Topic](https://img.shields.io/badge/Topic-AWS%20Overview-blue?style=flat-square)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen?style=flat-square)

> 📅 Date: April 7, 2026
> ⏱️ Time Spent: 3+ hrs
> 🎯 Goal: Understand AWS fundamentals, global infrastructure, core services, and set up Free Tier account safely

---

## 📌 What I Learned Today

### 1. What is AWS?

AWS (Amazon Web Services) is the world's most widely used **cloud platform**, offering 200+ services — compute, storage, databases, networking, AI — all available on-demand over the internet.

> Instead of buying a physical server (expensive + slow to set up), you **rent** one from AWS in seconds and pay only for what you use. This is called **pay-as-you-go** pricing.

---

### 2. AWS Global Infrastructure

Three key concepts:

#### Regions
- Physical locations around the world where AWS has data centers
- Each region is **completely independent**
- Example: `ap-south-1` = **Mumbai** (closest to Bengaluru — always use this!)
- Rule: Choose the region **closest to your users** for lowest latency

#### Availability Zones (AZs)
- Each Region has **2–6 AZs**
- Each AZ = one or more isolated physical data centers
- If one AZ fails, the others keep running → **high availability**

#### Edge Locations
- Used by **CloudFront (CDN)** to cache content closer to end users
- Makes websites and apps load faster globally
- There are **more edge locations than regions** worldwide

```
Region (ap-south-1 — Mumbai)
├── AZ 1 (ap-south-1a)
├── AZ 2 (ap-south-1b)
└── AZ 3 (ap-south-1c)
```

---

### 3. Core AWS Services — Big Picture

| Category | Service | What It Does |
|---|---|---|
| Compute | **EC2** | Virtual machines in the cloud |
| Storage | **S3** | Object storage — files, images, backups |
| Database | **RDS** | Managed relational databases |
| Networking | **VPC** | Your private network inside AWS |
| Security | **IAM** | Users, roles, and permissions |
| Monitoring | **CloudWatch** | Logs, metrics, and alerts |
| DNS | **Route 53** | Domain name management |
| Serverless | **Lambda** | Run code without managing servers |
| Containers | **ECS / EKS** | Run Docker containers at scale |

> 💡 You'll cover all of these in Days 15–28!

---

### 4. AWS Free Tier — What You Get

Three types of free offers:

**Always Free (Never expires)**
- AWS Lambda: 1 million requests/month
- DynamoDB: 25 GB storage
- CloudWatch: 10 custom metrics

**12 Months Free (From account creation date)**
- **EC2:** 750 hrs/month — t2.micro or t3.micro ← use this for everything!
- **S3:** 5 GB storage
- **RDS:** 750 hrs/month — db.t2.micro
- **CloudFront:** 1 TB data transfer/month

**Short-term Trials**
- Some services offer 30–60 day free trials

> ⚠️ Always use **t2.micro or t3.micro** for EC2
> ⚠️ Always check your **region** before launching anything
> ⚠️ Set a **billing alert** before doing anything else!

---

### 5. AWS Console — Services I Explored

After logging in and setting region to **Mumbai (ap-south-1)**:

```
Compute:      EC2, Lambda, Lightsail, Elastic Beanstalk
Storage:      S3, EFS, FSx
Containers:   ECS, EKS, ECR
Management:   CloudWatch, CloudFormation, AWS Config, Systems Manager
Security:     IAM, GuardDuty, Secrets Manager, Cognito, Certificate Manager
Networking:   VPC, Route 53, CloudFront
Database:     RDS, DynamoDB, ElastiCache
```

---

## 🛠️ Hands-On Practice

### Task 1 — Set Default Region
```
AWS Console → Top right corner → Changed to Asia Pacific (Mumbai) ap-south-1
URL confirms: ap-south-1.console.aws.amazon.com ✅
```

### Task 2 — Explored All Services
```
AWS Console → Click grid icon (⋮⋮⋮) → View All Services
→ Explored: EC2, S3, IAM, VPC, CloudWatch, Lambda ✅
```

### Task 3 — Set Zero Spend Billing Alert
```
AWS Console → Search "Billing" → Budgets → Create Budget
→ Template: Zero spend budget
→ Alerts when spending exceeds $0.01
→ Email: waggepradeep369@gmail.com
→ Created! ✅
```

**Why this is important:**
> If you forget to stop an EC2 instance or accidentally use a paid service,
> this alert emails you IMMEDIATELY before any real charge hits!

### Task 4 — Checked Free Tier Usage
```
AWS Console → Billing → Free Tier
→ 1 service in use: AWS Glue (12 requests — 0.00% of limit)
→ Credits remaining: $119.93
→ 0 of 1 services at or above limit ✅ All safe!
```

---

## 💡 Key Concepts I Understood Today

- AWS = cloud platform with 200+ services, pay only for what you use
- Always use **Mumbai (ap-south-1)** from Bengaluru — lowest latency
- **Region** = geographic location, **AZ** = isolated data center within a region
- Multiple AZs = high availability (one fails, others still run)
- Free Tier gives EC2, S3, RDS free for **12 months** within limits
- Always set a **billing alert FIRST** before touching any service
- `t2.micro` / `t3.micro` = the magic words for staying in Free Tier on EC2
- AWS Console organizes 200+ services neatly by category

---

## ❌ Mistakes I Made (and Learned From)

| Mistake | What Happened | What I Learned |
|---|---|---|
| Billing page showed "Global" region | Billing is always global, not region-specific | Billing & Cost Management is always in Global — that's normal! |
| Wasn't sure which EC2 type is free | Almost picked wrong instance type | Always pick **t2.micro or t3.micro** — those are Free Tier eligible |

---

## 🧠 Key Terms

| Term | Meaning |
|---|---|
| Region | Geographic location of AWS data centers |
| Availability Zone (AZ) | Isolated data center within a region |
| Edge Location | Cache point used by CloudFront CDN |
| Free Tier | AWS services usable for free within limits |
| IAM | Identity & Access Management — who can do what |
| Pay-as-you-go | Pay only for what you use, no upfront cost |
| Console | Web UI to manage AWS services |
| CLI | Command line interface to interact with AWS |

---

## 📅 What's Coming Next (Days 16–21)

| Day | Topic |
|---|---|
| Day 16 | IAM — Users, Roles, Policies |
| Day 17 | EC2 — Launch, SSH, Security Groups |
| Day 18 | S3 — Buckets, Policies, Static Website |
| Day 19 | VPC — Subnets, Route Tables, IGW |
| Day 20 | AWS CLI Setup + Basic Commands |
| Day 21 | Mini Project — Static Site on S3 |

---

## 📚 Resources I Used Today

- [AWS Free Tier](https://aws.amazon.com/free/)
- [AWS Global Infrastructure](https://aws.amazon.com/about-aws/global-infrastructure/)
- [AWS Skill Builder](https://skillbuilder.aws)
- [FreeCodeCamp AWS Full Course](https://www.youtube.com/watch?v=ulprqHHWlng)

---

## ✅ Tomorrow → Day 16: IAM — Users, Roles, Policies
