# Day 23 — AWS Databases: RDS + DynamoDB

![Day](https://img.shields.io/badge/Day-23-yellow?style=flat-square)
![Topic](https://img.shields.io/badge/Topic-RDS%20%2B%20DynamoDB-orange?style=flat-square)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen?style=flat-square)

> 📅 Date: April 09, 2026
> ⏱️ Time Spent: 3+ hrs
> 🎯 Goal: Understand AWS managed databases — launch RDS MySQL, perform full CRUD via terminal, create DynamoDB table, and operate it via console and CLI

---

## 📌 What I Learned Today

### 1. Why Managed Databases?

**Without managed DB (self-hosted on EC2):**
```
You manage → backups, patches, failover, scaling, crashes 😰
```

**With RDS / DynamoDB:**
```
AWS manages → backups, patches, failover, scaling
You → just use it ✅
```

---

### 2. Key Concepts

#### RDS (Relational Database Service)
AWS's **managed SQL database** — supports MySQL, PostgreSQL, MariaDB, Oracle, SQL Server.

> 💡 Think of RDS as: "MySQL but AWS runs the server for you"

| Term | Meaning |
|------|---------|
| DB Instance | The actual database server |
| DB Subnet Group | Which subnets RDS uses (needs 2+ AZs) |
| Endpoint | Hostname your app connects to |
| Multi-AZ | Standby replica in another AZ for failover |
| Read Replica | Copy for read-heavy workloads |

#### DynamoDB
AWS's **fully managed NoSQL database** — key-value and document store. No servers, no schema, scales automatically.

> 💡 Think of DynamoDB as: "MongoDB but fully serverless — just create a table and use it"

#### RDS vs DynamoDB

| Feature | RDS | DynamoDB |
|---------|-----|----------|
| Type | Relational (SQL) | NoSQL (key-value) |
| Schema | Fixed (tables, columns) | Flexible (any structure) |
| Query type | SQL | Key-based / PartiQL |
| Joins | ✅ Supported | ❌ Not supported |
| Scaling | Vertical | Horizontal (automatic) |
| Free tier | 750 hrs db.t3.micro/month | 25GB + 25 WCU/RCU/month |
| Best for | Complex queries, relationships | Fast lookups, high scale |

---

## 🛠️ Part A — Amazon RDS (MySQL)

### Step 1 — Created VPC & Subnet Group

- Created VPC and subnets across multiple AZs
- Created **DB Subnet Group**: `devops-db-subnet-group`
- Required because RDS needs subnets in at least 2 availability zones

### Step 2 — Launched RDS MySQL Instance

- **Engine:** MySQL 8.0
- **Template:** Free tier
- **DB identifier:** `devops-db`
- **Instance type:** `db.t3.micro`
- **Storage:** 20 GB gp2
- **Credentials:** username `admin` + strong password

### Step 3 — Connected via MySQL CLI

```bash
# Install MySQL client
sudo apt update
sudo apt install mysql-client -y

# Connect to RDS
mysql -h <rds-endpoint> -u admin -p
```

### Step 4 — Full CRUD Operations

```sql
-- Create database
CREATE DATABASE devopsdb;
USE devopsdb;

-- Create table
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100)
);

-- INSERT (Create)
INSERT INTO users (name, email) VALUES ('Pradeep', 'pradeep@example.com');
INSERT INTO users (name, email) VALUES ('DevOps', 'devops@example.com');

-- SELECT (Read)
SELECT * FROM users;

-- UPDATE
UPDATE users SET name='Pradeep Kumar' WHERE id=1;

-- DELETE
DELETE FROM users WHERE id=2;

-- Exit
EXIT;
```

> 💡 This is standard SQL — same syntax works on any MySQL/PostgreSQL database,
> whether on RDS, local machine, or any other server!

---

## 🛠️ Part B — Amazon DynamoDB (NoSQL)

### Step 1 — Created DynamoDB Table

- **Table name:** `devops-users`
- **Partition key:** `userId` (String)
- **Capacity mode:** On-demand (auto-scales, no manual config)

> 💡 Partition key = DynamoDB's primary identifier — every item MUST have it.
> It determines which partition (server) the data lives on — critical for performance!

### Step 2 — CRUD via Console

**Create item:**
```json
{
  "userId": "user001",
  "name": "Pradeep",
  "email": "pradeep@example.com"
}
```

**Update item:**
- Changed `name` → `"Pradeep Kumar"`

**Delete item:**
- Deleted `user002`

**Scan table:**
- Retrieved all items

### Step 3 — CLI Operations

```bash
# List all tables
aws dynamodb list-tables --region ap-south-1

# Get specific item
aws dynamodb get-item \
  --table-name devops-users \
  --key '{"userId": {"S": "user001"}}' \
  --region ap-south-1

# Scan all items
aws dynamodb scan \
  --table-name devops-users \
  --region ap-south-1
```

> 💡 In DynamoDB CLI, data types must be specified explicitly:
> `{"S": "value"}` = String, `{"N": "123"}` = Number, `{"BOOL": true}` = Boolean

---

## 💡 Key Concepts I Understood Today

- RDS = managed SQL database — AWS handles backups, patches, failover
- DynamoDB = serverless NoSQL — no server management at all
- DB Subnet Group = required for RDS, needs subnets in 2+ AZs
- Partition key in DynamoDB = critical — determines data distribution and performance
- RDS endpoint = hostname your app uses to connect (like a domain for the DB)
- SQL CRUD: `INSERT`, `SELECT`, `UPDATE`, `DELETE` — same across all SQL DBs
- DynamoDB CLI requires explicit type annotations: `{"S": "..."}` for strings
- RDS = best for structured relational data with complex queries
- DynamoDB = best for fast key-based lookups at any scale
- On-demand capacity in DynamoDB = auto-scales, no pre-provisioning needed

---

## ❌ Mistakes to Avoid

| Mistake | Issue | What to Remember |
|---------|-------|-----------------|
| Forgetting DB Subnet Group | RDS creation fails | RDS needs subnets in at least 2 AZs |
| Leaving RDS running | Costs money after free tier hours | Always delete RDS instances after practice |
| Missing type annotation in DynamoDB CLI | CLI command fails | Always use `{"S": "..."}` format for string keys |

---

## 🧹 Cleanup After Lab

**RDS is NOT free if left running beyond free tier:**

```
RDS → devops-db → Actions → Delete → uncheck final snapshot → confirm
DynamoDB → devops-users → Delete table
```

---

## 📚 Resources I Used Today

- [AWS RDS Docs](https://docs.aws.amazon.com/rds/)
- [AWS DynamoDB Docs](https://docs.aws.amazon.com/dynamodb/)

---

## ✅ Tomorrow → Day 24: CloudWatch — Logs & Alerts
