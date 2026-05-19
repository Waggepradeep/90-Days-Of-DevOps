# Day 39 — Kubernetes: Persistent Volumes & Storage

![Day](https://img.shields.io/badge/Day-39-yellow?style=flat-square)
![Topic](https://img.shields.io/badge/Topic-PV%20%2B%20PVC%20%2B%20StorageClass-orange?style=flat-square)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen?style=flat-square)

> 📅 Date: May 11, 2026
> ⏱️ Time Spent: 3+ hrs
> 🎯 Goal: Understand Kubernetes persistent storage — PV, PVC, StorageClass, dynamic provisioning, and StatefulSets with dedicated storage per pod

---

## 📌 What I Learned Today

### 1. What Problem Does Persistent Storage Solve?

```
Pod deleted       → container data gone 💀
Pod rescheduled   → can't find its data on new node 💀
Multiple pods     → need shared data → how? 🤔

Solution:
PersistentVolume (PV)       → actual storage (disk, NFS, EBS)
PersistentVolumeClaim (PVC) → pod's request for storage
StorageClass                → auto-provisions storage on demand
```

> 💡 Think of it like renting an apartment:
> PV = the actual apartment (storage exists)
> PVC = your rental agreement (claim on that storage)
> StorageClass = real estate agent (auto-provisions on demand)

---

### 2. PV vs PVC vs StorageClass

| Object | Role | Created by |
|--------|------|-----------|
| PersistentVolume (PV) | Actual storage | Admin (static) or K8s (dynamic) |
| PersistentVolumeClaim (PVC) | Request for storage | Developer |
| StorageClass | Provisioning rules | Admin |

---

### 3. Access Modes

| Mode | Meaning | Use Case |
|------|---------|---------|
| `ReadWriteOnce` (RWO) | One node reads+writes | Databases |
| `ReadOnlyMany` (ROX) | Many nodes read only | Static content |
| `ReadWriteMany` (RWX) | Many nodes read+write | Shared files |

---

### 4. PV Lifecycle

```
Available → Bound → Released → Deleted

Available = PV exists, no PVC bound yet
Bound     = PVC matched and bound to PV
Released  = PVC deleted, PV not yet reclaimed (data still exists!)
Deleted   = PV removed
```

---

### 5. Reclaim Policies

| Policy | What happens when PVC deleted |
|--------|------------------------------|
| `Retain` | PV kept → status = Released → admin reclaims manually |
| `Delete` | PV + underlying storage deleted automatically |
| `Recycle` | Deprecated — don't use |

---

### 6. Static vs Dynamic Provisioning

| | Static | Dynamic |
|--|--------|---------|
| PV creation | Admin creates manually | K8s auto-creates |
| Requires | Manual PV YAML | StorageClass |
| Effort | More work | Nearly zero |
| Use case | On-prem, specific storage | Cloud, Minikube |

---

### 7. StatefulSet vs Deployment

| | Deployment | StatefulSet |
|--|-----------|-------------|
| Pod names | Random (nginx-abc123) | Ordered (web-0, web-1, web-2) |
| Storage | Shared PVC | Each pod gets own PVC |
| Scaling order | Random | Ordered (0→1→2) |
| Use case | Stateless apps | Databases, Kafka, Elasticsearch |

---

## 🛠️ Steps I Performed

### Setup

```bash
minikube start --driver=docker
mkdir ~/day39-k8s
cd ~/day39-k8s
```

---

### Part 1 — PersistentVolume (Static)

**`pv.yaml`:**
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: devops-pv
spec:
  storageClassName: manual
  capacity:
    storage: 1Gi
  accessModes:
  - ReadWriteOnce
  hostPath:
    path: "/mnt/devops-data"
  persistentVolumeReclaimPolicy: Retain
```

```bash
kubectl apply -f pv.yaml
kubectl get pv
# STATUS: Available ✅ (exists, not bound yet)
kubectl describe pv devops-pv
```

---

### Part 2 — PersistentVolumeClaim

**`pvc.yaml`:**
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: devops-pvc
spec:
  storageClassName: manual
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 500Mi
```

```bash
kubectl apply -f pvc.yaml
kubectl get pvc
# STATUS: Bound ✅ (K8s matched PVC to PV)

kubectl get pv
# CLAIM: default/devops-pvc → PV reserved for this PVC ✅
```

---

### Part 3 — PVC Inside a Pod

**`pvc-pod.yaml`:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pvc-pod
spec:
  containers:
  - name: app
    image: nginx:1.25
    volumeMounts:
    - name: storage
      mountPath: /usr/share/nginx/html
  volumes:
  - name: storage
    persistentVolumeClaim:
      claimName: devops-pvc
```

```bash
kubectl apply -f pvc-pod.yaml
kubectl get pods

# Write data to persistent storage
kubectl exec -it nginx-pvc-pod -- sh
```

Inside pod:
```sh
echo "Persistent Storage Working" > /usr/share/nginx/html/index.html
cat /usr/share/nginx/html/index.html
exit
```

**Persistence test:**
```bash
# Delete pod
kubectl delete pod nginx-pvc-pod

# Recreate pod with SAME PVC
kubectl apply -f pvc-pod.yaml

# Verify data survived!
kubectl exec -it nginx-pvc-pod -- cat /usr/share/nginx/html/index.html
# Persistent Storage Working ✅
```

---

### Part 4 — Reclaim Policy Test

```bash
kubectl delete pvc devops-pvc

# Check PV status
kubectl get pv
# STATUS: Released (PVC gone, data still exists!) ✅
```

> 💡 `Retain` policy = data safe even after PVC deletion.
> Admin must manually clean up or re-bind the PV.

---

### Part 5 — StorageClass & Dynamic Provisioning

```bash
# Check default StorageClass
kubectl get storageclass
kubectl describe storageclass standard
# Provisioner: k8s.io/minikube-hostpath
```

**`dynamic-pvc.yaml`** (no storageClassName = uses default):
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: dynamic-pvc
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 200Mi
```

```bash
kubectl apply -f dynamic-pvc.yaml

# K8s auto-created PV!
kubectl get pvc   # Bound ✅
kubectl get pv    # pvc-84edb162-... auto-provisioned ✅
```

---

### Part 6 — Deployment with Persistent Storage (MySQL)

**`deployment-with-pvc.yaml`:**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: db-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: db
  template:
    metadata:
      labels:
        app: db
    spec:
      containers:
      - name: mysql
        image: mysql:8.0
        env:
        - name: MYSQL_ROOT_PASSWORD
          value: "rootpass"
        - name: MYSQL_DATABASE
          value: "devopsdb"
        ports:
        - containerPort: 3306
        volumeMounts:
        - name: mysql-storage
          mountPath: /var/lib/mysql
      volumes:
      - name: mysql-storage
        persistentVolumeClaim:
          claimName: dynamic-pvc
```

```bash
kubectl apply -f deployment-with-pvc.yaml
kubectl get pods
kubectl get pvc
kubectl get pv
```

✅ MySQL data persists across pod restarts!

---

### Part 7 — StatefulSet

**`statefulset.yaml`:**
```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: web
spec:
  serviceName: "web"
  replicas: 3
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: nginx
        image: nginx:1.25
        volumeMounts:
        - name: web-storage
          mountPath: /usr/share/nginx/html
  volumeClaimTemplates:
  - metadata:
      name: web-storage
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 100Mi
```

```bash
kubectl apply -f statefulset.yaml

kubectl get statefulsets
kubectl get pods
# web-0, web-1, web-2 → ordered names! ✅

kubectl get pvc
# web-storage-web-0
# web-storage-web-1
# web-storage-web-2  → each pod gets its own PVC! ✅
```

---

### Cleanup

```bash
kubectl delete -f statefulset.yaml
kubectl delete -f deployment-with-pvc.yaml
kubectl delete -f dynamic-pvc.yaml
kubectl delete -f pv.yaml

# StatefulSet PVCs NOT auto-deleted — must delete manually!
kubectl delete pvc web-storage-web-0
kubectl delete pvc web-storage-web-1
kubectl delete pvc web-storage-web-2

# Verify clean
kubectl get pvc   # No resources found ✅
kubectl get pv    # No resources found ✅

minikube stop
```

---

## 💡 Key Concepts I Understood Today

- PV = actual storage, PVC = claim/request for storage — they are separate objects
- PV status: Available → Bound → Released → Deleted
- PVC Bound = K8s found matching PV and reserved it
- `Retain` policy = data survives PVC deletion — PV goes to Released state
- `Delete` policy = PV and storage removed when PVC deleted
- StorageClass + dynamic provisioning = no manual PV creation needed
- StatefulSet pod names are ordered (web-0, web-1, web-2) unlike Deployment
- `volumeClaimTemplates` = each StatefulSet pod gets its own dedicated PVC
- StatefulSet PVCs are NOT deleted when StatefulSet is deleted — must delete manually!
- MySQL data at `/var/lib/mysql` must be on a PVC or it's lost on pod restart
- Container storage is temporary — always use PVC for stateful data

---

## ❌ Mistakes I Made (and Learned From)

| Mistake | Error/Observation | What I Learned |
|---------|------------------|----------------|
| Deleted StatefulSet but forgot PVCs | PVCs remained after `kubectl delete -f statefulset.yaml` | StatefulSet PVCs are intentionally NOT auto-deleted — must delete each PVC manually |
| Expected PV to disappear after PVC deletion with Retain policy | PV stayed in Released state | `Retain` keeps data — admin must manually reclaim or delete the PV |

---

## 📚 kubectl Reference for Today

```bash
# PV & PVC
kubectl get pv
kubectl get pvc
kubectl describe pv <name>
kubectl describe pvc <name>
kubectl delete pvc <name>

# StorageClass
kubectl get storageclass
kubectl describe storageclass <name>

# StatefulSet
kubectl get statefulsets
kubectl get pods   # ordered names
kubectl get pvc    # auto-created PVCs

# Cleanup StatefulSet PVCs manually
kubectl delete pvc <name>-0 <name>-1 <name>-2
```

---

## 📚 Resources I Used Today

- [Kubernetes PV Docs](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)
- [StatefulSets Docs](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/)

---

## ✅ Tomorrow → Day 40: Helm — Package Manager for Kubernetes
