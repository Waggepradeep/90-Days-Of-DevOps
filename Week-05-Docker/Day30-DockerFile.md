# Day 30 — Dockerfile: Writing & Building Custom Images

![Day](https://img.shields.io/badge/Day-30-yellow?style=flat-square)
![Topic](https://img.shields.io/badge/Topic-Dockerfile%20%2B%20Custom%20Images-orange?style=flat-square)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen?style=flat-square)

> 📅 Date: May 11, 2026
> ⏱️ Time Spent: 3+ hrs
> 🎯 Goal: Write Dockerfiles, build custom images, containerize a Flask app, understand layer caching, image versioning, and the full Docker development workflow

---

## 📌 What I Learned Today

### 1. What Changed from Day 29 → Day 30

```
Day 29: Using existing Docker images (nginx, python, ubuntu)
              ↓
Day 30: Building custom Docker images from scratch ✅
```

> 💡 In real DevOps — you never ship someone else's image.
> You package YOUR app into YOUR image using a Dockerfile!

---

### 2. Dockerfile Instructions

| Instruction | Purpose | Example |
|-------------|---------|---------|
| `FROM` | Base image to start from | `FROM python:3.12-slim` |
| `WORKDIR` | Set working directory inside container | `WORKDIR /app` |
| `COPY` | Copy files from host into image | `COPY requirements.txt .` |
| `RUN` | Execute command during build | `RUN pip install -r requirements.txt` |
| `EXPOSE` | Document which port app uses | `EXPOSE 5000` |
| `ENV` | Set environment variables | `ENV DEBUG=false` |
| `CMD` | Default command when container starts | `CMD ["python", "app.py"]` |

---

### 3. RUN vs CMD

```
RUN → executes during IMAGE BUILD   (e.g. install packages)
CMD → executes when CONTAINER STARTS (e.g. start your app)
```

---

### 4. Layer Caching — Why Order Matters

**Wrong order (slow builds):**
```dockerfile
COPY . .                          ← any code change breaks cache here
RUN pip install -r requirements.txt  ← reinstalls EVERY TIME
```

**Correct order (fast builds):**
```dockerfile
COPY requirements.txt .           ← only changes when deps change
RUN pip install -r requirements.txt  ← cached unless requirements change
COPY . .                          ← code changes don't affect pip cache
```

> 💡 This is a critical CI/CD optimization — correct layer ordering
> means pip install is cached and skipped on every code-only change!

---

### 5. Image Sizes — slim vs full

| Image | Size |
|-------|------|
| `python:3.12` | ~1.62 GB |
| `python:3.12-slim` | ~179 MB |
| `python:3.12-alpine` | ~50 MB |

> 💡 Always use `-slim` or `-alpine` in production:
> smaller attack surface, faster pulls, lower storage costs.
> Full image only for local development.

---

### 6. Health Endpoints in Production

`/health` endpoint is not just for testing — it's used by:
- Kubernetes liveness/readiness probes
- Load balancers (ALB health checks from Day 22)
- Monitoring systems
- Auto-healing infrastructure

---

## 🛠️ Steps I Performed

### Step 1 — Created Project Structure

```bash
mkdir ~/day30-docker
cd ~/day30-docker
```

**Files created:**
```
day30-docker/
├── app.py
├── requirements.txt
├── Dockerfile
└── .dockerignore
```

---

### Step 2 — Flask Application

**`app.py`:**
```python
from flask import Flask

app = Flask(__name__)

@app.route("/")
def home():
    return """
    <html>
    <body style="background:#0f172a;color:#e2e8f0;font-family:Arial;text-align:center;padding:60px">
        <h1 style="color:#38bdf8">🐳 Hello from Docker!</h1>
        <p>Day 30 — Dockerfile Practice</p>
        <p>90 Days of DevOps — Pradeep</p>
    </body>
    </html>
    """

@app.route("/health")
def health():
    return {"status": "healthy", "day": 30}

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
```

**`requirements.txt`:**
```
flask==3.0.0
```

---

### Step 3 — Dockerfile

```dockerfile
# Base image — slim for smaller size
FROM python:3.12-slim

# Set working directory inside container
WORKDIR /app

# Copy requirements FIRST — for layer caching
COPY requirements.txt .

# Install dependencies (cached unless requirements.txt changes)
RUN pip install --no-cache-dir -r requirements.txt

# Copy rest of app (code changes only rebuild from here)
COPY . .

# Document the port
EXPOSE 5000

# Start the app
CMD ["python", "app.py"]
```

**`.dockerignore`:**
```
__pycache__
*.pyc
.git
.env
```

---

### Step 4 — Built Image

```bash
docker build -t devops-app:v1 .
```

Observed each step creating a layer:
```
Step 1/7 : FROM python:3.12-slim
Step 2/7 : WORKDIR /app
Step 3/7 : COPY requirements.txt .
Step 4/7 : RUN pip install...
Step 5/7 : COPY . .
Step 6/7 : EXPOSE 5000
Step 7/7 : CMD ["python", "app.py"]
```

```bash
# Verify image created
docker images
```

---

### Step 5 — Ran and Tested Container

```bash
docker run -d -p 5000:5000 --name devops-flask devops-app:v1
```

- Browser → `http://localhost:5000` → Flask app loaded ✅
- Browser → `http://localhost:5000/health` → `{"status":"healthy","day":30}` ✅

```bash
# Check logs
docker logs devops-flask
```

Observed in logs:
- Flask startup output
- `GET / HTTP/1.1" 200` → successful requests
- `GET /favicon.ico 404` → normal browser behavior, not a Docker issue

---

### Step 6 — Layer Caching Observed

Modified `app.py` (code change only) → rebuilt:

```bash
docker build -t devops-app:v2 .
```

Output:
```
Step 1/7 → CACHED ✅
Step 2/7 → CACHED ✅
Step 3/7 → CACHED ✅
Step 4/7 → CACHED ✅  ← pip install NOT re-run!
Step 5/7 → rebuilt   ← only rebuilds from COPY . . onwards
```

✅ Proved layer caching works — requirements unchanged = pip cached!

---

### Step 7 — Entered Running Container

```bash
docker exec -it devops-flask bash
```

Inside container:
```bash
pwd       # /app
ls        # app.py requirements.txt Dockerfile
cat app.py
```

✅ Verified app files exist inside container

---

### Step 8 — docker stats

```bash
docker stats
```

Observed:
- CPU usage (very low)
- Memory usage (minimal)
- Network I/O

> 💡 Flask container used very little resources — containers are truly lightweight!

---

### Step 9 — docker inspect

```bash
docker inspect devops-flask
```

Observed:
- Container ID
- Environment variables
- Port bindings
- Filesystem paths
- Working directory
- Network configuration
- Runtime metadata

---

### Step 10 — Cleanup

```bash
docker stop devops-flask
docker rm devops-flask
docker rmi devops-app:v1 devops-app:v2
docker container prune
```

Confirmed: deleting containers does NOT delete images — they are separate objects.

---

## 💡 Key Concepts I Understood Today

- Dockerfile = step-by-step recipe for building a custom Docker image
- Each Dockerfile instruction creates an image layer
- `RUN` = build time (install packages), `CMD` = runtime (start app)
- Layer ordering matters — copy requirements before code for pip caching
- `.dockerignore` = exclude unnecessary files from build context
- `-slim` images are ~9x smaller than full images — always use in production
- `docker exec -it container bash` = enter a running container
- `docker stats` = live resource usage (CPU, memory, network)
- Health endpoints (`/health`) are used by K8s probes and load balancers
- Images are reusable templates — one image → unlimited containers
- Deleting containers ≠ deleting images — separate objects
- Slim images remove Linux utilities — `ps`, `curl` etc. not available by default

---

## ❌ Mistakes I Made (and Learned From)

| Mistake | Error | What I Learned |
|---------|-------|----------------|
| Tried `docker run ubuntu` without `-it` | Container exited immediately — nothing appeared | Ubuntu needs `-it bash` to stay alive — bash exits without interactive terminal |
| Stopped container then tried creating new one with same name | `container name already in use` | Must `docker rm container_name` before reusing the name |
| Ran `ps aux` inside slim container | `ps: command not found` | Slim images strip non-essential utilities — trade convenience for smaller size |

---

## 🔄 Complete Docker Workflow Learned

```
Write App
    ↓
Write Dockerfile
    ↓
Build Image (docker build)
    ↓
Version Image (v1, v2...)
    ↓
Run Container (docker run)
    ↓
Expose Ports (-p)
    ↓
Access in Browser
    ↓
Update App → Rebuild → Redeploy
    ↓
Inspect Logs (docker logs)
    ↓
Debug Container (docker exec)
    ↓
Monitor Resources (docker stats)
    ↓
Cleanup (docker stop → rm → rmi)
```

---

## 📚 Docker Commands Reference

| Command | Purpose |
|---------|---------|
| `docker build -t name:tag .` | Build image from Dockerfile |
| `docker run -d -p host:container` | Run container detached with port |
| `docker exec -it container bash` | Enter running container |
| `docker logs container` | View container stdout/stderr |
| `docker stats` | Live resource usage |
| `docker inspect container` | Full metadata |
| `docker stop / rm / rmi` | Stop, remove container, remove image |
| `docker container prune` | Remove all stopped containers |

---

## 📚 Resources I Used Today

- [Dockerfile Reference](https://docs.docker.com/engine/reference/builder/)
- [Docker Best Practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)

---

## ✅ Tomorrow → Day 31: Docker Volumes & Networks
