# Day 17 — AWS EC2: Launch, SSH, Security Groups

![Day](https://img.shields.io/badge/Day-17-yellow?style=flat-square)
![Topic](https://img.shields.io/badge/Topic-AWS%20EC2-orange?style=flat-square)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen?style=flat-square)

> 📅 Date: April 08, 2026
> ⏱️ Time Spent: 3+ hrs
> 🎯 Goal: Launch a real EC2 instance on AWS, SSH into it from Ubuntu terminal, configure Security Groups, and serve a live webpage using Nginx

---

## 📌 What I Learned Today

### 1. What is EC2?

**EC2 (Elastic Compute Cloud)** is AWS's virtual machine service — you rent a computer in Amazon's data center and choose the OS, CPU, RAM, and storage.

**Without EC2:**
```
Your app runs on your local machine → not accessible to the world
```

**With EC2:**
```
Your app runs on AWS server → accessible to the entire internet 🌍
```

> 💡 Think of EC2 like renting a PC in the cloud — you pay only for what you use,
> and anyone in the world can connect to it!

---

### 2. Key EC2 Concepts

#### AMI (Amazon Machine Image)
A **pre-built OS template** for your instance — like an ISO file.
- I used: **Ubuntu Server 24.04 LTS** (free tier eligible)
- Username to SSH with Ubuntu AMI: `ubuntu`

#### Instance Types
Defines the **hardware** — CPU, RAM, network.

| Type | vCPU | RAM | Free Tier? |
|------|------|-----|------------|
| `t2.micro` | 1 | 1 GB | ✅ Yes (some regions) |
| `t3.micro` | 2 | 1 GB | ✅ Yes (Mumbai) |
| `t3.small` | 2 | 2 GB | ❌ No |

> 💡 Mumbai region uses `t3.micro` instead of `t2.micro` — both are free tier eligible!

#### Security Groups
Acts as a **virtual firewall** — controls what traffic is allowed in and out.

| Rule | Port | Source | Use |
|------|------|--------|-----|
| SSH | 22 | My IP only | Connect via terminal |
| HTTP | 80 | 0.0.0.0/0 | Web traffic (public) |
| HTTPS | 443 | 0.0.0.0/0 | Secure web traffic |

#### Key Pair
A **public-private key pair** for SSH. AWS stores the public key on the instance — you keep the `.pem` file. Without it, you can't SSH in.

#### EBS (Elastic Block Store)
The **hard disk** of your instance. Default: 8 GB. Data persists when you stop (but NOT when you terminate).

---

### 3. EC2 Lifecycle

```
Launch → Running → Stop (paused, EBS kept, compute billing stops)
                 → Terminate (deleted forever ⚠️)
```

> ⚠️ Always STOP your instance when not using it — saves free tier hours!

---

### 4. What I Did Step by Step

#### Step 1 — Launch the Instance

- **Name:** `devops-server`
- **AMI:** Ubuntu Server 24.04 LTS
- **Instance type:** t3.micro (free tier eligible in Mumbai)
- **Key pair:** Created `devops-key.pem` → downloaded it
- **Region:** Asia Pacific — Mumbai (ap-south-1) — closest to Bengaluru ✅
- **Security group:** SSH (port 22) + HTTP (port 80)

#### Step 2 — Set Up Key Pair on Ubuntu

```bash
# Create .ssh folder (if not exists)
mkdir -p ~/.ssh

# Move key from Downloads
mv ~/Downloads/devops-key.pem ~/.ssh/

# Fix permissions — MANDATORY or SSH will refuse the key
chmod 400 ~/.ssh/devops-key.pem
```

#### Step 3 — SSH Into the Instance

```bash
ssh -i ~/.ssh/devops-key.pem ubuntu@13.232.123.218
```

First time connecting — SSH asks to confirm the server fingerprint:
```
Are you sure you want to continue connecting (yes/no/[fingerprint])?
```
Type `yes` — it saves the fingerprint and won't ask again.

#### Step 4 — Explore the Instance

```bash
whoami           # ubuntu
hostname         # ip-172-31-34-40
uname -a         # Linux kernel info
cat /etc/os-release  # Ubuntu 24.04.4 LTS
nproc            # 2 (vCPUs)
free -h          # 911Mi RAM
df -h            # 6.8G disk, 1.9G used
curl ifconfig.me # 13.232.123.218 (public IP)
```

#### Step 5 — Install and Start Nginx

```bash
sudo apt update
sudo apt install nginx -y
sudo systemctl start nginx
sudo systemctl status nginx
```

Result:
```
● nginx.service - A high performance web server
   Active: active (running) ✅
```

Then opened browser → `http://13.232.123.218` → **Welcome to nginx!** 🎉

---

### 5. Security Groups — Deep Dive

**Inbound Rules I Set:**

| Type | Port | Source | Why |
|------|------|--------|-----|
| SSH | 22 | `152.57.26.1/32` | Only my IP can SSH |
| HTTP | 80 | `0.0.0.0/0` | Anyone can access the website |

**The warning AWS shows:**
> "Rules with source 0.0.0.0/0 allow all IP addresses"

This is **fine for HTTP (port 80)** — web servers are supposed to be public.
This would be **dangerous for SSH (port 22)** — never open SSH to everyone!

---

### 6. Troubleshooting I Did Today

Real-world debugging — not everything works first try!

**Problem 1: SSH Connection Timed Out**
```
ssh: connect to host 13.232.123.218 port 22: Connection timed out
```
- Cause: Security group had old IP `152.57.8.50/32`
- Fix: Updated SSH rule to "My IP"

**Problem 2: Still Timed Out After Updating IP**

```bash
curl ifconfig.me
# Output: 2409:40f2:1034:1d3e:55eb:6cbb:d0ab:7cb3  ← IPv6!
```

- Cause: My machine was on IPv6 but security group only had IPv4 rule
- Fix: Used `curl -4 ifconfig.me` to get actual IPv4 address

```bash
curl -4 ifconfig.me
# Output: 152.57.26.1  ← IPv4 ✅
```

- Manually entered `152.57.26.1/32` in security group → SSH worked!

> 💡 Always use `curl -4 ifconfig.me` to get your IPv4 address for security group rules!

---

## 💡 Key Concepts I Understood Today

- EC2 = renting a virtual machine in AWS data center
- AMI = OS template (Ubuntu, Amazon Linux, etc.)
- Instance type = hardware config (t3.micro = 2 vCPU, 1GB RAM)
- Security Group = firewall — controls inbound/outbound traffic
- Key pair = `.pem` file — required for SSH, keep it safe!
- `chmod 400` on `.pem` is MANDATORY before SSH
- SSH port 22 → restrict to your IP only
- HTTP port 80 → open to 0.0.0.0/0 (that's correct for web servers)
- `curl -4 ifconfig.me` gives IPv4 address (use this for security group rules)
- Always STOP the instance when done — don't terminate!
- Mumbai region (ap-south-1) = best region for India

---

## ❌ Mistakes I Made (and Learned From)

| Mistake | Error | What I Learned |
|---------|-------|----------------|
| Used "My IP" in security group | SSH still timed out | AWS detected IPv6, but EC2 uses IPv4 — always verify with `curl -4 ifconfig.me` |
| IP changed between sessions | Connection timed out | ISPs assign dynamic IPs — update security group rule every session |
| Launched in wrong region (Stockholm) | Had to redo | Always check region top-right — use Mumbai for India |

---

## 📚 Resources I Used Today

- [AWS EC2 Docs](https://docs.aws.amazon.com/ec2/)
- [Nginx Official Docs](https://nginx.org/en/docs/)

---

## ✅ Tomorrow → Day 18: S3 — Buckets, Policies, Static Website Hosting
