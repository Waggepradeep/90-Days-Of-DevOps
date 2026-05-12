# Day 29 — Docker: Images, Containers & Volumes

![Day](https://img.shields.io/badge/Day-29-yellow?style=flat-square)
![Topic](https://img.shields.io/badge/Topic-Docker%20Basics-orange?style=flat-square)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen?style=flat-square)

> 📅 Date: May 11, 2026
> ⏱️ Time Spent: 3+ hrs
> 🎯 Goal: Understand Docker fundamentals — images, containers, volumes, port mapping, lifecycle management, and run real apps inside containers

---

## 📌 What I Learned Today

### 1. What Problem Does Docker Solve?

**Without Docker:**
```
Works on my Ubuntu machine ❌
Fails on EC2 (Amazon Linux) ❌
Fails on colleague's Mac ❌
```

**With Docker:**
```
Build once → runs identically everywhere ✅
Your laptop = EC2 = colleague's Mac = production server
```

> 💡 Docker packages your app + ALL its dependencies into a container —
> a lightweight, portable, isolated box that runs the same everywhere!

---

### 2. Core Concepts

| Concept | Meaning |
|---------|---------|
| Image | Read-only blueprint/template for containers |
| Container | Running instance of an image |
| Docker Hub | Public registry of pre-built images |
| Volume | Persistent/shared storage between host and container |
| Port Mapping | Connect host port to container port |
| Detached Mode (`-d`) | Run container in background |
| Interactive Mode (`-it`) | Open terminal inside container |

---

### 3. Docker Architecture

```
Docker CLI (you type commands)
        ↓
Docker Daemon (background service)
        ↓
Docker Image (pulled from Docker Hub)
        ↓
Container (isolated running process)
```

---

### 4. Container vs Virtual Machine

| | Container | Virtual Machine |
|--|-----------|----------------|
| OS | Shares host kernel | Full separate OS |
| Size | Lightweight (MBs) | Heavy (GBs) |
| Startup | Milliseconds | Minutes |
| Isolation | Process-level | Full hardware-level |

> 💡 Containers use Linux **namespaces** (isolation) + **cgroups** (resource limits)
> They are NOT virtual machines — they are isolated processes on the host!

---

### 5. Image vs Container vs Volume

| | Image | Container | Volume |
|--|-------|-----------|--------|
| What | Blueprint | Running instance | Persistent storage |
| Read/Write | Read-only | Read + Write | Read + Write |
| Persists | ✅ Yes | ❌ Deleted on remove | ✅ Yes |

---

### 6. Container Lifetime Rule

```
Container lifetime = main process lifetime

Process running → Container running
Process exits   → Container stops automatically
```

---

### 7. Docker Image Layers

Images are built in layers — like a stack:

```
Base OS (Ubuntu)
    ↓
Install packages (apt install nginx)
    ↓
Copy config files
    ↓
Set entrypoint (nginx -g daemon off)
```

Benefits:
- **Caching** — unchanged layers don't re-download
- **Faster pulls** — only changed layers downloaded
- **Smaller updates** — share common layers between images

---

## 🛠️ Steps I Performed

### Step 1 — Docker Verification

```bash
docker info
docker images
```

Key observations from `docker info`:
- **Storage driver:** `overlayfs` — Docker's layered filesystem
- **Cgroup version:** 2 — Linux resource isolation (used by K8s later)
- **Network drivers available:** bridge, host, overlay, ipvlan, macvlan

Images initially present: `hello-world`, `ubuntu`

---

### Step 2 — Ubuntu Interactive Container

```bash
docker run -it ubuntu bash
```

Commands run inside container:
```bash
whoami       # root
hostname     # container ID (e.g. a3f9d2c1b4e5)
cat /etc/os-release
pwd
ls /
```

Tested filesystem isolation:
```bash
echo "inside container" > test.txt
exit
```

After exiting — `test.txt` on host machine was different. ✅ Proved container filesystem isolation.

> 💡 `-it` = interactive terminal (attach stdin/stdout)
> Container gets its own isolated: filesystem, processes, hostname

---

### Step 3 — Nginx Container

```bash
docker run -d -p 8080:80 --name my-nginx nginx
```

Opened browser → `http://localhost:8080` → **Welcome to nginx!** ✅

**Port mapping explained:**
```
-p 8080:80
    ↑      ↑
  Host   Container
  port    port

Browser → localhost:8080 → Docker maps to → container port 80
```

```bash
# View logs
docker logs my-nginx
```

Observed in logs:
- `GET / HTTP/1.1" 200` → successful page load ✅
- `GET /favicon.ico 404` → normal browser behavior, not a Docker error

---

### Step 4 — Python Interactive Container

```bash
docker run -it python:3.12 python3
```

Commands run inside Python shell:
```python
print("Hello from Docker Container!")
2 + 2
import sys
print(sys.version)
exit()
```

After `exit()` — container stopped automatically. ✅ Proved container lifetime = main process lifetime.

---

### Step 5 — Container Lifecycle Management

```bash
docker stop my-nginx      # stop running container
docker start my-nginx     # start stopped container
docker ps                 # show running containers only
docker ps -a              # show ALL containers including stopped
```

**Key distinction learned:**

| Command | What it does |
|---------|-------------|
| `docker run` | Creates a NEW container from image |
| `docker start` | Starts an EXISTING stopped container |

---

### Step 6 — Image Management

```bash
# Pull image without running
docker pull alpine

# Inspect container/image metadata
docker inspect my-nginx
docker inspect nginx

# View image layers
docker history nginx

# Remove stopped containers
docker container prune
```

`docker inspect` shows:
- Environment variables
- Port bindings
- Entrypoint command
- Network configuration
- Filesystem metadata

> 💡 `docker inspect` is an essential production debugging command!

---

### Step 7 — Volume Mounting (Run Local Code in Container)

```bash
mkdir ~/docker-test
cd ~/docker-test
echo 'print("Hello from Python in Docker!")' > app.py

# Mount local folder into container and run the file
docker run -v $(pwd):/app python:3.12 python3 /app/app.py
```

Output:
```
Hello from Python in Docker!
```

**Volume mount explained:**
```
-v HOST_PATH:CONTAINER_PATH
-v $(pwd):/app

→ Mounts current folder on host → /app inside container
→ Container can read/write host files
```

> 💡 This is how developers run Python, Node.js, Flask, FastAPI
> inside containers while editing local code — live reload!

---

## 💡 Key Concepts I Understood Today

- Docker = package app + dependencies → run identically everywhere
- Image = read-only blueprint, Container = running instance of image
- `Image ≠ Container` — critical distinction
- Container lifetime = main process lifetime — process exits → container stops
- `-it` = interactive terminal, `-d` = detached (background), `-p` = port mapping
- `-v HOST:CONTAINER` = volume mount — share files between host and container
- Docker uses overlayfs — layered filesystem with caching
- Cgroups v2 = Linux resource isolation (CPU/memory limits)
- `docker run` = create new, `docker start` = restart existing
- `docker ps` = running only, `docker ps -a` = all including stopped
- `docker inspect` = full metadata — essential for debugging
- `docker history` = shows image layers — explains build caching
- Containers share host kernel — they are NOT virtual machines
- `docker container prune` = removes stopped containers only, not images

---

## ❌ Mistakes I Made (and Learned From)

| Mistake | Error | What I Learned |
|---------|-------|----------------|
| Typed `sys.info` in Python shell | `AttributeError` | Correct attribute is `sys.version` — `sys.info` doesn't exist |
| Used `<container_id>` literally in docker inspect | Error | `<>` are placeholders — replace with actual container ID or name |
| Tried `docker start python:3.12` | `No such container` | `python:3.12` is an IMAGE not a container — must use container name/ID |
| Used `-dokcer` instead of `-docker` in usermod | `group does not exist` | Caught and fixed typo immediately |

---

## 📚 Docker Commands Reference

| Command | Purpose |
|---------|---------|
| `docker info` | Docker system details |
| `docker images` | List all images |
| `docker ps` | Running containers |
| `docker ps -a` | All containers |
| `docker run` | Create and run container |
| `docker stop` | Stop container |
| `docker start` | Start stopped container |
| `docker logs` | View container logs |
| `docker inspect` | Container/image metadata |
| `docker history` | Image layers |
| `docker pull` | Download image |
| `docker container prune` | Remove stopped containers |
| `docker image prune` | Remove unused images |

---

## 📚 Resources I Used Today

- [Docker Official Docs](https://docs.docker.com/)
- [Docker Hub](https://hub.docker.com/)

---

## ✅ Tomorrow → Day 30: Dockerfile — Writing & Building Custom Images
