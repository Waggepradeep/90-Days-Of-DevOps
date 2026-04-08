# Day 19 — AWS VPC: Subnets, Route Tables & Internet Gateway

![Day](https://img.shields.io/badge/Day-19-yellow?style=flat-square)
![Topic](https://img.shields.io/badge/Topic-AWS%20VPC-orange?style=flat-square)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen?style=flat-square)

> 📅 Date: April 08, 2026
> ⏱️ Time Spent: 3+ hrs
> 🎯 Goal: Build a custom VPC from scratch with public and private subnets, Internet Gateway, and route tables — understanding how AWS networking works under the hood

---

## 📌 What I Learned Today

### 1. What is VPC?

**VPC (Virtual Private Cloud)** is your own private network inside AWS.

```
AWS = a massive apartment building
VPC = your private flat inside that building
EC2, RDS, S3 = furniture inside your flat
```

> 💡 Every AWS account gets a default VPC automatically.
> When EC2 was launched on Day 17, it was already running inside a VPC — just didn't know it!

---

### 2. Key VPC Concepts

#### VPC
A **logically isolated private network** in AWS where you launch resources.
- You define the IP range using **CIDR notation**
- `10.0.0.0/16` = 65,536 available IP addresses

#### Subnets
A **subdivision** of your VPC — splits the network into smaller chunks.

| Type | Internet Access | Use Case |
|------|----------------|----------|
| Public Subnet | ✅ Yes | Web servers, load balancers |
| Private Subnet | ❌ No | Databases, backend servers |

```
VPC (10.0.0.0/16)
├── Public Subnet  (10.0.1.0/24) → Web servers
└── Private Subnet (10.0.2.0/24) → Databases
```

#### Internet Gateway (IGW)
A **door** that connects your VPC to the internet.
- Without IGW → VPC is completely isolated from internet
- Attach IGW to VPC → internet traffic can flow in and out
- ⚠️ IGW is useless until attached to a VPC!

#### Route Tables
**Rules** that tell network traffic where to go — like a GPS for packets.

| Destination | Target | Meaning |
|-------------|--------|---------|
| `10.0.0.0/16` | local | Stay inside VPC |
| `0.0.0.0/0` | igw-xxx | Everything else → go to internet |

#### How They All Connect

```
Internet
    ↓
Internet Gateway (IGW)
    ↓
Route Table (0.0.0.0/0 → IGW)
    ↓
Public Subnet
    ↓
EC2 Instance
```

---

### 3. Public Subnet vs Private Subnet

For a subnet to be truly **public**, it needs ALL THREE:

```
✅ Internet Gateway attached to VPC
✅ Route table with 0.0.0.0/0 → IGW
✅ Route table associated with the subnet
```

Missing even one → subnet has no internet access!

---

### 4. What I Built Today

```
devops-vpc (10.0.0.0/16)
├── devops-public-subnet (10.0.1.0/24)
│     → devops-public-rt → devops-igw → Internet ✅
│
└── devops-private-subnet (10.0.2.0/24)
      → Main Route Table → No Internet ❌
```

---

### 5. Steps I Performed

#### Step 1 — Created VPC
- **Name:** `devops-vpc`
- **IPv4 CIDR:** `10.0.0.0/16`
- Resources to create: VPC only

#### Step 2 — Created Subnets

**Public Subnet:**
- Name: `devops-public-subnet`
- CIDR: `10.0.1.0/24`
- AZ: `ap-south-1a`
- ✅ Enabled **auto-assign public IP** (so EC2 launched here gets a public IP automatically)

**Private Subnet:**
- Name: `devops-private-subnet`
- CIDR: `10.0.2.0/24`
- AZ: `ap-south-1a`
- ❌ No public IP assignment

#### Step 3 — Created & Attached Internet Gateway
- Name: `devops-igw`
- Created → Actions → **Attach to VPC** → selected `devops-vpc`

#### Step 4 — Created Route Table
- Name: `devops-public-rt`
- VPC: `devops-vpc`
- Routes tab → Edit routes → Add route:
  - Destination: `0.0.0.0/0`
  - Target: Internet Gateway → `devops-igw`

#### Step 5 — Associated Route Table with Public Subnet
- `devops-public-rt` → Subnet associations tab → Edit
- Selected `devops-public-subnet` ✅
- Private subnet deliberately left with main route table (no internet)

#### Step 6 — Verified with Resource Map
- VPC Console → `devops-vpc` → Resource Map tab
- Confirmed full architecture visually ✅

---

## 💡 Key Concepts I Understood Today

- VPC = private isolated network in AWS — all resources live inside it
- Subnets = subdivisions of VPC (public = internet access, private = no internet)
- Internet Gateway = the door between VPC and internet
- Route table = GPS for network traffic — tells packets where to go
- `0.0.0.0/0` = "everything else" — default route to internet via IGW
- Public subnet needs 3 things: IGW + route + subnet association
- Private subnet should NOT be associated with the public route table
- Auto-assign public IP on subnet = EC2 launched there gets a public IP automatically
- Resource Map = best way to visually verify VPC architecture
- CIDR `/16` = 65,536 IPs, `/24` = 256 IPs

---

## ❌ Mistakes I Made (and Learned From)

| Mistake | Error | What I Learned |
|---------|-------|----------------|
| Forgot to set target while adding route | Route `0.0.0.0/0` had no target | Must select Internet Gateway as the target — destination alone is not enough |
| Thought route table alone was enough | Subnet still had no internet | Route table must also be **associated** with the subnet |
| Almost associated private subnet with public RT | Would have exposed private subnet | Private subnet must stay with main route table — never associate with public RT |

---

## 📚 Resources I Used Today

- [AWS VPC Docs](https://docs.aws.amazon.com/vpc/)
- [AWS VPC Subnets Guide](https://docs.aws.amazon.com/vpc/latest/userguide/configure-subnets.html)

---

## ✅ Tomorrow → Day 20: AWS CLI Setup & Basic Commands
