# Day 04 — Networking Basics (IP, SSH, DNS)

![Day](https://img.shields.io/badge/Day-04-yellow?style=flat-square)
![Topic](https://img.shields.io/badge/Topic-Networking%20Basics-blue?style=flat-square)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen?style=flat-square)

> 📅 Date: March 28, 2026
> ⏱️ Time Spent: 3+ hrs
> 🎯 Goal: Understand Linux networking — IP addresses, DNS, SSH and ports

---

## 📌 What I Learned Today

### 1. ip addr show — Network Interfaces

```bash
ip addr show
```

**My output had 2 interfaces:**

| Interface | Type | IP |
|-----------|------|----|
| `lo` | Loopback | 127.0.0.1 |
| `wlp1s0` | WiFi | 10.221.247.200 |

```
lo (Loopback):
  inet 127.0.0.1/8  ← computer talking to itself, not real network

wlp1s0 (WiFi):
  inet 10.221.247.200/24  ← my real local IP address!
  inet6 2409:40f2:...     ← IPv6 address
```

> 💡 `wlp1s0` = wireless network card name in Linux

---

### 2. hostname Commands

```bash
hostname
# wagge-HP-Pavilion-Laptop-14-dv2xxx  ← my computer's network name

hostname -I
# 10.221.247.200  ← local IP (WiFi)
# 2409:40f2:...   ← IPv6

hostname -i
# 127.0.0.1  ← loopback address
```

---

### 3. ping — Test Connectivity

```bash
ping google.com -c 4
# PING google.com (2404:6800:4002:830::200e)
# 4 packets transmitted, 4 received, 0% packet loss ✅
# rtt min/avg/max = 55/77/104 ms
```

> `-c 4` = send only 4 packets (without -c it runs forever)
> `0% packet loss` = internet working perfectly!
> `time=77ms` = how long it took Google to reply

---

### 4. curl ifconfig.me — Public IP

```bash
curl ifconfig.me
# 2409:40f2:216f:bc81:2e10:b04:f8e7:2aa8
```

> This is your **public IP** — how the internet sees you!
> Different from local IP (10.221.247.200)

**Difference between IPs:**
| Type | Example | Visible To |
|------|---------|-----------|
| Loopback | 127.0.0.1 | Only your own machine |
| Local IP | 10.221.247.200 | Devices on same WiFi |
| Public IP | 2409:40f2:... | The entire internet |

---

### 5. nslookup — DNS Lookup

```bash
nslookup google.com
# Server: 127.0.0.53 (my local DNS resolver)
# google.com → 142.251.223.206 (IPv4)
# google.com → 2404:6800:4002:820::200e (IPv6)
```

> DNS converts domain names → IP addresses
> Think of DNS like a **phonebook** 📖
> You look up "google.com" → get back "142.251.223.206"

---

### 6. traceroute — Network Path

```bash
traceroute google.com
# 1  _gateway (10.221.247.197)  28ms ✅  ← my WiFi router
# 2-30  * * *  ← routers blocking traceroute (normal!)
```

> Shows every "hop" your data takes to reach destination
> Hop 1 = your router
> `* * *` = that router blocks traceroute for security — totally normal!

---

### 7. Important Port Numbers

```bash
cat /etc/services | head -20
# Shows all standard port → service mappings
```

**Must memorise for DevOps:**
| Port | Service | Use |
|------|---------|-----|
| `22` | SSH | Remote server login |
| `80` | HTTP | Websites |
| `443` | HTTPS | Secure websites |
| `3306` | MySQL | Database |
| `5432` | PostgreSQL | Database |
| `27017` | MongoDB | Database |
| `6379` | Redis | Cache |
| `8080` | HTTP-alt | Dev servers |

---

### 8. ss -tulpn — Open Ports

```bash
ss -tulpn
# Shows all listening ports on your system
# udp  0.0.0.0:5353  ← mDNS
# tcp  127.0.0.1:631 ← CUPS printer
# tcp  0.0.0.0:22    ← SSH (after installing!)
```

**Flags meaning:**
| Flag | Meaning |
|------|---------|
| `-t` | TCP connections |
| `-u` | UDP connections |
| `-l` | Listening ports only |
| `-p` | Show process name |
| `-n` | Show numbers not names |

---

### 9. SSH — Secure Shell

SSH lets you **remotely control another computer** via terminal — fully encrypted!

```bash
sudo apt install openssh-server   # Install SSH server
sudo systemctl start ssh          # Start SSH now
sudo systemctl enable ssh         # Start SSH on every boot
sudo systemctl status ssh         # Check if running
```

**My status output:**
```
● ssh.service - OpenBSD Secure Shell server
Active: active (running) ✅
Loaded: enabled ✅
Main PID: 9801
Server listening on 0.0.0.0 port 22 ✅
Server listening on :: port 22 ✅
```

**SSH into my own machine:**
```bash
ssh wagge@localhost
# The authenticity of host 'localhost' can't be established
# Are you sure? yes
# Warning: Permanently added 'localhost' to known hosts ✅
# wagge@localhost's password: ****
# Welcome to Ubuntu 24.04.4 LTS! ✅
```

**Basic SSH commands:**
```bash
ssh username@ip-address           # Basic SSH
ssh ubuntu@54.123.45.67          # SSH to AWS server
ssh -i mykey.pem ubuntu@54.x.x.x # SSH with key file (AWS way)
exit                              # Close SSH session
# Connection to localhost closed ✅
```

> 💡 First time connecting → SSH asks about fingerprint → type `yes`
> After that it remembers and never asks again!

---

### 10. UFW — Firewall

```bash
sudo ufw status
# Status: inactive  (off by default)

sudo ufw enable           # Turn on
sudo ufw allow 22         # Allow SSH ← ALWAYS do this before enabling!
sudo ufw allow 80         # Allow HTTP
sudo ufw allow 443        # Allow HTTPS
sudo ufw deny 3306        # Block MySQL
sudo ufw status           # Check rules
sudo ufw disable          # Turn off
```

> ⚠️ Always allow port 22 BEFORE enabling UFW — otherwise you lock yourself out of SSH!

---

### 11. DNS Configuration Files

#### /etc/resolv.conf — DNS Server
```bash
cat /etc/resolv.conf
# nameserver 127.0.0.53  ← local DNS resolver
```
> Tells your system which DNS server to use
> `127.0.0.53` = systemd local resolver → forwards to router → internet

#### /etc/hosts — Local DNS
```bash
cat /etc/hosts
# 127.0.0.1 localhost
# 127.0.1.1 wagge-HP-Pavilion-Laptop-14-dv2xxx
```
> Checked BEFORE any DNS server!
> You can add custom entries:
```
192.168.1.10 myserver  ← then 'ping myserver' works!
```

---

### 12. How DNS Works (Full Flow)

```
You type: google.com
    ↓
1. Check /etc/hosts first
    ↓
2. Ask 127.0.0.53 (local resolver)
    ↓
3. Ask your router (10.221.247.197)
    ↓
4. Ask internet DNS servers
    ↓
Returns: 142.251.223.206
    ↓
Your browser connects to that IP!
```

---

## 💡 Key Concepts I Understood Today

- [x] Every device has a local IP (seen on network) and public IP (seen on internet)
- [x] `127.0.0.1` = loopback = your machine talking to itself
- [x] DNS converts domain names to IP addresses like a phonebook
- [x] Every service runs on a specific port number
- [x] SSH runs on port 22 — used to control remote servers
- [x] `/etc/hosts` is checked before any DNS server
- [x] `/etc/resolv.conf` tells system which DNS server to use
- [x] `traceroute` shows path to destination — `* * *` = blocked (normal!)
- [x] UFW is Ubuntu's firewall — always allow port 22 before enabling!
- [x] `systemctl start/enable/status` manages system services

---

## ❌ Mistakes I Made (and Learned From)

| Mistake | What I Learned |
|---------|----------------|
| `curl ifconfig.me` showed IPv6 not IPv4 | My ISP uses IPv6 — both are valid public IPs |
| traceroute showed `* * *` after hop 1 | Normal! Routers block traceroute for security |

---

## 📚 Resources I Used Today
- [Linux Journey — Networking](https://linuxjourney.com/lesson/network-basics)
- [SSH Basics](https://www.ssh.com/academy/ssh/command)

---

## ✅ Tomorrow → Day 05: Bash Scripting Basics
