# Day 42 — Project 2: Containerized Microservice on Kubernetes

![Day](https://img.shields.io/badge/Day-42-yellow?style=flat-square)
![Topic](https://img.shields.io/badge/Topic-Project%202%20K8s%20Microservice-orange?style=flat-square)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen?style=flat-square)

> 📅 Date: May 11, 2026
> ⏱️ Time Spent: 3+ hrs
> 🎯 Goal: Build and deploy a complete containerized Flask + Redis microservice on Kubernetes — combining Docker, K8s manifests, ConfigMaps, Secrets, PVC, Ingress, and health probes into one real project

---

## 📌 What I Built Today

**Week 5–6 Capstone Project** — combining everything:

```
Day 29 (Docker) + Day 30 (Dockerfile) + Day 31 (Networks) +
Day 32 (Compose) + Day 33 (ECR) + Days 34–41 (Kubernetes)
                        ↓
    Flask API + Redis microservice deployed on Kubernetes
    with production-grade setup: probes, PVC, Ingress, Secrets
```

---

## 🏗️ Architecture

```
User
  ↓
Ingress (microservice.local)
  ↓
Flask Service (ClusterIP :80)
  ↓
Flask Pods (3 replicas)
  ↓
Redis Service (ClusterIP :6379)
  ↓
Redis Pod
  ↓
PersistentVolumeClaim (100Mi)
```

---

## 📁 Project Structure

```
day42-project/
├── app/
│   ├── app.py
│   ├── requirements.txt
│   └── Dockerfile
├── k8s/
│   ├── namespace.yaml
│   ├── configmap.yaml
│   ├── secret.yaml
│   ├── redis-deployment.yaml
│   ├── redis-service.yaml
│   ├── flask-deployment.yaml
│   ├── flask-service.yaml
│   └── ingress.yaml
└── README.md
```

---

## 🛠️ Steps I Performed

### Part A — Flask Application

**`app/app.py`:**
```python
from flask import Flask, jsonify
import redis
import os

app = Flask(__name__)

redis_client = redis.Redis(
    host=os.environ.get("REDIS_HOST", "redis-service"),
    port=int(os.environ.get("REDIS_PORT", 6379)),
    decode_responses=True
)

@app.route("/")
def home():
    return jsonify({
        "app": "DevOps Microservice",
        "day": 42,
        "status": "running"
    })

@app.route("/health")
def health():
    try:
        redis_client.ping()
        return jsonify({"status": "healthy", "redis": "connected"})
    except:
        return jsonify({"status": "unhealthy", "redis": "disconnected"}), 500

@app.route("/count")
def count():
    visits = redis_client.incr("visit_count")
    return jsonify({"message": "Visit counted!", "total_visits": visits})

@app.route("/reset")
def reset():
    redis_client.set("visit_count", 0)
    return jsonify({"message": "Count reset!", "total_visits": 0})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=False)
```

**`app/requirements.txt`:**
```
flask==3.0.0
redis==5.0.1
```

**`app/Dockerfile`:**
```dockerfile
FROM python:3.12-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
EXPOSE 5000
CMD ["python", "app.py"]
```

---

### Part B — Docker Build & Push

```bash
cd ~/day42-project/app

# Build
docker build -t devops-microservice:v1 .

# Test locally (Redis disconnected expected)
docker run -p 5000:5000 devops-microservice:v1
curl http://localhost:5000/health
# {"redis":"disconnected","status":"unhealthy"} ← expected without Redis!

# Tag for Docker Hub
docker tag devops-microservice:v1 silosw369/devops-microservice:v1
docker tag devops-microservice:v1 silosw369/devops-microservice:latest

# Push
docker login
docker push silosw369/devops-microservice:v1
docker push silosw369/devops-microservice:latest
```

---

### Part C — Kubernetes Manifests

**`k8s/namespace.yaml`:**
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: microservice
```

**`k8s/configmap.yaml`:**
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
  namespace: microservice
data:
  REDIS_HOST: "redis-service"
  REDIS_PORT: "6379"
  APP_ENV: "production"
```

**`k8s/secret.yaml`:**
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-secret
  namespace: microservice
type: Opaque
data:
  SECRET_KEY: bXlzdXBlcnNlY3JldGtleQ==
```

**`k8s/redis-deployment.yaml`:**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: redis
  namespace: microservice
spec:
  replicas: 1
  selector:
    matchLabels:
      app: redis
  template:
    metadata:
      labels:
        app: redis
    spec:
      containers:
      - name: redis
        image: redis:7.0
        ports:
        - containerPort: 6379
        resources:
          requests:
            memory: "64Mi"
            cpu: "250m"
          limits:
            memory: "128Mi"
            cpu: "500m"
        volumeMounts:
        - name: redis-storage
          mountPath: /data
      volumes:
      - name: redis-storage
        persistentVolumeClaim:
          claimName: redis-pvc
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: redis-pvc
  namespace: microservice
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 100Mi
```

**`k8s/redis-service.yaml`:**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: redis-service
  namespace: microservice
spec:
  selector:
    app: redis
  ports:
  - port: 6379
    targetPort: 6379
```

**`k8s/flask-deployment.yaml`:**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: flask-app
  namespace: microservice
spec:
  replicas: 3
  selector:
    matchLabels:
      app: flask
  template:
    metadata:
      labels:
        app: flask
    spec:
      containers:
      - name: flask
        image: silosw369/devops-microservice:v1
        ports:
        - containerPort: 5000
        envFrom:
        - configMapRef:
            name: app-config
        - secretRef:
            name: app-secret
        resources:
          requests:
            memory: "64Mi"
            cpu: "250m"
          limits:
            memory: "128Mi"
            cpu: "500m"
        readinessProbe:
          httpGet:
            path: /health
            port: 5000
          initialDelaySeconds: 10
          periodSeconds: 5
        livenessProbe:
          httpGet:
            path: /health
            port: 5000
          initialDelaySeconds: 15
          periodSeconds: 10
```

**`k8s/flask-service.yaml`:**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: flask-service
  namespace: microservice
spec:
  selector:
    app: flask
  ports:
  - port: 80
    targetPort: 5000
```

**`k8s/ingress.yaml`:**
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: app-ingress
  namespace: microservice
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
  - host: microservice.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: flask-service
            port:
              number: 80
```

---

### Part D — Deploy Everything

```bash
kubectl apply -f k8s/

kubectl get all -n microservice
kubectl get pods -n microservice --watch
# All pods → READY 1/1, STATUS Running ✅
```

---

### Part E — Tested All Routes

```bash
# Add local DNS
echo "$(minikube ip) microservice.local" | sudo tee -a /etc/hosts

# Verify Ingress
kubectl get ingress -n microservice
# HOSTS: microservice.local ✅
```

| Route | Command | Response |
|-------|---------|----------|
| `/` | `curl http://microservice.local/` | `{"app":"DevOps Microservice","day":42,"status":"running"}` |
| `/health` | `curl http://microservice.local/health` | `{"redis":"connected","status":"healthy"}` |
| `/count` | `curl http://microservice.local/count` (x3) | `{"total_visits":1}` → `2` → `3` |
| `/reset` | `curl http://microservice.local/reset` | `{"message":"Count reset!","total_visits":0}` |

✅ Flask ↔ Redis communication via K8s DNS working!
✅ Visit counter persisting in Redis!

---

### Cleanup

```bash
kubectl delete namespace microservice
# Deletes: pods, services, ingress, PVCs, deployments — everything!

sudo sed -i '/microservice.local/d' /etc/hosts
minikube stop
```

---

## 💡 Key Concepts Applied Today

- Namespace = isolated environment for entire project
- ConfigMap + Secret = config/credentials injected via `envFrom`
- Redis service name = `redis-service` → Flask connects using K8s DNS
- PVC = Redis data persists across pod restarts
- `readinessProbe` = K8s only sends traffic when `/health` returns 200
- `livenessProbe` = K8s restarts container if `/health` fails
- 3 Flask replicas + 1 Redis = typical microservice tier separation
- `kubectl apply -f k8s/` = applies all files in folder at once
- `kubectl delete namespace X` = cleanest way to remove all project resources
- Health check returning `disconnected` locally = expected (no Redis without K8s)

---

## 🔄 Full Project Flow

```
Write Flask App + Dockerfile
        ↓
docker build → docker push → Docker Hub
        ↓
Write K8s manifests (namespace, configmap, secret, deployments, services, ingress)
        ↓
kubectl apply -f k8s/
        ↓
Pods Running → Services routing → Ingress exposed
        ↓
curl http://microservice.local/ ✅
        ↓
kubectl delete namespace microservice (cleanup)
```

---

## 📚 Resources Used

- [Flask Docs](https://flask.palletsprojects.com/)
- [Redis Python Client](https://redis-py.readthedocs.io/)
- [Kubernetes Probes](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/)

---

## ✅ Week 6 Complete!

| Day | Topic | Status |
|-----|-------|--------|
| 34 | K8s — Architecture & Core Concepts | ✅ |
| 35 | K8s — Pods, Deployments & ReplicaSets | ✅ |
| 36 | K8s — Services & kubectl Deep Dive | ✅ |
| 37 | K8s — ConfigMaps & Secrets | ✅ |
| 38 | K8s — Ingress & Namespaces | ✅ |
| 39 | K8s — Persistent Volumes & Storage | ✅ |
| 40 | Helm | ✅ |
| 41 | EKS Overview | ✅ |
| 42 | Project 2 — Containerized Microservice | ✅ |

---

## ✅ Tomorrow → Day 43: Terraform Intro — Phase 2 Week 7 Begins!
