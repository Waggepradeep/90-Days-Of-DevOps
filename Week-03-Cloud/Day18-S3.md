# Day 18 — AWS S3: Buckets, Policies & Static Website Hosting

![Day](https://img.shields.io/badge/Day-18-yellow?style=flat-square)
![Topic](https://img.shields.io/badge/Topic-AWS%20S3-orange?style=flat-square)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen?style=flat-square)

> 📅 Date: April 08, 2026
> ⏱️ Time Spent: 3+ hrs
> 🎯 Goal: Create an S3 bucket, upload a static website, configure public access policy, and host a live webpage — no server needed!

---

## 📌 What I Learned Today

### 1. What is S3?

**S3 (Simple Storage Service)** is AWS's object storage service — like Google Drive but built for developers and applications, with virtually unlimited storage.

**Without S3:**
```
Static website needs a server (EC2) → costs money, needs maintenance
```

**With S3:**
```
Upload HTML/CSS/JS → S3 serves it directly → no server needed! ✅
```

> 💡 Think of S3 like a USB drive in the cloud — store anything,
> access it from anywhere, and optionally share it with the whole world!

---

### 2. Key S3 Concepts

#### Buckets
A **container** that holds your files — like a folder at the top level.
- Name must be **globally unique** across ALL AWS accounts worldwide
- Must be **lowercase**, no spaces, no underscores
- You choose a region when creating it

#### Objects
Everything stored in S3 is an **object** — file + metadata.
- Max size per object: 5 TB
- No limit on number of objects

#### S3 Storage Structure
```
S3
└── devops-day18-pradeep001/     ← Bucket
    ├── index.html                ← Object
    ├── style.css                 ← Object
    └── images/
        └── logo.png              ← Object
```

#### Bucket Policy
A **JSON rule** that controls who can access your bucket and objects.

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::devops-day18-pradeep001/*"
        }
    ]
}
```

**Breaking it down:**

| Field | Value | Meaning |
|-------|-------|---------|
| `Effect` | `Allow` | Permit this action |
| `Principal` | `*` | Everyone (public) |
| `Action` | `s3:GetObject` | Read/download files |
| `Resource` | `arn:aws:s3:::bucket/*` | All objects in the bucket |

#### Static Website Hosting
S3 can serve HTML/CSS/JS files directly as a website — **no EC2 needed!**
- Website endpoint format: `http://bucket-name.s3-website.ap-south-1.amazonaws.com`
- Perfect for portfolios, landing pages, documentation

---

### 3. S3 vs EC2 for Hosting

| | S3 Static Hosting | EC2 + Nginx |
|--|-------------------|-------------|
| Server needed | ❌ No | ✅ Yes |
| Cost | Very cheap | More expensive |
| Use case | HTML/CSS/JS only | Full apps, APIs, backends |
| Setup time | 5 minutes | 30+ minutes |
| Scales automatically | ✅ Yes | ❌ Manual |

---

### 4. What I Did Step by Step

#### Step 1 — Created S3 Bucket
- **Bucket name:** `devops-day18-pradeep001`
- **Region:** Asia Pacific — Mumbai (ap-south-1)
- **Block all public access:** ❌ Disabled (needed for public website)
- Checked the acknowledgement box → Created bucket

#### Step 2 — Created and Uploaded index.html

```bash
mkdir ~/day18-website
cd ~/day18-website
nano index.html
```

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>DevOps Day 18</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: #0f172a;
            color: #e2e8f0;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
        }
        .card {
            text-align: center;
            padding: 40px;
            border: 1px solid #334155;
            border-radius: 12px;
            background: #1e293b;
        }
        h1 { color: #38bdf8; }
        p { color: #94a3b8; }
    </style>
</head>
<body>
    <div class="card">
        <h1>🚀 Day 18 — S3 Static Website</h1>
        <p>Hosted on AWS S3 by Pradeep</p>
        <p>90 Days of DevOps Journey</p>
    </div>
</body>
</html>
```

Uploaded via AWS Console → S3 bucket → Upload → Add files

#### Step 3 — Enabled Static Website Hosting
- Bucket → **Properties** tab → Static website hosting → Edit
- Enabled: ✅
- Hosting type: Host a static website
- Index document: `index.html`
- Saved → copied the **Bucket website endpoint** URL

#### Step 4 — Added Bucket Policy

- Bucket → **Permissions** tab → Bucket policy → Edit
- Pasted the public read policy (see above)
- Saved changes

#### Step 5 — Accessed the Website

Opened browser → visited:
```
http://devops-day18-pradeep001.s3-website.ap-south-1.amazonaws.com
```

**Website loaded successfully!** 🎉

---

### 5. Important S3 Security Notes

> ⚠️ "Block all public access" is ON by default — AWS protects you from accidentally making data public.
> We turned it OFF only because we intentionally want a public website.

**Real world rules:**
| Bucket Type | Block Public Access | Bucket Policy |
|-------------|-------------------|---------------|
| Public website | ❌ Off | Allow `s3:GetObject` for `*` |
| Private app data | ✅ On | No public policy |
| Logs/backups | ✅ On | No public policy |

---

## 💡 Key Concepts I Understood Today

- S3 = object storage — store any file, any size, from anywhere
- Bucket = container for objects (globally unique name required)
- Object = any file stored in S3 (max 5TB per object)
- Bucket policy = JSON rules controlling access
- Static website hosting = S3 serves HTML/CSS/JS directly, no server needed
- `Principal: "*"` = allow everyone (public access)
- `Action: s3:GetObject` = allow reading/downloading files
- Always disable "Block public access" before adding public bucket policy
- Website endpoint format: `bucket-name.s3-website.region.amazonaws.com`
- S3 is much cheaper and simpler than EC2 for static sites

---

## ❌ Mistakes to Avoid

| Mistake | Error | What to Remember |
|---------|-------|-----------------|
| Forgetting to disable "Block all public access" | Policy save fails | Must uncheck + acknowledge before adding public policy |
| Wrong bucket name in policy ARN | 403 Forbidden | Double check `arn:aws:s3:::bucket-name/*` matches exactly |
| Using S3 for dynamic apps | Won't work | S3 hosts static files only — use EC2 for backends/APIs |

---

## 📚 Resources I Used Today

- [AWS S3 Docs](https://docs.aws.amazon.com/s3/)
- [S3 Static Website Hosting Guide](https://docs.aws.amazon.com/AmazonS3/latest/userguide/WebsiteHosting.html)

---

## ✅ Tomorrow → Day 19: VPC — Subnets, Route Tables, Internet Gateway
