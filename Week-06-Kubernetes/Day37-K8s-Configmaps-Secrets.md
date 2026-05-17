# Day 37 — Kubernetes: ConfigMaps & Secrets

![Day](https://img.shields.io/badge/Day-37-yellow?style=flat-square)
![Topic](https://img.shields.io/badge/Topic-ConfigMaps%20%2B%20Secrets-orange?style=flat-square)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen?style=flat-square)

> 📅 Date: May 11, 2026
> ⏱️ Time Spent: 3+ hrs
> 🎯 Goal: Separate config from code using ConfigMaps and Secrets — inject them as env vars and volume-mounted files, and understand live config updates

---

## 📌 What I Learned Today

### 1. What Problem Do ConfigMaps & Secrets Solve?

**Without ConfigMaps/Secrets:**
```yaml
environment:
  DB_HOST: mysql
  DB_PASSWORD: devpass   ← hardcoded in YAML 😱
```

Problems:
```
Hardcoded config → can't reuse same image for dev/staging/prod
Hardcoded secrets → committed to Git → security breach 💀
```

**With ConfigMaps & Secrets:**
```
ConfigMap → store non-sensitive config (URLs, ports, feature flags)
Secret    → store sensitive data (passwords, API keys, tokens)
Both      → injected into pods at runtime → image stays clean ✅
```

> 💡 Golden rule: never hardcode config or secrets in your image!
> This is the 12-Factor App principle — separate config from code!

---

### 2. ConfigMap vs Secret

| | ConfigMap | Secret |
|--|-----------|--------|
| Data type | Non-sensitive | Sensitive |
| Storage | Plain text | Base64 encoded |
| Use case | DB_HOST, APP_ENV, LOG_LEVEL | DB_PASSWORD, API_KEY, tokens |
| Visible in describe | ✅ Yes | ❌ Hidden |

---

### 3. ⚠️ Base64 is NOT Encryption!

```bash
echo -n "devpass" | base64      # ZGV2cGFzcw==
echo ZGV2cGFzcw== | base64 -d  # devpass  ← anyone can decode!
```

> Base64 = encoding, not encryption!
> In production use AWS Secrets Manager, HashiCorp Vault, or Sealed Secrets!

---

### 4. Ways to Inject ConfigMaps & Secrets

| Method | How | Auto-updates? |
|--------|-----|--------------|
| Env vars (key-by-key) | `valueFrom.configMapKeyRef` | ❌ Needs pod restart |
| Env vars (all keys) | `envFrom.configMapRef` | ❌ Needs pod restart |
| Volume mount | `volumes.configMap` | ✅ Auto-refreshes! |

---

### 5. Volume Mount — How it Works

Each ConfigMap key becomes a **file** at the mount path:
```
/etc/config/DB_HOST     → "mysql"
/etc/config/APP_ENV     → "production"
/etc/config/LOG_LEVEL   → "info"
```

> 💡 This is how nginx.conf, app.properties, certificates etc.
> are injected into containers in production!

---

## 🛠️ Steps I Performed

### Setup

```bash
minikube start --driver=docker
mkdir ~/day37-k8s
cd ~/day37-k8s
```

---

### Part A — Created ConfigMaps

**Method 1 — YAML:**

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  DB_HOST: "mysql"
  DB_PORT: "3306"
  APP_ENV: "production"
  LOG_LEVEL: "info"
  APP_NAME: "devops-app"
```

```bash
kubectl apply -f configmap.yaml
kubectl get configmaps
kubectl describe configmap app-config
kubectl get configmap app-config -o yaml
```

**Method 2 — CLI literals:**

```bash
kubectl create configmap cli-config \
  --from-literal=ENV=staging \
  --from-literal=PORT=8080

kubectl describe configmap cli-config
```

**Method 3 — From file:**

```bash
echo "This is app config content" > app.properties
kubectl create configmap file-config --from-file=app.properties
kubectl describe configmap file-config
```

Learned: filename → key, file contents → value. Useful for `.env`, `.properties`, nginx configs.

---

### Part B — Created Secrets

```bash
# Encode values first
echo -n "devpass" | base64       # ZGV2cGFzcw==
echo -n "secretkey123" | base64  # c2VjcmV0a2V5MTIz
```

**`secret.yaml`:**
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-secret
type: Opaque
data:
  DB_PASSWORD: ZGV2cGFzcw==
  API_KEY: c2VjcmV0a2V5MTIz
```

```bash
kubectl apply -f secret.yaml
kubectl get secrets
kubectl describe secret app-secret   # values hidden ✅

# Decode a value
kubectl get secret app-secret \
  -o jsonpath='{.data.DB_PASSWORD}' | base64 -d
# devpass ✅
```

**CLI method (K8s auto-encodes):**
```bash
kubectl create secret generic cli-secret \
  --from-literal=DB_PASSWORD=mypassword \
  --from-literal=TOKEN=abc123xyz

kubectl get secret cli-secret -o yaml   # values auto base64 encoded ✅
```

---

### Part C — ConfigMap as Environment Variables (envFrom)

**`configmap-pod.yaml`:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: configmap-pod
spec:
  containers:
  - name: app
    image: nginx:1.25
    envFrom:
    - configMapRef:
        name: app-config
```

```bash
kubectl apply -f configmap-pod.yaml
kubectl exec -it configmap-pod -- sh
```

Inside pod:
```sh
env | grep APP   # APP_NAME=devops-app, APP_ENV=production
env | grep DB    # DB_HOST=mysql, DB_PORT=3306
exit
```

✅ All ConfigMap keys loaded as env vars automatically!

---

### Part D — Secret as Environment Variables

**`secret-pod.yaml`:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secret-pod
spec:
  containers:
  - name: app
    image: nginx:1.25
    env:
    - name: DB_PASSWORD
      valueFrom:
        secretKeyRef:
          name: app-secret
          key: DB_PASSWORD
    - name: API_KEY
      valueFrom:
        secretKeyRef:
          name: app-secret
          key: API_KEY
```

```bash
kubectl apply -f secret-pod.yaml
kubectl exec -it secret-pod -- sh
```

Inside pod:
```sh
env | grep DB     # DB_PASSWORD=devpass ✅
env | grep API    # API_KEY=secretkey123 ✅
exit
```

> 💡 Kubernetes auto-decodes secret values before injecting — containers
> see plain text, never base64!

---

### Part E — ConfigMap as Volume (Files)

**`configmap-volume-pod.yaml`:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: configmap-volume-pod
spec:
  containers:
  - name: app
    image: nginx:1.25
    volumeMounts:
    - name: config-volume
      mountPath: /etc/config
  volumes:
  - name: config-volume
    configMap:
      name: app-config
```

```bash
kubectl apply -f configmap-volume-pod.yaml
kubectl exec -it configmap-volume-pod -- sh
```

Inside pod:
```sh
ls /etc/config
# APP_ENV  APP_NAME  DB_HOST  DB_PORT  LOG_LEVEL

cat /etc/config/APP_NAME   # devops-app ✅
cat /etc/config/DB_HOST    # mysql ✅
exit
```

✅ Each key = one file, value = file content!

---

### Part F — Secret as Volume (Files)

**`secret-volume-pod.yaml`:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secret-volume-pod
spec:
  containers:
  - name: app
    image: nginx:1.25
    volumeMounts:
    - name: secret-volume
      mountPath: /etc/secret
  volumes:
  - name: secret-volume
    secret:
      secretName: app-secret
```

```bash
kubectl apply -f secret-volume-pod.yaml
kubectl exec -it secret-volume-pod -- sh
```

Inside pod:
```sh
ls /etc/secret
# API_KEY  DB_PASSWORD

cat /etc/secret/DB_PASSWORD   # devpass ✅ (auto-decoded!)
cat /etc/secret/API_KEY       # secretkey123 ✅
exit
```

> 💡 Volume-mounted secrets = standard for TLS certs, SSH keys, API tokens!
> K8s auto-decodes values before mounting — containers see plain text!

---

### Part G — Live ConfigMap Update

```bash
# Edit ConfigMap live
kubectl edit configmap app-config
# Press i → change LOG_LEVEL: info → LOG_LEVEL: debug → Esc → :wq

# Verify change
kubectl describe configmap app-config

# Check inside volume-mounted pod (no restart needed!)
kubectl exec -it configmap-volume-pod -- cat /etc/config/LOG_LEVEL
# debug ✅ (auto-refreshed within ~30-60 seconds)

# Check env var pod (restart needed)
kubectl exec -it configmap-pod -- env | grep LOG_LEVEL
# info ← still old value! Needs pod restart to update
```

**Critical difference:**

| Method | Auto-updates on ConfigMap change? |
|--------|----------------------------------|
| Environment Variables (`envFrom`) | ❌ Requires pod restart |
| Volume Mount | ✅ Auto-refreshes (~30-60s) |

---

### Cleanup

```bash
kubectl delete pod configmap-pod secret-pod configmap-volume-pod secret-volume-pod
kubectl delete configmap app-config cli-config file-config
kubectl delete secret app-secret cli-secret
kubectl get all   # only default service remains ✅
minikube stop
```

---

## 💡 Key Concepts I Understood Today

- ConfigMap = non-sensitive config, Secret = sensitive data
- Base64 = encoding NOT encryption — anyone can decode it
- `envFrom` = load ALL configmap keys as env vars at once
- `valueFrom.secretKeyRef` = load specific secret key as env var
- Volume mount = each key becomes a file at the mount path
- K8s auto-decodes secret values before injecting — containers see plain text
- Volume-mounted ConfigMaps auto-refresh on change — no pod restart needed
- Env var ConfigMaps do NOT auto-refresh — pod must restart
- `kubectl edit` opens vim — `i` for insert, `Esc` + `:wq` to save
- YAML spacing matters — `LOG_LEVEL:debug` fails, `LOG_LEVEL: debug` works
- In production: use AWS Secrets Manager / HashiCorp Vault for real encryption

---

## ❌ Mistakes I Made (and Learned From)

| Mistake | Error | What I Learned |
|---------|-------|----------------|
| Opened `kubectl edit` but couldn't type | Vim was in command mode | Press `i` first to enter INSERT mode. `Esc` → `:wq` to save and exit |
| Wrote `LOG_LEVEL:debug` (no space) | YAML parsing error | YAML requires space after colon: `LOG_LEVEL: debug` |

---

## 📚 kubectl Reference for Today

```bash
# ConfigMap
kubectl create configmap <name> --from-literal=key=value
kubectl create configmap <name> --from-file=file.properties
kubectl get configmaps
kubectl describe configmap <name>
kubectl edit configmap <name>

# Secret
kubectl create secret generic <name> --from-literal=key=value
kubectl get secrets
kubectl describe secret <name>
kubectl get secret <name> -o jsonpath='{.data.KEY}' | base64 -d

# Verify inside pod
kubectl exec -it <pod> -- env
kubectl exec -it <pod> -- ls /etc/config
kubectl exec -it <pod> -- cat /etc/config/KEY
```

---

## 📚 Resources I Used Today

- [Kubernetes ConfigMaps Docs](https://kubernetes.io/docs/concepts/configuration/configmap/)
- [Kubernetes Secrets Docs](https://kubernetes.io/docs/concepts/configuration/secret/)

---

## ✅ Tomorrow → Day 38: Kubernetes — Ingress & Namespaces
