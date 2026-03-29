# Day 07 — Review + System Health Monitor Project

![Day](https://img.shields.io/badge/Day-07-yellow?style=flat-square)
![Topic](https://img.shields.io/badge/Topic-Review%20%26%20Final%20Project-blue?style=flat-square)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen?style=flat-square)

> 📅 Date: March 29, 2026
> ⏱️ Time Spent: 3+ hrs
> 🎯 Goal: Review all Week 01 concepts and build a real System Health Monitor script

---

## 📌 Week 01 Quick Review

### Concepts I Can Recall Without Notes ✅

| Question | Answer |
|----------|--------|
| Current directory? | `pwd` |
| What is `chmod 755`? | `-rwxr-xr-x` Owner=rwx, Group=r-x, Others=r-x |
| Show all processes? | `ps aux` or `htop` |
| Check IP address? | `ip addr` or `hostname -I` |
| First line of bash script? | `#!/bin/bash` (shebang) |

---

## 📌 Week 01 Full Summary

### Day 01 — Linux Navigation
```bash
pwd          # where am I?
ls -la       # list files with details
cd /home     # absolute path
cd ..        # go up one level
cd ~         # go home
find . -name "*.sh"   # find files
```

### Day 02 — File Permissions
```bash
chmod 644 file.txt   # rw-r--r-- (normal files)
chmod 755 script.sh  # rwxr-xr-x (scripts)
chmod 400 key.pem    # r-------- (SSH keys)
chown wagge file.txt # change owner
sudo useradd -m user # create user with home
sudo userdel -r user # delete user
```

### Day 03 — Processes & Package Manager
```bash
ps aux            # all processes
ps aux | grep bash # filter processes
kill -9 PID       # force kill
sleep 500 &       # run in background
jobs              # see background jobs
fg 1              # bring to foreground
sudo apt install  # install software
sudo apt remove   # remove software
sudo apt autoremove # clean up
```

### Day 04 — Networking
```bash
ip addr show      # network interfaces + IP
hostname -I       # quick IP
ping google.com -c 4  # test connectivity
curl ifconfig.me  # public IP
nslookup google.com   # DNS lookup
ss -tulpn         # open ports
ssh user@ip       # remote login
sudo ufw allow 22 # firewall rule
```

### Day 05 — Bash Scripting Basics
```bash
#!/bin/bash       # shebang - always first line!
NAME="Wagge"      # variable
echo "$NAME"      # print variable
read INPUT        # user input
if [ $X -gt 10 ]; then ... fi  # condition
for i in 1 2 3; do ... done    # for loop
while [ $X -le 5 ]; do ... done # while loop
greet() { echo "Hello $1"; }   # function
```

### Day 06 — Bash Scripting Advanced
```bash
ARR=("a" "b" "c")    # array
${ARR[0]}             # first element
${ARR[@]}             # all elements
${#ARR[@]}            # length
${VAR^^}              # uppercase
${VAR,,}              # lowercase
${VAR/old/new}        # replace
${VAR:0:6}            # slice
set -e                # exit on error
$?                    # last exit code
tar -czf backup.tar.gz folder/  # compress
```

---

## 📌 Day 07 Final Project — System Health Monitor

```bash
#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status()  { echo -e "${GREEN}[OK]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARN]${NC} $1"; }
print_error()   { echo -e "${RED}[ERROR]${NC} $1"; }

echo "================================"
echo "   SYSTEM HEALTH MONITOR"
echo "   $(date)"
echo "================================"

# System Info
echo "--- System Info ---"
print_status "Hostname: $(hostname)"
print_status "User: $(whoami)"
print_status "Uptime: $(uptime -p)"

# CPU Check
echo "--- CPU Usage ---"
CPU=$(grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {print usage}')
CPU_INT=${CPU%.*}
if [ "$CPU_INT" -gt 80 ]; then
    print_error "CPU usage is HIGH: $CPU%"
else
    print_status "CPU usage is normal: $CPU%"
fi

# Memory
echo "--- Memory Usage ---"
TOTAL=$(free -h | awk 'NR==2{print $2}')
USED=$(free -h | awk 'NR==2{print $3}')
FREE=$(free -h | awk 'NR==2{print $4}')
print_status "Total: $TOTAL | Used: $USED | Free: $FREE"

# Disk Check
echo "--- Disk Usage ---"
DISK=$(df / | awk 'NR==2{print $5}' | cut -d'%' -f1)
if [ "$DISK" -gt 80 ]; then
    print_error "Disk usage is HIGH: $DISK%"
else
    print_status "Disk usage is normal: $DISK%"
fi

# Network
echo "--- Network ---"
IP=$(hostname -I | awk '{print $1}')
print_status "Local IP: $IP"
if ping -c 1 google.com &>/dev/null; then
    print_status "Internet: Connected ✅"
else
    print_error "Internet: Not Connected ❌"
fi

# Top 5 Processes
echo "--- Top 5 Processes ---"
ps aux --sort=-%cpu | awk 'NR>1{print $1, $2, $3"%", $11}' | head -5

echo "================================"
echo "   Health Check Complete!"
echo "================================"
```

**My output:**
```
[OK] Hostname: wagge-HP-Pavilion-Laptop-14-dv2xxx
[OK] User: wagge
[OK] Uptime: up 8 hours, 49 minutes
[OK] CPU usage is normal: 2.21%
[OK] Total: 15Gi | Used: 3.4Gi | Free: 9.7Gi
[OK] Disk usage is normal: 30%
[OK] Local IP: 10.221.247.200
[OK] Internet: Connected ✅
Top 5 processes listed ✅
Health Check Complete! ✅
```

---

## 💡 New Things Learned Today

- [x] Terminal colors using `\033[0;31m` escape codes
- [x] `RED='\033[0;31m'` and `NC='\033[0m'` (reset color)
- [x] `echo -e` enables escape codes in echo
- [x] `/proc/stat` contains live CPU stats
- [x] `${CPU%.*}` removes decimal part from float
- [x] `ping -c 1 google.com &>/dev/null` silent ping check
- [x] `&>/dev/null` suppresses all output

---

## ❌ Mistakes I Made (and Learned From)

| Mistake | Error | What I Learned |
|---------|-------|----------------|
| `[ "$CPU_INT" -gt 80]` | syntax error | Need space before `]` |
| Used `print_error` for normal case | showed red for OK values | Use `print_status` for normal, `print_error` for problems |

---

## 🏆 Week 01 Complete!

```
✅ Day 01 — Linux Navigation & File System
✅ Day 02 — File Permissions & Users
✅ Day 03 — Processes & Package Manager
✅ Day 04 — Networking Basics
✅ Day 05 — Bash Scripting Basics
✅ Day 06 — Bash Scripting Advanced
✅ Day 07 — Review + System Health Monitor
```

> 🎯 Week 01 done! You went from complete Linux beginner to writing real DevOps scripts in 7 days! 💪

---

## 📚 Resources I Used
- [Linux Journey](https://linuxjourney.com)
- [Bash Scripting Tutorial](https://www.youtube.com/watch?v=ZtqBQ68cfJc)

---

## ✅ Next Week → Week 02: Git & GitHub
