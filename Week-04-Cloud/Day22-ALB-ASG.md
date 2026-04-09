# Day 22 — Load Balancers + Auto Scaling

![Day](https://img.shields.io/badge/Day-22-yellow?style=flat-square)
![Topic](https://img.shields.io/badge/Topic-ALB%20%2B%20Auto%20Scaling-orange?style=flat-square)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen?style=flat-square)

> 📅 Date: April 09, 2026
> ⏱️ Time Spent: 3+ hrs
> 🎯 Goal: Set up a scalable web application using EC2 Launch Template, Auto Scaling Group, and Application Load Balancer — so the infrastructure scales automatically with traffic

---

## 📌 What I Learned Today

### 1. What Problem Does This Solve?

**Without Load Balancer + Auto Scaling:**
```
10,000 requests → 1 EC2 instance → crashes 💀
```

**With Load Balancer + Auto Scaling:**
```
10,000 requests → ALB → spreads across 3 EC2s → handles it fine ✅
Traffic drops   → ASG scales back to 1 EC2 → saves money 💰
```

---

### 2. Key Concepts

#### Launch Template
A **blueprint** for EC2 instances — defines AMI, instance type, security group, key pair, and user data script. Auto Scaling uses this to launch new instances automatically.

#### Auto Scaling Group (ASG)
Automatically **adds or removes EC2 instances** based on demand.

```
CPU > 70% → launch more EC2s   (scale out) 📈
CPU < 30% → terminate EC2s     (scale in)  📉
```

| Setting | Value Used | Meaning |
|---------|-----------|---------|
| Minimum | 1 | Always keep at least 1 instance |
| Desired | 2 | Normally run 2 instances |
| Maximum | 3 | Never exceed 3 instances |

#### Application Load Balancer (ALB)
A **traffic distributor** — sits in front of instances and spreads requests across all healthy ones.

```
Users
  ↓
ALB (single entry point)
  ↓          ↓
EC2 #1     EC2 #2
```

#### Target Group
A **group of EC2 instances** the ALB routes traffic to. Performs health checks — if an instance fails, ALB automatically stops sending traffic to it.

#### How They All Work Together

```
Internet
    ↓
Application Load Balancer (devops-alb)
    ↓
Target Group (devops-tg) — health checks
    ↓
Auto Scaling Group (devops-asg)
    ├── EC2 #1 (always running — minimum: 1)
    └── EC2 #2 (launched for desired: 2)
             ↑
    Launch Template (devops-launch-template)
```

---

### 3. User Data Script

This script runs **automatically** when each EC2 instance launches — no manual SSH needed!

```bash
#!/bin/bash
sudo apt update -y
sudo apt install nginx -y
sudo systemctl start nginx
sudo systemctl enable nginx
echo "<h1>Hello from $(hostname)</h1>" > /var/www/html/index.nginx-debian.html
```

> 💡 `$(hostname)` prints the server's private hostname — so each instance shows a different name.
> This lets you see which EC2 is serving your request when you refresh the page!

---

## 🛠️ Steps I Performed

### Step 1 — Created Launch Template

- **Name:** `devops-launch-template`
- **AMI:** Ubuntu Server 24.04 LTS
- **Instance type:** `t3.micro`
- **Key pair:** `devops-key`
- **Security group:** `devops-web-sg` — allowed ports 22 (SSH) and 80 (HTTP)
- **User data:** Nginx install + start script (see above)

---

### Step 2 — Created Auto Scaling Group

- **Name:** `devops-asg`
- **Launch template:** `devops-launch-template`
- **VPC:** `devops-vpc` (custom VPC from Day 19)
- **Subnets:** public subnets (multi-AZ for high availability)
- **Load balancer:** Application Load Balancer
  - Name: `devops-alb`
  - Scheme: Internet-facing
  - Listener: HTTP port 80
  - Target group: `devops-tg`
- **Health checks:** ELB health checks enabled
- **Scaling config:** Min: 1, Desired: 2, Max: 3

---

### Step 3 — Verified Setup

After ~3 minutes:
- ✅ 2 EC2 instances launched **automatically** by ASG — no manual launching!
- ✅ Both instances registered in `devops-tg` target group
- ✅ Health checks passed — both showing **Healthy**

Accessed ALB DNS in browser:
```
http://devops-alb-xxxxx.ap-south-1.elb.amazonaws.com
```

✅ Nginx page loaded — showing `Hello from ip-10-0-x-xxx`

---

### Step 4 — Cleanup (Important ⚠️)

ALB is **NOT free tier** — deleted everything after lab:

Deleted in correct order:
1. **Auto Scaling Group** first — otherwise it relaunches terminated instances
2. **Load Balancer** (`devops-alb`)
3. **Target Group** (`devops-tg`)
4. **Launch Template**
5. **EC2 instances** — terminated
6. **EBS volumes** — deleted after instance termination

---

## 💡 Key Concepts I Understood Today

- Launch Template = blueprint for EC2 — ASG uses it to launch instances automatically
- Auto Scaling Group = manages instance lifecycle based on demand
- ALB = distributes traffic across all healthy instances
- Target Group = pool of instances ALB routes to, with health checks
- User data script = runs automatically on instance launch — no manual setup needed
- `$(hostname)` in user data = each instance shows its own name
- Multi-AZ subnets = instances spread across availability zones for high availability
- HTTPS requires SSL/TLS certificate — HTTP works by default
- Servers are **disposable** in DevOps — automation rebuilds them anytime
- Always delete ASG before ALB — otherwise ASG relaunches instances

---

## ❌ Mistakes I Made (and Learned From)

| Mistake | Observation | What I Learned |
|---------|-------------|----------------|
| Tried HTTPS on ALB DNS | Did not work | HTTPS requires SSL/TLS certificate (ACM) — not configured today |
| Almost deleted ALB before ASG | Would have caused issues | Always delete ASG first — it manages instance lifecycle |

---

## 🔑 Final Insight

```
In DevOps:
Servers are disposable.
Automation > manual setup.
```

Infrastructure is temporary and reproducible — the Launch Template + ASG can rebuild
everything from scratch in minutes. That's the power of cloud automation.

---

## 📚 Resources I Used Today

- [AWS ALB Docs](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/)
- [AWS Auto Scaling Docs](https://docs.aws.amazon.com/autoscaling/ec2/userguide/)

---

## ✅ Tomorrow → Day 23: RDS + DynamoDB Basics
