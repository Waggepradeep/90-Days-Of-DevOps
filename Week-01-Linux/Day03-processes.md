# Day 03 — Processes & Package Manager

![Day](https://img.shields.io/badge/Day-03-yellow?style=flat-square)
![Topic](https://img.shields.io/badge/Topic-Processes%20%26%20Package%20Manager-blue?style=flat-square)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen?style=flat-square)

> 📅 Date: March 27, 2026
> ⏱️ Time Spent: 3+ hrs
> 🎯 Goal: Understand Linux processes and how to manage software using apt

---

## 📌 What I Learned Today

### 1. ps — Process Status

```bash
ps
# Shows only processes in current terminal session
# PID   TTY    TIME  CMD
# 3830  pts/0  bash
# 6239  pts/0  ps

ps aux
# Shows ALL processes running on the system
```

**ps aux columns explained:**

| Column | Meaning |
|--------|---------|
| `USER` | Who owns the process |
| `PID` | Process ID — unique number for each process |
| `%CPU` | How much CPU it's using |
| `%MEM` | How much RAM it's using |
| `STAT` | State: S=sleeping, R=running, I=idle |
| `COMMAND` | What program is running |

> 💡 All those `[kworker]`, `[kthreadd]` processes owned by root are Linux kernel processes — totally normal!

---

### 2. Filtering Processes with grep

```bash
ps aux | grep bash
# wagge  3830  bash   ← your terminal session
# wagge  6421  grep --color=auto bash  ← the grep command itself
```

> `|` is called a **pipe** — sends output of one command into another
> `grep` filters and shows only lines containing what you search for

---

### 3. top — Live Process Viewer

```bash
top
```

**What I saw on MY system:**
```
Tasks: 303 total, 1 running, 302 sleeping
%Cpu: 1.5 us, 97.5 id   ← 97.5% CPU is idle (free!)
MiB Mem: 15660.1 total, 10608.9 free, 2695.0 used
```

**Top processes on my system:**
| Process | CPU% | Meaning |
|---------|------|---------|
| `gnome-shell` | 9.3% | Desktop UI |
| `firefox` | 6.6% | Browser |

**Useful keys in top:**
| Key | Action |
|-----|--------|
| `q` | Quit |
| `k` | Kill a process |
| `M` | Sort by memory |
| `P` | Sort by CPU |

---

### 4. htop — Better Interactive Process Viewer

```bash
sudo apt install htop
htop
```

> htop is much better than top — shows CPU cores as bars, color coded, easier to use!

**What I saw:**
```
12 CPU core bars at top
Mem: 2.17G/15.3G used
Tasks: 121, 629 threads
Uptime: 01:57:12
```

**Useful keys in htop:**
| Key | Action |
|-----|--------|
| `q` | Quit |
| `F3` | Search process |
| `F9` | Kill process |
| `F6` | Sort by column |

---

### 5. Killing Processes

```bash
sleep 1000 &        # Start process in background → got PID 6481
ps aux | grep sleep # Find it → PID 6481

kill 6481           # Politely ask process to stop
kill -9 6481        # Force kill — no questions asked! ⚡
```

**Difference:**
| Command | Meaning |
|---------|---------|
| `kill <PID>` | Send SIGTERM — polite stop request |
| `kill -9 <PID>` | Send SIGKILL — immediate force kill |

**What I practiced:**
```bash
sleep 2000 &   # PID 7660
sleep 5000 &   # PID 7664
kill -9 7664   # → [2]+ Killed sleep 5000 ✅
kill -9 7600   # → No such process ❌ (already dead from before)
```

---

### 6. Background & Foreground Jobs

```bash
sleep 500 &     # Run in background → [1] 9721
jobs            # See all background jobs → [1]+ Running sleep 500 &
fg 1            # Bring job 1 to foreground
# press Ctrl+C  # Kill it ✅
```

| Command | Meaning |
|---------|---------|
| `&` | Run command in background |
| `jobs` | List background jobs |
| `fg <n>` | Bring job number n to foreground |
| `bg <n>` | Send job to background |
| `Ctrl+C` | Kill foreground process |
| `Ctrl+Z` | Pause foreground process |

---

### 7. apt — Package Manager

apt is how you install/remove software on Ubuntu — like an app store but for terminal!

```bash
sudo apt update                  # Refresh package list (always do this first!)
sudo apt install <package>       # Install a package
sudo apt remove <package>        # Remove a package
sudo apt autoremove              # Remove leftover unused packages
sudo apt upgrade                 # Update all installed packages
```

**What I practiced:**
```bash
sudo apt install htop    # ✅ Installed htop
sudo apt install tree    # ✅ Installed tree
sudo apt install cowsay  # ✅ Installed cowsay

cowsay "I am learning DevOps!"
# < I am learning DevOps! >
#         \   ^__^
#          \  (oo)\_______  😄

sudo apt remove cowsay    # ✅ Removed cowsay (freed 93.2KB)
sudo apt autoremove       # ✅ Removed leftover packages (freed 297MB!)
```

---

### 8. tree — Visual Folder Structure

```bash
tree
# Shows entire folder structure visually
# 58 directories, 34 files in my home folder
```

---

## 💡 Key Concepts I Understood Today

- [x] Every running program is a **process** with a unique PID
- [x] `ps aux` shows ALL processes on the system
- [x] `|` pipe sends output of one command to another
- [x] `grep` filters output to find what you need
- [x] `top` and `htop` show live process info
- [x] `kill <PID>` politely stops a process
- [x] `kill -9 <PID>` force kills immediately
- [x] `&` runs a process in the background
- [x] `jobs` shows background jobs
- [x] `fg` brings background job to foreground
- [x] `Ctrl+C` kills a running process
- [x] `apt` is Ubuntu's package manager
- [x] Always run `sudo apt update` before installing anything

---

## ❌ Mistakes I Made (and Learned From)

| Mistake | Error | What I Learned |
|---------|-------|----------------|
| `kill -9 7600` | No such process | Process was already dead from earlier — not an error! |

---

## 📚 Resources I Used Today
- [Linux Journey — Processes](https://linuxjourney.com/lesson/monitor-processes-ps-command)
- [Linux Journey — Package Management](https://linuxjourney.com/lesson/software-distribution)

---

## ✅ Tomorrow → Day 04: Networking Basics (IP, SSH, DNS)
