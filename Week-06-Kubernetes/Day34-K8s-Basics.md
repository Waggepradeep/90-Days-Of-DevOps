# Day 34 — Kubernetes: Architecture & Core Concepts

![Day](https://img.shields.io/badge/Day-34-yellow?style=flat-square)
![Topic](https://img.shields.io/badge/Topic-Kubernetes%20Basics-orange?style=flat-square)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen?style=flat-square)

> 📅 Date: May 11, 2026
> ⏱️ Time Spent: 3+ hrs
> 🎯 Goal: Install kubectl + Minikube, understand K8s architecture, run pods, deployments, services, and namespaces on a local cluster

---

## 📌 What I Learned Today

### 1. Why Kubernetes After Docker?

**Docker Compose → good for 1 server, 2-3 containers**
**Production → 50 containers, 10 servers:**

```
Container crashes at 3 AM → who restarts it? 😴
Traffic spikes            → who adds containers? 😰
Server dies               → who moves containers? 💀
```

**Kubernetes solves all of this automatically:**
```
Container crashes → K8s restarts instantly        ✅
Traffic spikes    → K8s scales up containers      ✅
Server dies       → K8s moves to healthy server   ✅
```

> 💡 Docker runs containers. Kubernetes manages thousands of them at scale!

---

### 2. Cluster Architecture

```
Kubernetes Cluster
├── Control Plane (brain)
│     ├── API Server       → entry point for all kubectl commands
│     ├── etcd             → database storing all cluster state
│     ├── Scheduler        → decides which node runs which pod
│     └── Controller Mgr   → watches cluster, fixes drift
└── Worker Nodes (muscle)
      ├── kubelet          → agent, talks to API server
      ├── kube-proxy       → handles networking
      └── Container Runtime → actually runs containers
```

---

### 3. Kubernetes Object Hierarchy

```
Deployment
    ↓
ReplicaSet
    ↓
Pods
    ↓
Containers
```

And separately:
```
Service → routes traffic to → Pods
```

---

### 4. Key Kubernetes Objects

| Object | Purpose |
|--------|---------|
| **Pod** | Smallest unit — wraps container(s) |
| **Deployment** | Manages pods — desired state, self-healing, scaling |
| **ReplicaSet** | Ensures N replicas of a pod always run |
| **Service** | Stable network endpoint for pods |
| **Namespace** | Virtual cluster — isolate resources logically |

---

### 5. Desired State Model (Most Important!)

```
You tell K8s: "I want 3 replicas"
K8s watches constantly (reconciliation loop)
1 pod crashes → K8s sees 2 → launches 1 more → back to 3 ✅
```

> 💡 K8s never "runs commands" — it continuously reconciles
> actual state to your desired state. This is the core K8s philosophy!

---

### 6. Standalone Pod vs Deployment

| | Standalone Pod | Deployment |
|--|---------------|------------|
| Self-healing | ❌ Deleted = gone forever | ✅ Auto-recreated |
| Scaling | ❌ Manual | ✅ `--replicas=N` |
| Rolling updates | ❌ No | ✅ Yes |
| Use in production | ❌ Never | ✅ Always |

---

### 7. Service Types

| Type | Purpose |
|------|---------|
| **ClusterIP** | Internal only — pods talk to each other |
| **NodePort** | Exposes app on node's IP + port (external access) |
| **LoadBalancer** | Cloud load balancer (AWS ALB etc.) |

---

## 🛠️ Steps I Performed

### Part A — Setup

**Install kubectl:**
```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s \
  https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client
```

**Install Minikube:**
```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
minikube version
```

---

### Part B — Start Cluster

```bash
# Start with Docker as driver
minikube start --driver=docker

# Verify
kubectl get nodes       # 1 node → Ready ✅
kubectl cluster-info    # API server + DNS
minikube status         # all components running
```

---

### Part C — Pods

```bash
# Create standalone nginx pod
kubectl run nginx-pod --image=nginx

# Check status
kubectl get pods
kubectl get pods -o wide    # shows which node pod is on

# Detailed info + events
kubectl describe pod nginx-pod

# View logs
kubectl logs nginx-pod

# Execute inside pod (like docker exec)
kubectl exec -it nginx-pod -- bash
```

Inside pod:
```bash
ls
nginx -v
ls /usr/share/nginx/html
cat /etc/nginx/nginx.conf
exit
```

```bash
# Delete standalone pod
kubectl delete pod nginx-pod

# Check — pod is gone, NOT recreated ❌
kubectl get pods
```

> 💡 Standalone pods are NOT self-healing — delete = gone forever.
> Always use Deployments in practice!

---

### Part D — Deployments

```bash
# Create deployment
kubectl create deployment nginx-deployment --image=nginx

# Verify
kubectl get deployments
kubectl get pods        # pod name has random suffix (dynamic)
```

**Self-healing test:**
```bash
# Delete a pod manually
kubectl delete pod <pod-name>

# Watch K8s recreate it automatically
kubectl get pods
```
✅ Pod recreated instantly — desired state reconciliation working!

**Scaling:**
```bash
kubectl scale deployment nginx-deployment --replicas=3

# Verify 3 pods running
kubectl get pods
kubectl get deployments
```
✅ 3 pods running — horizontal scaling works!

---

### Part E — Services

```bash
# Expose deployment via NodePort
kubectl expose deployment nginx-deployment \
  --type=NodePort \
  --port=80

# Check service
kubectl get services

# Open in browser via Minikube
minikube service nginx-deployment
```

✅ Browser opened → Nginx welcome page accessible from outside cluster!

---

### Part F — Namespaces

```bash
# View default namespaces
kubectl get namespaces
# default, kube-system, kube-public, kube-node-lease
```

**kube-system** = K8s internal components (API server, scheduler etc.)

```bash
# See system pods
kubectl get pods -n kube-system

# Create custom namespace
kubectl create namespace dev

# Deploy app inside namespace
kubectl create deployment nginx-dev --image=nginx -n dev

# Verify
kubectl get deployments -n dev
kubectl get pods -n dev

# View everything across all namespaces
kubectl get all --all-namespaces
```

---

### Part G — Cleanup

```bash
kubectl delete deployment nginx-deployment
kubectl delete deployment nginx-dev -n dev
kubectl delete service nginx-deployment
kubectl delete namespace dev   # deletes everything inside!

minikube stop    # pause cluster (keeps data)
# minikube delete  # remove cluster entirely
```

---

## 💡 Key Concepts I Understood Today

- Kubernetes = container orchestration — manages containers at scale
- Cluster = control plane (brain) + worker nodes (muscle)
- Pod = smallest K8s unit — wraps one or more containers
- Deployment = manages pods with self-healing + scaling + rolling updates
- ReplicaSet = created by Deployment — ensures N pods always running
- Service = stable network endpoint for pods (pods have dynamic IPs)
- NodePort = exposes service externally on node's IP + port
- Namespace = logical isolation — use for dev/staging/prod separation
- Standalone pod deleted = gone. Deployment pod deleted = auto-recreated
- `kubectl describe` = most useful debugging command in K8s
- Dynamic pod names = deployment name + random suffix (e.g. `nginx-deployment-abc123`)
- `minikube stop` = pause, `minikube delete` = remove entirely
- kube-system namespace = K8s internal components — never touch manually

---

## ❌ Mistakes I Made (and Learned From)

| Mistake | Error | What I Learned |
|---------|-------|----------------|
| Ran `docker run nginx` in foreground | Terminal appeared stuck | `nginx` runs as foreground process — always use `-d` flag for detached mode |
| Used deployment name in `kubectl get pod` | Pod not found | Deployments generate dynamic pod names — use `kubectl get pods` first to get actual name |
| Forgot `-n <namespace>` flag | Resources not found | All resources belong to a namespace — always specify with `-n` when not using default |

---

## 📚 kubectl Quick Reference

```bash
# Get resources
kubectl get pods / nodes / services / deployments / all

# Detailed info
kubectl describe pod <name>

# Logs
kubectl logs <pod-name>

# Execute inside pod
kubectl exec -it <pod-name> -- bash

# Scale
kubectl scale deployment <name> --replicas=N

# Delete
kubectl delete pod/deployment/service/namespace <name>

# Apply from file
kubectl apply -f file.yaml

# All namespaces
kubectl get pods --all-namespaces
kubectl get all --all-namespaces
```

---

## 📚 Resources I Used Today

- [Kubernetes Docs](https://kubernetes.io/docs/home/)
- [Minikube Docs](https://minikube.sigs.k8s.io/docs/)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)

---

## ✅ Tomorrow → Day 35: Kubernetes — Pods, Deployments & ReplicaSets
