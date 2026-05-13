# Day 31 — Docker Volumes & Networks

![Day](https://img.shields.io/badge/Day-31-yellow?style=flat-square)
![Topic](https://img.shields.io/badge/Topic-Docker%20Volumes%20%2B%20Networks-orange?style=flat-square)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen?style=flat-square)

> 📅 Date: May 11, 2026
> ⏱️ Time Spent: 3+ hrs
> 🎯 Goal: Understand Docker persistent storage via volumes, container communication via networks, and build a real multi-container Flask + MySQL app

---

## 📌 What I Learned Today

### 1. What Problems Do Volumes & Networks Solve?

**Problem 1 — Data Loss:**
```
Container running MySQL → stores data inside container
Container deleted → ALL data gone forever 💀

Solution → Docker Volumes → data lives outside container ✅
```

**Problem 2 — Container Communication:**
```
Flask app needs to talk to MySQL container
How do they find each other? 🤔

Solution → Docker Networks → containers talk by NAME ✅
```

---

### 2. Storage Types

| Type | Syntax | Use Case |
|------|--------|---------|
| Named Volume | `-v myvolume:/app/data` | Persistent DB data, production |
| Bind Mount | `-v $(pwd):/app` | Local dev — live code editing |
| tmpfs | `--tmpfs /tmp` | Temporary in-memory data |

---

### 3. Docker Networks

**Default networks:**

| Network | Description |
|---------|-------------|
| `bridge` | Default — containers isolated, use IP |
| `host` | Container shares host's network directly |
| `none` | No networking at all |

**Custom bridge network:**
```
Custom network → Docker provides DNS by container name
Flask container → connects to "mysql-db" (just the name!) ✅
```

> 💡 Always use a custom network — never rely on default bridge.
> Custom network = automatic DNS resolution by container name!

---

### 4. Container Analogy

```
Container = temporary room (deleted anytime)
Volume    = external hard drive (data survives)
Network   = private LAN connecting containers
```

---

### 5. Docker DNS

```
Default bridge network → containers use IP addresses (bad)
Custom bridge network  → containers use NAMES (good)

mysql-db resolves automatically → no IP needed!
```

---

## 🛠️ Steps I Performed

### Part A — Named Volumes

```bash
# Create named volume
docker volume create devops-data

# List volumes
docker volume ls

# Inspect — see where data lives on host
docker volume inspect devops-data
# Data stored at: /var/lib/docker/volumes/devops-data/
```

**Test persistence:**

```bash
# Run container with volume
docker run -it -v devops-data:/data ubuntu bash
```

Inside container:
```bash
echo "This data will survive!" > /data/test.txt
cat /data/test.txt
exit
```

```bash
# New container — same volume
docker run -it -v devops-data:/data ubuntu bash
```

Inside new container:
```bash
cat /data/test.txt   # Still there! ✅
exit
```

✅ Data survived container deletion — volumes work!

---

### Part B — Bind Mounts (Live Code Reload)

```bash
cd ~/day30-docker

docker run -d \
  -p 5000:5000 \
  -v $(pwd):/app \
  --name flask-dev \
  devops-app:v2
```

- Modified `app.py` locally → added `LIVE RELOAD TEST` text
- Ran `docker restart flask-dev`
- Browser showed changes immediately ✅

> 💡 Bind mount = host folder ↔ container folder — changes reflect instantly!
> This is the standard local development workflow with Docker.

```bash
docker stop flask-dev
docker rm flask-dev
```

---

### Part C — Docker Networking

```bash
# List default networks
docker network ls
# bridge, host, none

# Create custom network
docker network create devops-network

# Inspect — see subnet, gateway, driver
docker network inspect devops-network
```

---

### Part D — Multi-Container Communication (Flask + MySQL)

**Step 1 — Run MySQL on custom network:**

```bash
docker run -d \
  --name mysql-db \
  --network devops-network \
  -e MYSQL_ROOT_PASSWORD=rootpass \
  -e MYSQL_DATABASE=devopsdb \
  -e MYSQL_USER=devops \
  -e MYSQL_PASSWORD=devpass \
  -v mysql-data:/var/lib/mysql \
  mysql:8.0
```

**Step 2 — Test network connectivity:**

```bash
docker run -it --network devops-network ubuntu bash
```

Inside Ubuntu container:
```bash
apt update && apt install iputils-ping -y
ping mysql-db   # Resolved by name! ✅
```

✅ `mysql-db` resolved automatically — Docker DNS working!

**Step 3 — Connect to MySQL:**

```bash
docker run -it \
  --network devops-network \
  mysql:8.0 \
  mysql -h mysql-db -u devops -pdevpass devopsdb
```

Inside MySQL:
```sql
SHOW DATABASES;
CREATE TABLE users (id INT, name VARCHAR(50));
INSERT INTO users VALUES (1, 'No_Body');
SELECT * FROM users;
EXIT;
```

---

### Part E — Full Flask + MySQL Integration

Created `devops-app:v3` — Flask app with MySQL connection and `/users` route.

```bash
docker build -t devops-app:v3 .

docker run -d \
  --name flask-app \
  --network devops-network \
  -p 5000:5000 \
  devops-app:v3
```

**Tested routes:**

| Route | Result |
|-------|--------|
| `http://localhost:5000` | Flask + MySQL Docker App ✅ |
| `http://localhost:5000/health` | `{"status":"healthy"}` ✅ |
| `http://localhost:5000/users` | `ID: 1 \| Name: No_Body` ✅ |

✅ Flask container successfully read data from MySQL container — multi-container app working!

---

### Part F — Cleanup

```bash
# Stop and remove containers
docker stop flask-app mysql-db
docker rm flask-app mysql-db

# Remove networks
docker network rm devops-network
docker network prune

# Remove volumes
docker volume rm devops-data mysql-data
docker volume prune

# Remove images
docker rmi devops-app:v2
```

---

## 💡 Key Concepts I Understood Today

- Named volumes = data persists independently from container lifecycle
- Every `docker run` creates a NEW container — not the same one
- Bind mount = live link between host folder and container folder
- Custom Docker network = automatic DNS by container name
- Default bridge network = containers use IPs (not names)
- `mysql-db` resolves by name only when both containers on same custom network
- Volumes are persistent — reusing old volumes can cause initialization conflicts
- `docker rm` = remove container, `docker rmi` = remove image (different commands!)
- `$(pwd)` = command substitution — use inside another command, not alone
- Debugging container issues via `docker logs` is essential

---

## ❌ Mistakes I Made (and Learned From)

| Mistake | Error | What I Learned |
|---------|-------|----------------|
| Used old `devops-data` volume for MySQL | `data directory has files in it` — MySQL crashed | Always create a fresh volume for MySQL — never reuse volumes with existing unrelated data |
| Ran `$(pwd)` alone in terminal | `bash: /home/wagge/day30-docker: Is a directory` | `$(pwd)` is command substitution — only valid inside another command like `-v $(pwd):/app` |
| Ran `docker rm devops-app:v2` | Error — wrong command | `docker rm` = remove containers only. `docker rmi` = remove images |
| Expected `docker run` to reuse existing container | Two Ubuntu containers appeared in `docker ps -a` | Every `docker run` creates a brand new container — use `docker start` to restart existing |

---

## 🏗️ Final Architecture Built Today

```
devops-network (custom bridge)
├── mysql-db container
│     └── mysql-data volume → /var/lib/mysql (persistent!)
└── flask-app container
      └── connects to mysql-db by NAME via Docker DNS
            ↓
      /users route queries MySQL and returns data
```

---

## 📚 Docker Commands Reference

| Command | Purpose |
|---------|---------|
| `docker volume create` | Create named volume |
| `docker volume ls` | List volumes |
| `docker volume inspect` | Volume details |
| `docker volume rm / prune` | Remove volumes |
| `docker network create` | Create custom network |
| `docker network ls` | List networks |
| `docker network inspect` | Network details |
| `docker network rm / prune` | Remove networks |
| `docker run --network` | Attach container to network |

---

## 📚 Resources I Used Today

- [Docker Volumes Docs](https://docs.docker.com/storage/volumes/)
- [Docker Networking Docs](https://docs.docker.com/network/)

---

## ✅ Tomorrow → Day 32: Docker Compose — Multi-Container Apps
