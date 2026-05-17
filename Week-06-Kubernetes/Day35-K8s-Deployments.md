# Day 35 — Kubernetes: YAML Manifests, Deployments & Rollbacks

![Day](https://img.shields.io/badge/Day-35-yellow?style=flat-square)
![Topic](https://img.shields.io/badge/Topic-K8s%20Deployments%20%2B%20Rollbacks-orange?style=flat-square)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen?style=flat-square)

> 📅 Date: May 11, 2026
> ⏱️ Time Spent: 3+ hrs
> 🎯 Goal: Write declarative YAML manifests for Pods, Deployments, and Services — perform rolling updates, scale deployments, and roll back to previous versions

---

## 📌 What I Learned Today

### 1. Imperative vs Declarative

```
Day 34 (Imperative):
kubectl create deployment nginx --image=nginx  ← tell K8s HOW to do it

Day 35 (Declarative):
kubectl apply -f deployment.yaml               ← tell K8s WHAT you want ✅
```

> 💡 Every real DevOps team uses YAML manifests — not kubectl create commands!
> YAML is version-controllable, reproducible, and shareable with the team.

---

### 2. YAML Manifest Structure

Every K8s object has 4 top-level fields:

```yaml
apiVersion: apps/v1    # which API version handles this object
kind: Deployment       # what type of object
metadata:              # name, labels, namespace
  name: my-app
spec:                  # desired state — what you want
  replicas: 3
  ...
```

---

### 3. Resource Requests vs Limits

```yaml
resources:
  requests:
    memory: "64Mi"   # guaranteed minimum — scheduler uses this
    cpu: "250m"      # 250 millicores = 0.25 CPU core
  limits:
    memory: "128Mi"  # maximum — K8s kills container if exceeded
    cpu: "500m"
```

```
requests → minimum guaranteed (used by scheduler to place pod on node)
limits   → maximum allowed (container killed/throttled if exceeded)
```

---

### 4. Kubernetes Object Hierarchy

```
Deployment
    ↓ manages
ReplicaSet
    ↓ manages
Pods
    ↓ contains
Containers
```

And separately:
```
Service → selects Pods via labels → routes traffic
```

---

### 5. Standalone Pod vs Deployment

| | Standalone Pod | Deployment |
|--|---------------|------------|
| Self-healing | ❌ Delete = gone | ✅ Auto-recreated |
| Scaling | ❌ Manual | ✅ `replicas: N` |
| Rolling updates | ❌ No | ✅ Zero downtime |
| Rollback | ❌ No | ✅ `kubectl rollout undo` |
| Production use | ❌ Never | ✅ Always |

---

### 6. Rolling Update — How It Works

```
Old: RS1 (v1 v1 v1)
Update starts → new RS2 created:
  RS2 (v2) + RS1 (v1 v1)   → 1 new up, 1 old down
  RS2 (v2 v2) + RS1 (v1)   → 2 new up, 2 old down
  RS2 (v2 v2 v2) + RS1 ()  → all updated, zero downtime! ✅
```

> 💡 Deployments NEVER update pods directly!
> Every rollout creates a NEW ReplicaSet — old RS scales down, new RS scales up.

---

### 7. Rollback Creates New Revision

```
Revision 1 → nginx:1.25 (initial)
Revision 2 → nginx:1.26 (update)
Revision 3 → nginx:1.25 (rollback ← this is a NEW revision, not going back!)
```

---

### 8. Labels & Selectors

Services find pods using **label selectors** — not names or IPs:

```yaml
# Deployment pod has label:
labels:
  app: nginx

# Service selector matches:
selector:
  app: nginx   ← finds all pods with this label automatically
```

---

## 🛠️ Steps I Performed

### Setup

```bash
minikube start --driver=docker
kubectl get nodes   # 1 node → Ready ✅

mkdir ~/day35-K8s
cd ~/day35-K8s
```

---

### Part A — Pod via YAML

**`pod.yaml`:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: devops-pod
  labels:
    app: devops
    env: learning
spec:
  containers:
  - name: nginx
    image: nginx:1.25
    ports:
    - containerPort: 80
    resources:
      requests:
        memory: "64Mi"
        cpu: "250m"
      limits:
        memory: "128Mi"
        cpu: "500m"
```

```bash
kubectl apply -f pod.yaml

kubectl get pods
kubectl get pods --show-labels   # app=devops, env=learning ✅
kubectl describe pod devops-pod  # events, scheduling, resources
kubectl logs devops-pod
kubectl get pod devops-pod -o yaml  # full internal state K8s stores
```

Observed from `describe`:
- Pod lifecycle events (Scheduled → Pulling → Running)
- Resource limits and QoS class
- Node assignment and IP

---

### Part B — Deployment via YAML

**`deployment.yaml`:**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: devops-deployment
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.25
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "64Mi"
            cpu: "250m"
          limits:
            memory: "128Mi"
            cpu: "500m"
```

```bash
kubectl apply -f deployment.yaml

kubectl get deployments
kubectl get replicasets
kubectl get pods
kubectl get all
```

✅ All 3 created automatically: Deployment → ReplicaSet → 3 Pods

---

### Part C — Service via YAML

**`service.yaml`:**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: devops-service
spec:
  type: NodePort
  selector:
    app: nginx
  ports:
  - port: 80
    targetPort: 80
```

```bash
kubectl apply -f service.yaml
kubectl get services

# Open in browser
minikube service devops-service
```

✅ Browser opened → Nginx accessible from outside cluster!

Traffic flow:
```
Browser → NodePort Service → Deployment → Pods
```

---

### Part D — Scaling

Updated `deployment.yaml`: changed `replicas: 3` → `replicas: 5`

```bash
kubectl apply -f deployment.yaml

kubectl get deployments   # DESIRED=5
kubectl get pods          # 5 pods running ✅
```

K8s reconciled automatically — ReplicaSet added 2 more pods!

---

### Part E — Rolling Update

Updated `deployment.yaml`: changed `image: nginx:1.25` → `image: nginx:1.26`

```bash
kubectl apply -f deployment.yaml

# Watch live
kubectl rollout status deployment/devops-deployment
kubectl get pods -w
```

Observed two ReplicaSets during transition:
```
devops-deployment-569f95f5cb  ← old RS (nginx:1.25) scaling down
devops-deployment-8574879789  ← new RS (nginx:1.26) scaling up
```

```bash
# View rollout history
kubectl rollout history deployment/devops-deployment
kubectl rollout history deployment/devops-deployment --revision=1
kubectl rollout history deployment/devops-deployment --revision=2
```

---

### Part F — Rollback

```bash
# Roll back to previous version
kubectl rollout undo deployment/devops-deployment

# Verify
kubectl rollout status deployment/devops-deployment
kubectl describe deployment devops-deployment   # image back to nginx:1.25 ✅
```

Observed: revision counter went to **3** — rollback is a new revision, not undoing!

---

### Cleanup

```bash
kubectl delete deployment devops-deployment
kubectl delete service devops-service
kubectl delete pod devops-pod

kubectl get all   # only default kubernetes service remains ✅

minikube stop
```

---

## 💡 Key Concepts I Understood Today

- Declarative YAML = describe desired state, K8s figures out how to achieve it
- Every K8s manifest has: `apiVersion`, `kind`, `metadata`, `spec`
- `requests` = scheduler uses to place pod, `limits` = max before kill/throttle
- Deployment manages ReplicaSets — never create ReplicaSets directly
- Every rollout creates a NEW ReplicaSet — old scales down, new scales up
- Rollback creates a new revision — doesn't "undo", it moves forward
- Services find pods using label selectors — not names or IPs
- `kubectl apply -f` = idempotent — safe to run multiple times
- `kubectl rollout status` = watch live progress of update
- `maxSurge` = extra pods during update, `maxUnavailable` = pods down during update
- K8s default rolling update: 25% max unavailable, 25% max surge
- `kubectl get pod -o yaml` = see full internal state K8s stores for any object

---

## ❌ Mistakes I Made (and Learned From)

| Mistake | Error | What I Learned |
|---------|-------|----------------|
| Typed incomplete rollout command | Command didn't execute | Always complete the full command before pressing Enter |
| Tried `kubectl rollout undo --to-revision=1` after rollback | `unable to find specified revision` | Rollback creates new revision — history shifts. Revision numbers are dynamic |

---

## 📚 kubectl Reference for Today

```bash
# Apply manifest
kubectl apply -f file.yaml

# Get resources
kubectl get pods / deployments / replicasets / services / all

# Show labels
kubectl get pods --show-labels

# Rollout commands
kubectl rollout status deployment/<name>
kubectl rollout history deployment/<name>
kubectl rollout history deployment/<name> --revision=N
kubectl rollout undo deployment/<name>
kubectl rollout undo deployment/<name> --to-revision=N

# Scale
kubectl scale deployment <name> --replicas=N

# Watch live
kubectl get pods -w
```

---

## 📚 Resources I Used Today

- [Kubernetes Deployments Docs](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)

---

## ✅ Tomorrow → Day 36: Kubernetes — Services & kubectl Deep Dive
