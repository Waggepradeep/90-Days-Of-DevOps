# Day 27 — AWS Cloud Security Best Practices

![Day](https://img.shields.io/badge/Day-27-yellow?style=flat-square)
![Topic](https://img.shields.io/badge/Topic-AWS%20Cloud%20Security-orange?style=flat-square)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen?style=flat-square)

> 📅 Date: April 10, 2026
> ⏱️ Time Spent: 3+ hrs
> 🎯 Goal: Understand AWS security fundamentals — IAM hardening, MFA, CloudTrail auditing, S3 security, Secrets Manager, GuardDuty, and security best practices across all services used so far

---

## 📌 What I Learned Today

### 1. Why Security Matters

Every service built so far — EC2, S3, RDS, Lambda — is exposed to the internet. One misconfiguration and:

```
Open S3 bucket    → anyone downloads your data 😱
Weak IAM          → attacker controls your entire AWS account 💀
No MFA            → password leak = full account access 🔑
Public RDS        → database exposed to the world 🌍
Hardcoded secrets → credentials leaked in code 🚨
```

> 💡 The #1 cause of AWS breaches = misconfigured IAM + open S3 buckets.
> Security is not optional in DevOps — it's built in from day one.

---

### 2. Principle of Least Privilege

Give users/roles **only the permissions they need** — nothing more.

```
❌ Bad:  Give developer AdministratorAccess
✅ Good: Give developer only S3ReadOnly + EC2StartStop
```

---

### 3. Root Account Rules

```
✅ Enable MFA on root account immediately
✅ Never use root for daily tasks
✅ Never create access keys for root
✅ Lock root credentials away safely
```

---

### 4. IAM Users vs IAM Roles

| | IAM User | IAM Role |
|--|---------|---------|
| For | Humans | AWS services / applications |
| Credentials | Long-term (access keys) | Temporary (auto-rotated) |
| Best practice | Use for people | Use for EC2, Lambda etc. |

---

### 5. AWS Security Services Overview

| Service | Purpose |
|---------|---------|
| **IAM** | Identity & access management |
| **MFA** | Extra authentication layer |
| **CloudTrail** | Logs every API call in the account |
| **KMS** | Encrypt data at rest |
| **GuardDuty** | Threat detection — finds suspicious activity |
| **Secrets Manager** | Securely store passwords, API keys |
| **AWS WAF** | Web Application Firewall |
| **AWS Shield** | DDoS protection |
| **Config** | Track configuration changes over time |
| **VPC Flow Logs** | Record all network traffic |

---

### 6. CloudTrail — The Security Camera

**Every action in AWS is logged by CloudTrail.**

```
Who made this change?       → CloudTrail knows
When was this deleted?      → CloudTrail knows
Which IP launched this EC2? → CloudTrail knows
```

Useful filters in Event History:
- `ListBuckets` → who listed your S3 buckets
- `DescribeInstances` → who queried your EC2
- `ConsoleLogin` → who logged into the console

---

### 7. Secrets Manager vs Hardcoding

```
❌ Bad:  Hardcode password in Lambda code or EC2 env variable
✅ Good: Store in Secrets Manager → fetch at runtime securely
```

---

## 🛠️ Steps I Performed

### Part A — IAM Security Checks

```bash
# List all IAM users
aws iam list-users --output table

# Check account password policy
aws iam get-account-password-policy
# Output: NoSuchEntity → no custom policy set (normal for beginner labs)

# Check MFA devices
aws iam list-virtual-mfa-devices

# List access keys for devops-user
aws iam list-access-keys \
  --user-name devops-user
```

---

### Part B — MFA Verification

- IAM → Users → `devops-user` → Security credentials
- Multi-factor authentication → Assign MFA device
- Authenticator app (Google Authenticator / Authy)
- Scanned QR code → entered two consecutive codes → MFA enabled ✅

> 💡 MFA = password + authenticator code
> Even if password is leaked, attacker can't login without the second factor!

---

### Part C — Access Key Management

```bash
# List access keys
aws iam list-access-keys \
  --user-name devops-user
```

Shows: active keys, creation dates, status.

```bash
# Delete an unused/old access key
aws iam delete-access-key \
  --user-name devops-user \
  --access-key-id ACCESS_KEY_ID
```

After deletion — verified it worked:
```bash
aws sts get-caller-identity
# Output: InvalidClientTokenId → key successfully deleted ✅
```

> ⚠️ This also meant CLI stopped working until new access key was created!
> Learned: always create new key BEFORE deleting old one.

---

### Part D — CloudTrail Setup

- Created trail: `devops-trail`
- Logs stored in S3 bucket: `aws-cloudtrail-logs-ACCOUNT_ID`
- Checked **Event History** with filters:
  - `ListBuckets` — showed my `aws s3 ls` CLI calls
  - `DescribeInstances` — showed my EC2 queries

✅ Every CLI command I ran appeared in CloudTrail history!

**Cleanup:**
```
CloudTrail → devops-trail → Delete trail
S3 → cloudtrail logs bucket → Empty → Delete
```

---

### Part E — S3 Security Checks

```bash
# Check public access block settings
aws s3api get-public-access-block \
  --bucket devops-day18-pradeep001
```

Output fields:
- `BlockPublicAcls`
- `IgnorePublicAcls`
- `BlockPublicPolicy`
- `RestrictPublicBuckets`

```bash
# Enable full public access block (for non-website buckets)
aws s3api put-public-access-block \
  --bucket devops-day18-pradeep001 \
  --public-access-block-configuration \
  "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

# Check bucket ACL
aws s3api get-bucket-acl \
  --bucket devops-day18-pradeep001

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket devops-day18-pradeep001 \
  --versioning-configuration Status=Enabled

# Verify versioning
aws s3api get-bucket-versioning \
  --bucket devops-day18-pradeep001
```

> 💡 Important: Enabling Block Public Access on the website bucket caused `403 Forbidden`.
> Website buckets need public access — non-website buckets should be private.
> Never apply the same policy blindly to all buckets!

---

### Part F — Secrets Manager

**Created secret:**
- Secret name: `devops/db-credentials`
- Key: `db_password` → Value: `MySecretPassword123!`

```bash
# Retrieve secret via CLI
aws secretsmanager get-secret-value \
  --secret-id devops/db-credentials \
  --region ap-south-1
```

Output:
```json
{
  "db_password": "MySecretPassword123!"
}
```

**Cleanup:**
```bash
aws secretsmanager delete-secret \
  --secret-id devops/db-credentials \
  --force-delete-without-recovery
```

---

### Part G — Additional Security Checks

```bash
# Check VPC Flow Logs
aws ec2 describe-flow-logs --region ap-south-1
# Empty result = no flow logs configured (not an error — just not set up yet)
```

**GuardDuty:**
- Enabled via console → checked findings → suspended trial after lab

---

## 💡 Key Concepts I Understood Today

- Principle of least privilege = give only permissions needed, nothing more
- Root account = never use for daily tasks, always enable MFA
- IAM Roles > IAM Users for AWS services (temporary credentials, auto-rotated)
- CloudTrail = security camera — every API call logged with who/when/where
- `NoSuchEntity` on password policy = no custom policy (not an error)
- `InvalidClientTokenId` = access key deleted/invalid — CLI stops working
- Always create new access key BEFORE deleting old one
- S3 Block Public Access must be OFF for website buckets, ON for all others
- Enabling Block Public Access on a public website bucket causes 403 Forbidden
- S3 versioning = recover deleted/overwritten files — always enable for important buckets
- Secrets Manager = store passwords/API keys securely, never hardcode in code
- GuardDuty = threat detection, finds crypto mining, unusual API calls, port scans
- VPC Flow Logs = empty result just means not configured yet, not an error

---

## ❌ Mistakes I Made (and Learned From)

| Mistake | Error | What I Learned |
|---------|-------|----------------|
| Deleted active access key without creating a new one first | `InvalidClientTokenId` — CLI completely stopped working | Always create new key BEFORE deleting old one. Delete → create order = locked out |
| Enabled Block Public Access on website S3 bucket | `403 Forbidden` on website URL | Website buckets need public read access — Block Public Access must be OFF for them only |
| No custom password policy set | `NoSuchEntity` output | This is not an error — just means no custom policy. Default AWS policy applies |

---

## 🔑 Security Checklist (Real World)

```
IAM:
  ✅ Enable MFA on root + all IAM users
  ✅ Never use root for daily operations
  ✅ Delete unused access keys regularly
  ✅ Apply least privilege to all users/roles

S3:
  ✅ Block Public Access ON (except intentional website buckets)
  ✅ Enable versioning on important buckets
  ✅ Enable access logging
  ✅ Never use wildcard (*) in bucket policies unless required

EC2:
  ✅ Never open SSH to 0.0.0.0/0
  ✅ Use IAM roles — never put access keys on EC2
  ✅ Place databases in private subnets

Secrets:
  ✅ Use Secrets Manager — never hardcode credentials
  ✅ Rotate secrets regularly

Monitoring:
  ✅ Enable CloudTrail in all regions
  ✅ Enable GuardDuty
  ✅ Review CloudTrail event history regularly
```

---

## 📚 Resources I Used Today

- [AWS Security Best Practices](https://docs.aws.amazon.com/wellarchitected/latest/security-pillar/)
- [AWS CloudTrail Docs](https://docs.aws.amazon.com/cloudtrail/)
- [AWS Secrets Manager Docs](https://docs.aws.amazon.com/secretsmanager/)

---

## ✅ Tomorrow → Day 28: Week 4 Review + Polish S3 Project
