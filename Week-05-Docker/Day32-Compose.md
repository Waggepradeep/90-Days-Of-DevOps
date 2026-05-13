# Day 32 — Docker Compose: Multi-Container Apps

![Day](https://img.shields.io/badge/Day-32-yellow?style=flat-square)
![Topic](https://img.shields.io/badge/Topic-Docker%20Compose-orange?style=flat-square)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen?style=flat-square)

> 📅 Date: May 11, 2026
> ⏱️ Time Spent: 3+ hrs
> 🎯 Goal: Use Docker Compose to manage multi-container apps with a single YAML file — replace all manual docker run commands with one declarative config

---

## 📌 What I Learned Today

### 1. What Problem Does Docker Compose Solve?

**Day 31 — Manual approach (6+ commands):**
```bash
docker network create devops-network
docker volume create mysql-data
docker run -d --name mysql-db --network ... -e ... -v ... mysql:8.0
docker run -d --name flask-app --network ... -p 5000:5000 devops-app:v3
```

**Day 32 — Docker Compose (1 command):**
```bash
docker compose up   # starts EVERYTHING ✅
docker compose down # stops EVERYTHING ✅
```

> 💡 Docker Compose = define your entire app stack in one YAML file.
> Networks, volumes, environment variables, ports — all in one place!

---

### 2. Core Concepts

#### Service Discovery (Most Important!)
Inside Docker Compose, the **service name = hostname**.

```yaml
services:
  mysql:    ← service name
  app:      ← service name
```

Flask connects to MySQL using:
```python
host = "mysql"   ← the service name, not localhost or container ID!
```

> ⚠️ This is the #1 mistake people make — using `localhost` or wrong name.
> Compose networking automatically resolves service names as DNS hostnames!

#### Auto Networking
Compose automatically creates a network — no `docker network create` needed:
```
day32-compose_devops-network  ← auto-created
```

#### Auto Volume Management
Compose automatically creates named volumes defined in the file:
```
day32-compose_mysql-data  ← auto-created
```

#### Database Initialization
MySQL automatically runs SQL scripts placed in:
```
/docker-entrypoint-initdb.d/
```
Mount `init.sql` there → tables and data created on first startup!

---

### 3. Compose vs Manual docker run

| | Manual `docker run` | Docker Compose |
|--|--------------------|----|
| Start | 6+ long commands | `docker compose up` |
| Stop | Multiple commands | `docker compose down` |
| Networking | Manual `docker network create` | Auto-created |
| Volumes | Manual `docker volume create` | Defined in YAML |
| Reproducible | ❌ Easy to forget flags | ✅ Everything in one file |
| Team sharing | ❌ Document every flag | ✅ Share the YAML file |

---

### 4. Key Compose Commands

| Command | Purpose |
|---------|---------|
| `docker compose up` | Start all services (foreground) |
| `docker compose up -d` | Start in background |
| `docker compose up --build` | Rebuild images then start |
| `docker compose down` | Stop + remove containers + network |
| `docker compose down -v` | Stop + remove volumes too |
| `docker compose down -v --rmi all` | Remove everything including images |
| `docker compose ps` | List running services |
| `docker compose logs` | View all logs |
| `docker compose logs -f` | Follow logs live |
| `docker compose logs app` | Logs for specific service |
| `docker compose exec service cmd` | Run command in service |
| `docker compose restart app` | Restart specific service |
| `docker compose top` | View processes inside containers |

---

## 🛠️ Steps I Performed

### Step 1 — Project Structure

```
day32-compose/
├── app.py
├── requirements.txt
├── Dockerfile
├── init.sql
└── docker-compose.yml
```

---

### Step 2 — Flask App (`app.py`)

```python
from flask import Flask, jsonify
import mysql.connector
import os

app = Flask(__name__)

def get_db():
    return mysql.connector.connect(
        host=os.environ.get("DB_HOST", "mysql"),
        user=os.environ.get("DB_USER", "devops"),
        password=os.environ.get("DB_PASSWORD", "devpass"),
        database=os.environ.get("DB_NAME", "devopsdb")
    )

@app.route("/")
def home():
    return "<h1>🐳 Docker Compose App</h1><a href='/users'>View Users</a>"

@app.route("/health")
def health():
    return jsonify({"status": "healthy", "day": 32})

@app.route("/users")
def users():
    try:
        conn = get_db()
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM users")
        rows = cursor.fetchall()
        return jsonify([{"id": r[0], "name": r[1]} for r in rows])
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
```

---

### Step 3 — Supporting Files

**`requirements.txt`:**
```
flask==3.0.0
mysql-connector-python==8.3.0
```

**`Dockerfile`:**
```dockerfile
FROM python:3.12-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
EXPOSE 5000
CMD ["python", "app.py"]
```

**`init.sql`** (auto-runs on first MySQL startup):
```sql
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100)
);

INSERT INTO users (name) VALUES ('Pradeep');
INSERT INTO users (name) VALUES ('DevOps');
INSERT INTO users (name) VALUES ('Docker');
```

---

### Step 4 — docker-compose.yml

```yaml
version: "3.8"

services:

  mysql:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: rootpass
      MYSQL_DATABASE: devopsdb
      MYSQL_USER: devops
      MYSQL_PASSWORD: devpass
    volumes:
      - mysql-data:/var/lib/mysql
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql
    networks:
      - devops-network
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      interval: 10s
      timeout: 5s
      retries: 5

  app:
    build: .
    ports:
      - "5000:5000"
    environment:
      DB_HOST: mysql
      DB_USER: devops
      DB_PASSWORD: devpass
      DB_NAME: devopsdb
    depends_on:
      mysql:
        condition: service_healthy
    networks:
      - devops-network
    volumes:
      - .:/app

volumes:
  mysql-data:

networks:
  devops-network:
    driver: bridge
```

> 💡 `depends_on` with `condition: service_healthy` = Flask waits for MySQL
> to be FULLY READY before starting — not just "container started"!

---

### Step 5 — Started and Tested

```bash
docker compose up -d
docker compose ps
```

**Routes tested:**

| Route | Result |
|-------|--------|
| `http://localhost:5000` | Home page ✅ |
| `http://localhost:5000/health` | `{"status":"healthy","day":32}` ✅ |
| `http://localhost:5000/users` | Users from MySQL ✅ |

---

### Step 6 — Explored Compose Features

```bash
# View all logs
docker compose logs

# Follow live
docker compose logs -f

# Specific service
docker compose logs app
docker compose logs mysql

# Enter MySQL shell
docker compose exec mysql mysql -u devops -pdevpass devopsdb
```

Inside MySQL:
```sql
show tables;
select * from users;
```

```bash
# Enter Flask shell
docker compose exec app bash

# View processes
docker compose top

# Restart Flask service
docker compose restart app
```

---

### Step 7 — Scaling Attempt

```bash
docker compose up -d --scale app=3
```

**Failed** — two reasons:
1. Fixed port `5000:5000` can't be shared by multiple containers
2. Custom container name prevents duplicate containers

> 💡 This is exactly the problem Kubernetes solves — it handles scaling
> with dynamic port routing and load balancing automatically!

---

### Step 8 — Cleanup

```bash
docker compose down       # remove containers + network
docker compose down -v    # also remove volumes
```

Kept images for future use — did NOT run `--rmi all`.

---

## 💡 Key Concepts I Understood Today

- Docker Compose = manage entire multi-container app with one YAML file
- Service name = DNS hostname inside Compose network (critical!)
- `host="mysql"` not `host="localhost"` — service name is the hostname
- Compose auto-creates networks and volumes — no manual commands needed
- `init.sql` mounted at `/docker-entrypoint-initdb.d/` = auto DB initialization
- `depends_on: condition: service_healthy` = proper startup ordering
- `docker compose up --build` = rebuild image + start (use after code changes)
- Scaling fails with fixed ports + custom container names → Kubernetes solves this
- `docker compose down` keeps volumes, `docker compose down -v` removes them
- Compose YAML is shareable — whole team runs same stack with one command

---

## ❌ Mistakes I Made (and Learned From)

| Mistake | Error | What I Learned |
|---------|-------|----------------|
| Used `host="db"` in Flask but service was named `mysql` | 500 error — connection failed | Service name in YAML = hostname. Always match exactly |
| Typed SQL without semicolons (`show tables`) | MySQL error — invalid syntax | Always end SQL statements with `;` |
| Tried `docker compose up --scale app=3` with fixed port | Compose warning — scaling prevented | Fixed ports + custom names block scaling — Kubernetes handles this properly |

---

## 🏗️ Final Architecture

```
docker-compose.yml
├── mysql service
│     ├── image: mysql:8.0
│     ├── volume: mysql-data → /var/lib/mysql (persistent)
│     ├── init.sql → auto creates table + data
│     └── healthcheck → ready signal for Flask
└── app service
      ├── build: . (custom Flask image)
      ├── depends_on: mysql (waits for healthy)
      ├── port: 5000:5000
      └── env: DB_HOST=mysql (service name as hostname)

Both on devops-network → talk by service name via Docker DNS
```

---

## 📚 Resources I Used Today

- [Docker Compose Docs](https://docs.docker.com/compose/)
- [Compose File Reference](https://docs.docker.com/compose/compose-file/)

---

## ✅ Tomorrow → Day 33: Docker Hub + ECR — Image Registry
