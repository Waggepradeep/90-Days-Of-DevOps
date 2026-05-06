# Day 25 — AWS Route 53 + DNS Management

![Day](https://img.shields.io/badge/Day-25-yellow?style=flat-square)
![Topic](https://img.shields.io/badge/Topic-Route%2053%20%2B%20DNS-orange?style=flat-square)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen?style=flat-square)

> 📅 Date: April 10, 2026
> ⏱️ Time Spent: 3+ hrs
> 🎯 Goal: Understand DNS fundamentals, create Route 53 hosted zones, manage DNS records, host a static website on S3 with Route 53 routing, and configure health checks

---

## 📌 What I Learned Today

### 1. What Problem Does This Solve?

**Without DNS:**
```
Users must remember: http://13.232.123.218  ← impossible to share
```

**With Route 53 + DNS:**
```
Users just type: mywebsite.com → Route 53 → 13.232.123.218 ✅
```

> 💡 DNS = Phone book of the internet.
> Humans remember names (google.com), computers need IPs (142.250.77.46)

---

### 2. What is Route 53?

AWS's **managed DNS service** — translates domain names to IP addresses. Also handles:
- Domain registration
- DNS management
- Traffic routing (weighted, latency, geolocation, failover)
- Health monitoring

---

### 3. Key DNS Concepts

| Concept | Meaning |
|---------|---------|
| DNS | Converts domain names → IP addresses |
| Hosted Zone | Container for all DNS records of a domain |
| Public Hosted Zone | Internet-accessible DNS |
| Private Hosted Zone | Internal VPC-only DNS |
| Record | A single DNS mapping entry |
| TTL | How long DNS resolvers cache a record |

---

### 4. DNS Record Types

| Record | Purpose | Example |
|--------|---------|---------|
| **A** | Domain → IPv4 address | `mysite.com → 13.232.123.218` |
| **AAAA** | Domain → IPv6 address | `mysite.com → 2001:db8::1` |
| **CNAME** | Domain → another domain | `www.mysite.com → mysite.com` |
| **MX** | Mail server records | `mysite.com → mail.mysite.com` |
| **NS** | Authoritative nameservers | AWS name servers |
| **SOA** | Zone authority info | Start of Authority record |
| **TXT** | Text info (verification, SPF) | `"v=spf1 include:aws..."` |
| **Alias** | AWS-specific → points to AWS resources | `mysite.com → ALB or S3` |

---

### 5. Public vs Private Hosted Zones

| | Public Hosted Zone | Private Hosted Zone |
|--|-------------------|---------------------|
| Accessible from | Internet | VPC only |
| Use case | Public websites | Internal apps/services |
| Example | `devops-practice.com` | `devops-practice.internal` |

---

### 6. Route 53 Routing Policies

| Policy | What it does |
|--------|-------------|
| **Simple** | One record → one resource |
| **Weighted** | Split traffic by % (80% → A, 20% → B) |
| **Latency** | Route to lowest latency AWS region |
| **Failover** | Primary + backup — switch if primary fails |
| **Geolocation** | Route based on user's country/continent |

---

### 7. Critical S3 + Route 53 Rule

> ⚠️ For Route 53 Alias to work with S3 static website hosting:
> **Bucket name MUST exactly match the domain name.**

```
Domain: devops-practice.com
Bucket name must be: devops-practice.com  ← exact match required
```

If names don't match → Route 53 rejects the alias as invalid endpoint.

---

## 🛠️ Steps I Performed

### Step 1 — Created Hosted Zones

**Public Hosted Zone:**
- Domain: `devops-practice.com`
- Type: Public (internet-accessible)
- Auto-created records: NS + SOA

**Private Hosted Zone:**
- Domain: `devops-practice.internal`
- Type: Private (VPC only)
- VPC: `devops-vpc`

---

### Step 2 — Created S3 Bucket Matching Domain Name

```
Bucket name: devops-practice.com   ← matches domain exactly
Region: ap-south-1
```

- Disabled Block Public Access
- Enabled Static Website Hosting
- Index document: `index.html`
- Uploaded `index.html`

```html
<!DOCTYPE html>
<html>
<head><title>My S3 Website</title></head>
<body>
  <h1>My S3 Static Website is Working!</h1>
</body>
</html>
```

Added public bucket policy:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::devops-practice.com/*"
    }
  ]
}
```

S3 website endpoint generated:
```
http://devops-practice.com.s3-website.ap-south-1.amazonaws.com
```
✅ Endpoint worked successfully!

---

### Step 3 — Connected Route 53 to S3 (Alias Record)

- Hosted zone: `devops-practice.com`
- Created **A record (Alias)**
- Target: `s3-website.ap-south-1.amazonaws.com`
- Routes traffic from domain → S3 website ✅

---

### Step 4 — CLI Commands

```bash
# List all hosted zones
aws route53 list-hosted-zones

# List DNS records in a hosted zone
aws route53 list-resource-record-sets \
  --hosted-zone-id HOSTED_ZONE_ID
```

---

### Step 5 — DNS Tools

```bash
# Test private DNS resolution
nslookup app.devops-practice.internal
# Result: NXDOMAIN (record not found — expected for unregistered domain)

# Check mail server records
dig google.com MX

# Check authoritative nameservers
dig google.com NS
```

---

### Step 6 — Created Health Check

- **Name:** `s3-health-check`
- **Protocol:** HTTP
- **Interval:** 30 seconds
- **Failure threshold:** 3
- **Status:** ✅ Healthy

> 💡 Health checks let Route 53 automatically stop routing traffic
> to unhealthy endpoints — the foundation of failover routing!

---

## 💡 Key Concepts I Understood Today

- Route 53 = AWS managed DNS — translates domain names to IPs
- Hosted Zone = container for all DNS records of a domain
- Public hosted zone = internet, private hosted zone = VPC internal only
- A record = maps domain to IPv4 address
- Alias record = AWS-specific, maps domain to AWS resources (S3, ALB, CloudFront)
- CNAME = maps domain to another domain name
- TTL = how long DNS answer is cached (lower = faster propagation)
- S3 bucket name MUST match domain name for Route 53 Alias to work
- Hosted zone alone doesn't make a domain work — need a purchased/registered domain
- Health checks monitor endpoints and enable automatic failover
- `nslookup` and `dig` are essential DNS troubleshooting tools
- `NXDOMAIN` = DNS record not found

---

## ❌ Mistakes I Made (and Learned From)

| Mistake | Error | What I Learned |
|---------|-------|----------------|
| Used wrong S3 endpoint format `s3-website-ap-south-1` | Alias record rejected | Correct format is `s3-website.ap-south-1` (dot not dash) |
| Bucket objects not public | 403 AccessDenied on website | Must add bucket policy AND disable Block Public Access |
| Tried accessing custom domain without real registration | Domain not opening in browser | Hosted zone alone ≠ working domain. Need purchased domain OR DNS delegation from registrar |

---

## 🔑 Interview-Level Concepts

### S3 Website Endpoint vs REST Endpoint

| Website Endpoint | REST Endpoint |
|-----------------|---------------|
| Used for static websites | Used for API/object access |
| Supports `index.html` routing | Does not support website hosting |
| Format: `bucket.s3-website.region.amazonaws.com` | Format: `bucket.s3.region.amazonaws.com` |

### Real-World Use Cases

| Topic | Real Usage |
|-------|-----------|
| Route 53 | DNS management for production apps |
| Health Checks | Auto-failover when primary region goes down |
| S3 Static Hosting | Hosting frontend/marketing sites at near-zero cost |
| Alias Records | Route traffic to ALB, CloudFront, S3 without IP |
| Private Hosted Zones | Internal microservice DNS (service-a.internal) |

---

## 📚 Resources I Used Today

- [AWS Route 53 Docs](https://docs.aws.amazon.com/route53/)
- [S3 Static Website Hosting](https://docs.aws.amazon.com/AmazonS3/latest/userguide/WebsiteHosting.html)

---

## ✅ Tomorrow → Day 26: Lambda — Serverless Basics
