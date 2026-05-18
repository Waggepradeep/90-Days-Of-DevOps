# Day 38 — Kubernetes: Ingress & Namespaces

![Day](https://img.shields.io/badge/Day-38-yellow?style=flat-square)
![Topic](https://img.shields.io/badge/Topic-Ingress%20%2B%20Namespaces-orange?style=flat-square)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen?style=flat-square)

> 📅 Date: May 11, 2026
> ⏱️ Time Spent: 3+ hrs
> 🎯 Goal: Route external traffic using Ingress with path-based routing, isolate environments using Namespaces, and limit resources with ResourceQuotas

---

## 📌 What I Learned Today

### 1. What Problem Does Ingress Solve?

```
NodePort    → ugly high ports (30080) → not production ready ❌
LoadBalancer → one LB per service → 10 services = 10 LBs = expensive 💸

Ingress → ONE entry point → routes to MANY services:
  myapp.com/web   → web-service ✅
  myapp.com/api   → api-service ✅
  All through ONE load balancer → much cheaper!
```

> 💡 Ingress = smart HTTP router in front of all services.
> Like an Nginx reverse proxy — but managed by Kubernetes!

---

### 2. Ingress vs Service

| | Service (NodePort/LB) | Ingress |
|--|----------------------|---------|
| Layer | L4 (TCP/UDP) | L7 (HTTP/HTTPS) |
| Routing | Port-based | Path/hostname-based |
| Cost | 1 LB per service | 1 LB for all services |
| URL | myapp:30080 | myapp.com/api |
| HTTPS | Manual | Built-in TLS termination |

---

### 3. Ingress Controller

Ingress is just a YAML spec — you need a controller to implement it:

```
Ingress YAML (rules) → Ingress Controller (nginx) → actual routing
```

Minikube provides the Nginx Ingress Controller as an addon.

---

### 4. Namespaces

```
Cluster
├── default      → your apps (default workspace)
├── kube-system  → K8s internal components
├── dev          → development environment
├── staging      → staging environment
└── production   → production environment
```

**Why namespaces matter:**
- Resource isolation → dev can't accidentally delete prod
- Resource quotas → limit CPU/memory per team/environment
- RBAC → give team access to dev only, not prod
- Same resource names can exist in different namespaces

---

### 5. ResourceQuota

Limits total resources a namespace can consume:

```yaml
spec:
  hard:
    pods: "5"           # max 5 pods
    requests.cpu: "1"   # max 1 CPU requested
    requests.memory: 1Gi
    limits.cpu: "2"
    limits.memory: 2Gi
```

---

### 6. Cross-Namespace DNS

```
Service DNS format: service-name.namespace.svc.cluster.local

web-service.default.svc.cluster.local
web-service.dev.svc.cluster.local
```

---

## 🛠️ Steps I Performed

### Setup

```bash
minikube start --driver=docker
mkdir ~/day38-k8s
cd ~/day38-k8s
```

---

### Part A — Enabled Ingress Controller

```bash
minikube addons enable ingress

# Wait for controller to be ready
kubectl get pods -n ingress-nginx --watch
```

Observed:
- Ingress controller pod → `Running` ✅
- Admission jobs → `Completed` ✅

---

### Part B — Deployed Two Apps

**`apps.yaml`** (web-app + api-app with their services):

```yaml
# web-app Deployment + Service
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: web
        image: nginx:1.25
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: web-service
spec:
  selector:
    app: web
  ports:
  - port: 80
    targetPort: 80
---
# api-app Deployment + Service
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: api
  template:
    metadata:
      labels:
        app: api
    spec:
      containers:
      - name: api
        image: httpd:2.4
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: api-service
spec:
  selector:
    app: api
  ports:
  - port: 80
    targetPort: 80
```

```bash
kubectl apply -f apps.yaml
kubectl get pods
kubectl get services
```

Final state: 2 web pods + 2 api pods + 2 ClusterIP services ✅

---

### Part C — Created Ingress

**`ingress.yaml`:**

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: app-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
  - host: myapp.local
    http:
      paths:
      - path: /web
        pathType: Prefix
        backend:
          service:
            name: web-service
            port:
              number: 80
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: api-service
            port:
              number: 80
```

```bash
kubectl apply -f ingress.yaml
kubectl get ingress
kubectl describe ingress app-ingress
```

---

### Part D — Local DNS Mapping

```bash
# Get Minikube IP
minikube ip   # 192.168.49.2

# Add to hosts file
sudo nano /etc/hosts
# Added: 192.168.49.2 myapp.local

# Verify
ping myapp.local
```

---

### Part E — Tested Routing

```bash
curl http://myapp.local/web   # → Nginx page ✅
curl http://myapp.local/api   # → Apache page ✅
```

Also verified in browser — path-based routing working! 🎉

---

### Part F — Namespaces

```bash
# View existing
kubectl get namespaces

# Create environments
kubectl create namespace dev
kubectl create namespace staging
kubectl create namespace production
```

**`namespace-deploy.yaml`** (same app, different namespaces):

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
  namespace: dev
spec:
  replicas: 1
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: app
        image: nginx:1.25
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
  namespace: staging
spec:
  replicas: 2
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: app
        image: nginx:1.25
```

```bash
kubectl apply -f namespace-deploy.yaml

kubectl get pods -n dev        # 1 pod ✅
kubectl get pods -n staging    # 2 pods ✅
kubectl get deployments -n dev
kubectl get deployments -n staging

# All namespaces at once
kubectl get pods --all-namespaces
```

✅ Same deployment name, different namespaces, different replica counts!

---

### Part G — Resource Quotas

**`quota.yaml`:**

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: dev-quota
  namespace: dev
spec:
  hard:
    pods: "5"
    requests.cpu: "1"
    requests.memory: 1Gi
    limits.cpu: "2"
    limits.memory: 2Gi
```

```bash
kubectl apply -f quota.yaml

kubectl get resourcequota -n dev
kubectl describe resourcequota dev-quota -n dev
```

Observed: `pods: 1/5` → using 1, max 5 ✅

---

### Part H — Namespace Context Switching

```bash
# Set default namespace — no more -n flag needed
kubectl config set-context --current --namespace=dev
kubectl get pods   # shows only dev pods ✅

# Switch back
kubectl config set-context --current --namespace=default
kubectl get pods   # shows default pods ✅
```

---

### Cleanup

```bash
kubectl delete -f ingress.yaml
kubectl delete -f apps.yaml
kubectl delete -f namespace-deploy.yaml
kubectl delete -f quota.yaml
kubectl delete namespace dev staging production

# Remove hosts entry
sudo sed -i '/myapp.local/d' /etc/hosts

minikube stop
```

---

## 💡 Key Concepts I Understood Today

- Ingress = L7 HTTP router — routes by path/hostname, not port
- Ingress needs a controller (nginx) to actually implement routing rules
- `rewrite-target: /` annotation = strip path prefix before forwarding to service
- One Ingress handles all services → much cheaper than multiple LoadBalancers
- `/etc/hosts` = local DNS override — maps hostname to Minikube IP
- Namespaces = logical isolation — same names can exist in different namespaces
- ResourceQuota = hard limits per namespace — prevents resource hogging
- `kubectl config set-context --current --namespace=X` = set default namespace
- Cross-namespace DNS: `service.namespace.svc.cluster.local`
- Minikube stops on reboot — always run `minikube start` after restart
- Deployment selectors are immutable — delete old deployment before recreating with different selector
- Ingress webhook needs time to initialize — wait for controller pod to be `Running` before applying

---

## ❌ Mistakes I Made (and Learned From)

| Mistake | Error | What I Learned |
|---------|-------|----------------|
| Old Day 36 deployment still existed | `spec.selector: field is immutable` | Deployment selectors can't be changed after creation — delete old deployment first |
| Ran kubectl after system reboot | `Unable to connect to the server` | Minikube stops on reboot — always run `minikube start --driver=docker` first |
| Applied Ingress before controller was ready | `failed calling webhook` | Ingress admission webhook needs controller fully running — wait for `Running` status before applying |
| Ran kubectl after `minikube stop` | `connection refused at localhost:8080` | kubectl needs live API server — restart Minikube to use kubectl again |

---

## 📚 kubectl Reference for Today

```bash
# Ingress
minikube addons enable ingress
kubectl get ingress
kubectl describe ingress <name>

# Namespaces
kubectl get namespaces
kubectl create namespace <name>
kubectl get pods -n <namespace>
kubectl get all --all-namespaces
kubectl delete namespace <name>

# Context / default namespace
kubectl config set-context --current --namespace=<name>

# ResourceQuota
kubectl get resourcequota -n <namespace>
kubectl describe resourcequota <name> -n <namespace>
```

---

## 📚 Resources I Used Today

- [Kubernetes Ingress Docs](https://kubernetes.io/docs/concepts/services-networking/ingress/)
- [Kubernetes Namespaces Docs](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/)
- [Resource Quotas Docs](https://kubernetes.io/docs/concepts/policy/resource-quotas/)

---

## ✅ Tomorrow → Day 39: Kubernetes — Persistent Volumes & Storage
