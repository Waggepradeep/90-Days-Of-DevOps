# Day 41 — Kubernetes on AWS: EKS Overview

![Day](https://img.shields.io/badge/Day-41-yellow?style=flat-square)
![Topic](https://img.shields.io/badge/Topic-AWS%20EKS-orange?style=flat-square)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen?style=flat-square)

> 📅 Date: May 11, 2026
> ⏱️ Time Spent: 3+ hrs
> 🎯 Goal: Deploy a managed Kubernetes cluster on AWS EKS using eksctl, run real workloads, expose via AWS LoadBalancer, scale nodegroups, and perform rolling updates

---

## 📌 What I Learned Today

### 1. What is EKS?

**Self-managed K8s on EC2:**
```
You manage: control plane, etcd, upgrades, HA, certificates, networking
= 6+ EC2 instances just for control plane 😰
```

**Amazon EKS:**
```
AWS manages: control plane, etcd, upgrades, certificates, HA
You manage:  worker nodes + your applications ✅
```

> 💡 EKS = managed Kubernetes on AWS.
> AWS runs the control plane — you just deploy your apps!

---

### 2. EKS Architecture

```
kubectl (your terminal)
        ↓
EKS Control Plane (AWS Managed — multi-AZ, HA)
├── API Server
├── etcd
└── Scheduler + Controller Manager
        ↓
Worker Nodes (EC2 instances)
        ↓
Pods / Deployments / Services
```

---

### 3. Tools Used

| Tool | Purpose |
|------|---------|
| AWS CLI | Connect to AWS |
| eksctl | Create/manage EKS clusters |
| kubectl | Manage Kubernetes resources |
| CloudFormation | AWS infrastructure provisioning (auto-used by eksctl) |

---

### 4. EKS vs Minikube

| | Minikube | EKS |
|--|---------|-----|
| Purpose | Local dev/learning | Production |
| Nodes | 1 (your laptop) | Multiple EC2s |
| Control plane | You manage | AWS manages |
| HA | ❌ No | ✅ Multi-AZ |
| Cost | Free | ~$0.10/hr + EC2 |
| LoadBalancer | ❌ Simulated | ✅ Real AWS ELB |

---

### 5. `type: LoadBalancer` on EKS

```
kubectl apply service with type: LoadBalancer
        ↓
EKS automatically provisions AWS ELB
        ↓
EXTERNAL-IP = *.ap-south-1.elb.amazonaws.com
        ↓
Real public internet access! ✅
```

---

## 🛠️ Steps I Performed

### Part A — Installed eksctl

```bash
curl --silent --location \
  "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" \
  | tar xz -C /tmp

sudo mv /tmp/eksctl /usr/local/bin

eksctl version
# 0.226.0 ✅
```

---

### Part B — Fixed AWS Credentials

```bash
aws --version

# Initially got:
# InvalidClientTokenId ← wrong credentials!

# Fixed:
aws configure

# Verified:
aws sts get-caller-identity
# arn:aws:iam::173194475741:user/devops-user ✅
```

---

### Part C — Created EKS Cluster

**First attempt with t3.medium failed** → nodegroup provisioning limits.

Cleaned failed cluster:
```bash
eksctl delete cluster \
  --name devops-cluster \
  --region ap-south-1
```

**Successful creation with lighter config:**
```bash
eksctl create cluster \
  --name devops-cluster \
  --region ap-south-1 \
  --nodegroup-name linux-nodes \
  --node-type t3.small \
  --nodes 1
```

eksctl automatically created:
- VPC, subnets, security groups
- IAM roles
- EKS control plane
- EC2 worker node
- CloudFormation stacks

---

### Part D — Verified Cluster

```bash
kubectl get nodes
# 1 node → Ready ✅

kubectl get pods -A
```

System pods observed:

| Pod | Purpose |
|-----|---------|
| coredns | Cluster DNS |
| kube-proxy | Service networking |
| aws-node | VPC CNI networking |
| metrics-server | Metrics collection |

---

### Part E — Deployed Application

**Quick deploy:**
```bash
kubectl create deployment nginx-demo --image=nginx

kubectl expose deployment nginx-demo \
  --port=80 \
  --type=LoadBalancer
```

K8s automatically triggered AWS ELB creation!

```bash
kubectl get svc
# TYPE: LoadBalancer
# EXTERNAL-IP: *.ap-south-1.elb.amazonaws.com ✅

curl http://<ELB-DNS>
# nginx HTML page ✅
```

**Scale:**
```bash
kubectl scale deployment nginx-demo --replicas=3
kubectl get pods   # 3 running ✅
```

---

### Part F — YAML-Based Deployment

**`deployment.yaml`:**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: devops-web
spec:
  replicas: 3
  selector:
    matchLabels:
      app: devops-web
  template:
    metadata:
      labels:
        app: devops-web
    spec:
      containers:
      - name: web
        image: nginx:1.25
        ports:
        - containerPort: 80
```

**`service.yaml`:**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: devops-web-service
spec:
  type: LoadBalancer
  selector:
    app: devops-web
  ports:
  - port: 80
    targetPort: 80
```

```bash
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl get svc --watch   # wait for EXTERNAL-IP
```

---

### Part G — Nodegroup Scaling

One pod went **Pending** — not enough resources on single node.

```bash
eksctl get nodegroup \
  --cluster devops-cluster \
  --region ap-south-1
```

**First scaling attempt failed:**
```
desired capacity 2 can't be greater than max size 1
```

**Fixed — increase max size too:**
```bash
eksctl scale nodegroup \
  --cluster devops-cluster \
  --name linux-nodes \
  --nodes 2 \
  --nodes-max 2 \
  --region ap-south-1
```

Watched new node join:
```bash
kubectl get nodes --watch
# NotReady → Ready ✅
```

After second node joined → pending pod automatically scheduled → all pods Running! ✅

---

### Part H — Rolling Update

```bash
kubectl set image deployment/devops-web \
  web=nginx:1.26

kubectl rollout status deployment/devops-web
```

Observed:
- New ReplicaSet created
- Gradual pod replacement
- Zero downtime rollout ✅

```bash
kubectl describe deployment devops-web
# StrategyType: RollingUpdate ✅
```

---

### Cleanup (Critical!)

```bash
# Delete K8s resources FIRST (ELB must be released before cluster delete!)
kubectl delete -f deployment.yaml
kubectl delete -f service.yaml
kubectl delete deployment nginx-demo
kubectl delete service nginx-demo

# Wait ~2 minutes for ELB to be released
# THEN delete cluster
eksctl delete cluster \
  --name devops-cluster \
  --region ap-south-1

# Verify
eksctl get cluster --region ap-south-1
# No clusters found ✅
```

---

## 💡 Key Concepts I Understood Today

- EKS = AWS manages control plane — you manage worker nodes + apps
- eksctl = simplest way to create/manage EKS clusters (one command!)
- `type: LoadBalancer` on EKS = automatically provisions real AWS ELB
- eksctl uses CloudFormation stacks under the hood
- `aws-node` pod = AWS VPC CNI — gives pods real VPC IPs
- Pending pod = scheduler can't place pod — usually insufficient node resources
- Nodegroup max size must be increased BEFORE scaling beyond original max
- Always delete K8s LoadBalancer services BEFORE deleting the cluster — otherwise ELB orphans and keeps charging!
- `aws sts get-caller-identity` = quickest way to verify AWS CLI auth
- Rolling updates work identically on EKS as on Minikube — same kubectl commands!

---

## ❌ Mistakes I Made (and Learned From)

| Mistake | Error | What I Learned |
|---------|-------|----------------|
| Configured wrong AWS credentials | `InvalidClientTokenId` | Always verify with `aws sts get-caller-identity` after `aws configure` |
| Used `t3.medium` on first attempt | Nodegroup provisioning failed | Start with `t3.small` + 1 node for learning — scale up only when needed |
| Tried scaling nodes without increasing max | `desired capacity 2 can't be greater than max size 1` | Must set `--nodes-max` to at least equal to desired node count |

---

## 📚 eksctl Reference

```bash
# Create cluster
eksctl create cluster --name <name> --region <region> \
  --nodegroup-name <ng-name> --node-type t3.small --nodes 1

# Get clusters
eksctl get cluster --region <region>

# Get nodegroups
eksctl get nodegroup --cluster <name> --region <region>

# Scale nodegroup
eksctl scale nodegroup --cluster <name> --name <ng-name> \
  --nodes N --nodes-max N --region <region>

# Delete cluster
eksctl delete cluster --name <name> --region <region>
```

---

## 📚 Resources I Used Today

- [EKS Official Docs](https://docs.aws.amazon.com/eks/)
- [eksctl Docs](https://eksctl.io/)

---

## ✅ Tomorrow → Day 42: Project 2 — Containerized Microservice on Kubernetes
