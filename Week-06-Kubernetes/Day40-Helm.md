# Day 40 — Helm: Package Manager for Kubernetes

![Day](https://img.shields.io/badge/Day-40-yellow?style=flat-square)
![Topic](https://img.shields.io/badge/Topic-Helm%20Package%20Manager-orange?style=flat-square)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen?style=flat-square)

> 📅 Date: May 11, 2026
> ⏱️ Time Spent: 3+ hrs
> 🎯 Goal: Install Helm, use public chart repos, create custom charts, deploy to multiple environments with different values, and manage releases with upgrade and rollback

---

## 📌 What I Learned Today

### 1. What Problem Does Helm Solve?

**Without Helm:**
```
deployment.yaml + service.yaml + ingress.yaml + configmap.yaml + secret.yaml + pvc.yaml
→ copy-paste + manual edits for every environment 😰
→ dev, staging, prod all have slightly different YAML files
→ easy to make mistakes, hard to track changes
```

**With Helm:**
```bash
helm install dev-app ./my-chart -f dev-values.yaml    # dev ✅
helm install prod-app ./my-chart -f prod-values.yaml  # prod ✅
# Same chart, different configs, one command each!
```

> 💡 Helm = `apt` for Ubuntu, `pip` for Python — but for Kubernetes apps!
> Packages all your K8s YAMLs into one reusable, versioned chart!

---

### 2. Core Concepts

| Concept | Meaning |
|---------|---------|
| Chart | Helm package — K8s YAML templates + default values |
| Release | Running instance of a chart in K8s |
| Repository | Collection of charts (like Docker Hub for Helm) |
| values.yaml | Default configuration values |
| Template | K8s YAML with Go template variables |
| Revision | Version history of a release |

---

### 3. Chart Structure

```
mychart/
├── Chart.yaml          ← metadata (name, version, description)
├── values.yaml         ← default config values
├── templates/          ← K8s YAML templates
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── ingress.yaml
│   └── _helpers.tpl    ← reusable template snippets
└── charts/             ← dependency charts
```

---

### 4. How Templates Work

**`templates/deployment.yaml`:**
```yaml
image: {{ .Values.image.repository }}:{{ .Values.image.tag }}
replicas: {{ .Values.replicaCount }}
```

**`values.yaml`:**
```yaml
image:
  repository: nginx
  tag: "1.25"
replicaCount: 3
```

**Rendered output:**
```yaml
image: nginx:1.25
replicas: 3
```

---

### 5. Key Helm Commands

| Command | Purpose |
|---------|---------|
| `helm install` | Install chart as a release |
| `helm upgrade` | Upgrade existing release |
| `helm rollback` | Roll back to previous revision |
| `helm uninstall` | Remove release |
| `helm list` | Show all releases |
| `helm history` | Show release revision history |
| `helm template` | Render templates locally (no deploy) |
| `helm lint` | Validate chart for errors |
| `helm status` | Show release details |

---

## 🛠️ Steps I Performed

### Part A — Installed Helm

```bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

helm version
# version.BuildInfo{Version:"v3.21.0", ...} ✅
```

---

### Part B — Helm Repositories

```bash
# Add repos
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add stable https://charts.helm.sh/stable

# Update (like apt update)
helm repo update

# List repos
helm repo list

# Search charts
helm search repo nginx
helm search repo mysql
helm search repo wordpress
```

---

### Part C — Install Chart from Repo

```bash
minikube start --driver=docker
kubectl get nodes

# Install nginx from Bitnami
helm install my-nginx bitnami/nginx

# Check everything
helm list
kubectl get all
helm status my-nginx

# Upgrade — scale to 2 replicas
helm upgrade my-nginx bitnami/nginx --set replicaCount=2
kubectl get pods

# View history
helm history my-nginx

# Rollback to revision 1
helm rollback my-nginx 1
kubectl get pods

# Uninstall
helm uninstall my-nginx
```

---

### Part D — Create Custom Chart

```bash
mkdir ~/day40-helm
cd ~/day40-helm

# Create chart scaffold
helm create mychart

# Explore structure
ls mychart/
cat mychart/Chart.yaml
cat mychart/values.yaml
ls mychart/templates/

# Lint before install
helm lint mychart/

# Render templates without deploying
helm template test-release mychart/

# Install
helm install devops-release mychart/
kubectl get all
helm list
```

---

### Part E — Customized Chart

```bash
helm create devops-app
nano devops-app/values.yaml
```

**`values.yaml`:**
```yaml
replicaCount: 2

image:
  repository: nginx
  tag: "1.25"
  pullPolicy: IfNotPresent

service:
  type: NodePort
  port: 80

ingress:
  enabled: false

resources:
  requests:
    memory: "64Mi"
    cpu: "250m"
  limits:
    memory: "128Mi"
    cpu: "500m"

autoscaling:
  enabled: false

env:
  APP_NAME: "devops-app"
  APP_ENV: "production"
  LOG_LEVEL: "info"
```

**`Chart.yaml`:**
```yaml
apiVersion: v2
name: devops-app
description: My DevOps App Helm Chart
type: application
version: 0.1.0
appVersion: "1.0.0"
```

---

### Part F — Validate & Install

```bash
# Validate
helm lint devops-app/

# Preview — dry run (no actual deploy)
helm install my-devops-app devops-app/ --dry-run

# Render templates locally
helm template my-devops-app devops-app/

# Install
helm install my-devops-app devops-app/

# Verify
kubectl get all
helm list
helm status my-devops-app
```

---

### Part G — Multi-Environment with --set

```bash
# Development release
helm install dev-app devops-app/ \
  --set replicaCount=1 \
  --set env.APP_ENV=development \
  --set image.tag=1.26

# Staging release
helm install staging-app devops-app/ \
  --set replicaCount=3 \
  --set env.APP_ENV=staging

# Both running from same chart!
helm list
kubectl get pods
```

---

### Part H — Values Files

**`dev-values.yaml`:**
```yaml
replicaCount: 1
env:
  APP_ENV: development
  LOG_LEVEL: debug
image:
  tag: "1.25"
```

**`prod-values.yaml`:**
```yaml
replicaCount: 5
env:
  APP_ENV: production
  LOG_LEVEL: warn
image:
  tag: "1.26"
```

```bash
# Install using values files
helm install prod-app devops-app/ -f prod-values.yaml

helm list
kubectl get pods
```

> 💡 `-f values-file.yaml` is cleaner than `--set` for many overrides.
> Commit values files to Git → version-controlled environment configs!

---

### Part I — Upgrade & Rollback

```bash
# Upgrade release
helm upgrade dev-app devops-app/ --set replicaCount=3

# View revision history
helm history dev-app
# REVISION 1 → original
# REVISION 2 → scaled to 3

# Rollback to revision 1
helm rollback dev-app 1

# Verify
kubectl get pods   # back to 1 replica ✅
helm history dev-app
# REVISION 3 → rollback (new revision created!)
```

---

### Cleanup

```bash
helm uninstall my-devops-app
helm uninstall dev-app
helm uninstall staging-app
helm uninstall prod-app

helm list        # empty ✅
kubectl get all  # only default service ✅

minikube stop
```

---

## 💡 Key Concepts I Understood Today

- Helm = K8s package manager — like apt/pip but for Kubernetes apps
- Chart = package of K8s YAML templates + default values
- Release = running instance of a chart — one chart → many releases
- `helm template` = render YAML locally without deploying — great for debugging
- `helm lint` = validate chart before installing — catches errors early
- `--dry-run` = simulate install without creating resources
- Same chart → multiple environments with different values files
- `-f values-file.yaml` = cleaner than `--set` for multiple overrides
- Rollback creates a new revision — history always moves forward
- Must preserve all values expected by templates in `values.yaml` — removing expected keys causes `nil pointer` errors
- `helm history` = view all revisions of a release
- `helm uninstall` removes all K8s resources created by the chart

---

## ❌ Mistakes I Made (and Learned From)

| Mistake | Error | What I Learned |
|---------|-------|----------------|
| Replaced `values.yaml` without keeping template-expected keys | `nil pointer evaluating interface {}.create` | Helm templates reference specific keys — must keep all expected values even if customizing |

---

## 🏗️ Helm Workflow

```
helm create chart        → scaffold chart structure
Edit values.yaml         → set default config
Edit templates/          → customize K8s YAMLs
helm lint                → validate
helm template            → preview rendered output
helm install --dry-run   → simulate deploy
helm install             → deploy
helm upgrade             → update release
helm history             → view revisions
helm rollback            → revert to previous revision
helm uninstall           → remove release
```

---

## 📚 Resources I Used Today

- [Helm Official Docs](https://helm.sh/docs/)
- [Helm Hub / Artifact Hub](https://artifacthub.io/)
- [Bitnami Charts](https://charts.bitnami.com/bitnami)

---

## ✅ Tomorrow → Day 41: Kubernetes on AWS — EKS Overview
