# Day 33 — Docker Hub + ECR: Image Registry

![Day](https://img.shields.io/badge/Day-33-yellow?style=flat-square)
![Topic](https://img.shields.io/badge/Topic-Docker%20Hub%20%2B%20Amazon%20ECR-orange?style=flat-square)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen?style=flat-square)

> 📅 Date: May 11, 2026
> ⏱️ Time Spent: 3+ hrs
> 🎯 Goal: Push images to Docker Hub and Amazon ECR, understand registry workflows, authenticate Docker with AWS, and manage image lifecycle policies

---

## 📌 What I Learned Today

### 1. What Problem Does a Registry Solve?

**Without a registry:**
```
Image lives only on YOUR laptop 💻
→ Can't deploy to EC2
→ Can't share with teammates
→ Can't pull into Kubernetes
```

**With a registry:**
```
Your laptop → push → Registry (Docker Hub / ECR)
                           ↓
              EC2 / K8s / teammate → pull ✅
```

> 💡 A registry is like GitHub but for Docker images.
> GitHub stores code. Registry stores container images!

---

### 2. Image Naming Convention

```
REGISTRY/USERNAME/IMAGE_NAME:TAG

Docker Hub: silosw369/devops-app:v3
ECR:        173194475741.dkr.ecr.ap-south-1.amazonaws.com/devops-app:v3
```

---

### 3. Registry Workflow

```
Build → Tag → Login → Push → Pull
```

---

### 4. Docker Tags — Critical Concept

```
Multiple tags can point to the SAME image (same IMAGE ID)
Removing a tag ≠ deleting the image
Image is only deleted when ALL tags/references are removed
```

```bash
docker tag devops-app:v3 silosw369/devops-app:v3
docker tag devops-app:v3 silosw369/devops-app:latest
# Both tags → same IMAGE ID → no data duplication!
```

---

### 5. Docker Hub vs ECR

| | Docker Hub | Amazon ECR |
|--|-----------|-----------|
| Type | Public / Private | Private only |
| Auth | Username + Password | AWS IAM + temp token |
| Free tier | Free public repos | 500MB free/month |
| Layer sharing | Global (official images) | Private (no global sharing) |
| Best for | Open source, sharing | AWS deployments (ECS, EKS) |
| Vulnerability scan | Paid | ✅ Built-in free |

---

### 6. ECR Authentication

ECR uses **temporary tokens** — not username/password like Docker Hub:

```bash
aws ecr get-login-password | docker login --username AWS --password-stdin ECR_URI
```

> 💡 Token expires after 12 hours — in CI/CD pipelines, auth is run
> before every push automatically!

---

## 🛠️ Steps I Performed

### Part A — Docker Hub

#### Step 1 — Login

```bash
docker login
# Authenticated via browser-based login ✅
```

#### Step 2 — Tagged Image

```bash
docker tag devops-app:v3 silosw369/devops-app:v3
docker tag devops-app:v3 silosw369/devops-app:latest

# Verify — same IMAGE ID for both tags
docker images
```

#### Step 3 — Pushed to Docker Hub

```bash
docker push silosw369/devops-app:v3
docker push silosw369/devops-app:latest
```

✅ Verified on hub.docker.com — repository visible with both tags!

#### Step 4 — Removed Local Tags

```bash
docker rmi silosw369/devops-app:v3
docker rmi silosw369/devops-app:latest
```

Observed: only tags removed — original `devops-app:v3` image still existed!

#### Step 5 — Pulled Back from Docker Hub

```bash
docker pull silosw369/devops-app:v3
```

✅ Restored successfully — Docker used digests/layers, didn't fully re-download!

---

### Part B — Amazon ECR

#### Step 1 — Verified AWS CLI

```bash
aws --version
aws configure   # configured Access Key, Secret Key, region, output
```

#### Step 2 — Verified Identity

```bash
aws sts get-caller-identity
```

✅ Confirmed: `devops-user`, account `173194475741`

#### Step 3 — Created ECR Repository

```bash
aws ecr create-repository \
  --repository-name devops-app \
  --region ap-south-1
```

Repository URI created:
```
173194475741.dkr.ecr.ap-south-1.amazonaws.com/devops-app
```

#### Step 4 — Authenticated Docker to ECR

```bash
aws ecr get-login-password --region ap-south-1 | \
  docker login --username AWS \
  --password-stdin \
  173194475741.dkr.ecr.ap-south-1.amazonaws.com
```

Output: `Login Succeeded` ✅

#### Step 5 — Tagged Image for ECR

```bash
docker tag devops-app:v3 \
  173194475741.dkr.ecr.ap-south-1.amazonaws.com/devops-app:v3

# Verify — same IMAGE ID reused
docker images
```

#### Step 6 — Pushed to ECR

```bash
docker push \
  173194475741.dkr.ecr.ap-south-1.amazonaws.com/devops-app:v3
```

✅ Verified in AWS Console → ECR → devops-app → image tag v3, digest, size all visible!

#### Step 7 — Pulled Back from ECR

```bash
# Remove local ECR tag first
docker rmi 173194475741.dkr.ecr.ap-south-1.amazonaws.com/devops-app:v3

# Pull from ECR
docker pull 173194475741.dkr.ecr.ap-south-1.amazonaws.com/devops-app:v3
```

✅ Restored successfully — ECR pull authentication working!

---

### Part C — ECR CLI Commands

```bash
# List all repositories
aws ecr describe-repositories --region ap-south-1

# List images in repo
aws ecr list-images \
  --repository-name devops-app \
  --region ap-south-1

# Describe images (size, push date, last pull)
aws ecr describe-images \
  --repository-name devops-app \
  --region ap-south-1
```

---

### Part D — Lifecycle Policy

```bash
aws ecr put-lifecycle-policy \
  --repository-name devops-app \
  --lifecycle-policy-text '{
    "rules": [
      {
        "rulePriority": 1,
        "description": "Keep last 5 images",
        "selection": {
          "tagStatus": "any",
          "countType": "imageCountMoreThan",
          "countNumber": 5
        },
        "action": {
          "type": "expire"
        }
      }
    ]
  }' \
  --region ap-south-1
```

> 💡 In real CI/CD — every push creates a new image.
> Without lifecycle policies → hundreds of old images → unexpected AWS bill!

---

### Cleanup

```bash
# Delete ECR repository
aws ecr delete-repository \
  --repository-name devops-app \
  --force \
  --region ap-south-1

# Remove local ECR tags
docker rmi 173194475741.dkr.ecr.ap-south-1.amazonaws.com/devops-app:v3

# Remove Docker Hub tags
docker rmi silosw369/devops-app:v3
docker rmi silosw369/devops-app:latest
```

---

## 💡 Key Concepts I Understood Today

- Registry = remote storage for Docker images (like GitHub for code)
- Tags are references — same IMAGE ID can have multiple tags
- Removing a tag ≠ deleting image — image deleted only when all tags removed
- Docker Hub = public/private, manual login, great for sharing/open source
- ECR = AWS private, IAM-based, perfect for ECS/EKS CI/CD workflows
- ECR uses temporary tokens (12hr expiry) — not username/password
- ECR layers are private — no global sharing like Docker Hub official images
- `aws sts get-caller-identity` = quickest way to verify AWS CLI auth
- Lifecycle policies = auto-cleanup old images → prevents storage cost buildup
- `docker pull` uses digests — only downloads changed layers, not full image

---

## ❌ Mistakes I Made (and Learned From)

| Mistake | Error | What I Learned |
|---------|-------|----------------|
| Typed invalid characters in AWS Access Key | `The security token included in the request is invalid` | Always paste credentials carefully — one wrong character breaks auth. Use `aws sts get-caller-identity` to verify |
| Thought removing a tag deletes the image | Image still existed after `docker rmi tag` | Docker only deletes image data when ALL references/tags are removed |
| Expected ECR to share layers like Docker Hub | Layers not shared globally | ECR is private — repositories don't share layers across accounts like Docker Hub official images do |

---

## 🔄 Full Registry Workflow Practiced

```
devops-app:v3 (local)
      ↓
docker tag → silosw369/devops-app:v3
      ↓
docker push → Docker Hub ✅
      ↓
docker pull → restored from Docker Hub ✅

devops-app:v3 (local)
      ↓
docker tag → 173194475741.dkr.ecr.ap-south-1.amazonaws.com/devops-app:v3
      ↓
aws ecr get-login-password | docker login
      ↓
docker push → Amazon ECR ✅
      ↓
docker pull → restored from ECR ✅
```

---

## 📚 Resources I Used Today

- [Docker Hub Docs](https://docs.docker.com/docker-hub/)
- [Amazon ECR Docs](https://docs.aws.amazon.com/ecr/)

---

## ✅ Week 5 Complete!

| Day | Topic | Status |
|-----|-------|--------|
| Day 29 | Docker — Images, Containers, Volumes | ✅ |
| Day 30 | Dockerfile — Writing & Building | ✅ |
| Day 31 | Docker Volumes & Networks | ✅ |
| Day 32 | Docker Compose | ✅ |
| Day 33 | Docker Hub + ECR | ✅ |

---

## ✅ Tomorrow → Day 34: Kubernetes — Architecture & Core Concepts
