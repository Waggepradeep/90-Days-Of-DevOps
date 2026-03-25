# Day 01 — Linux Navigation & File System

![Day](https://img.shields.io/badge/Day-01-yellow?style=flat-square)
![Topic](https://img.shields.io/badge/Topic-Linux%20Navigation-blue?style=flat-square)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen?style=flat-square)

> 📅 Date: March 25, 2026
> ⏱️ Time Spent: 3+ hrs
> 🎯 Goal: Understand the Linux file system and navigate confidently using the terminal

---

## 📌 What I Learned Today

### 1. The Linux File System Structure

The Linux file system starts from the **root** `/` — everything lives inside it.

| Directory | Purpose |
|-----------|---------|
| `/` | Root — top of everything |
| `/home` | Personal folders for each user (e.g. `/home/wagge`) |
| `/etc` | System configuration files |
| `/var` | Logs and variable data |
| `/tmp` | Temporary files |
| `/bin` | Essential system commands |
| `/usr` | Installed software |

> 💡 My username is `wagge` so my home directory is `/home/wagge`

---

### 2. Navigation Commands

#### 📍 pwd — Where am I?
```bash
pwd
# Output: /home/wagge
```
> Stands for **Print Working Directory** — tells you your current location

---

#### 📂 cd — Move between directories
```bash
cd /home          # Go to /home (absolute path)
cd ~              # Go directly to home /home/wagge
cd ..             # Go one level up (parent directory)
cd Documents      # Go into Documents (relative path)
cd -              # Go back to previous directory
```

**What I discovered about cd .. :**
```bash
# I was in /home
cd ..
pwd
# Output: /   ← went all the way up to root!
```

**cd~ error I got:**
```bash
cd~
# Error: Command 'cd-' not found ❌
# Reason: Need a SPACE between cd and ~ → correct is: cd ~
```

---

### 3. Listing Files

```bash
ls
# Output: Desktop  Documents  Downloads  Music  Pictures  Public  snap  Templates  Videos

ls -a
# Shows hidden files too (.bashrc .bash_history .config .ssh .profile etc.)

ls -la
# Full details — permissions, owner, size, date
# drwxr-x--- 21 wagge wagge 4096 Mar 25 10:58 .
# -rw-r--r--  1 wagge wagge 3771 Mar 31 2024  .bashrc
```

> 💡 Files starting with `.` are **hidden files** — only visible with `ls -a`

---

### 4. Creating Files & Folders

```bash
touch file.txt            # Create an empty file
mkdir myfolder            # Create a folder
mkdir -p a/b/c            # Create nested folders in one command
```

**What happened when I ran these:**
```bash
touch file.txt    # ✅ Created file.txt in home directory
mkdir -p a/b/c    # ✅ Created folder a, inside it b, inside it c
mkdir myfolder    # ✅ Created myfolder
```

---

### 5. Copying & Moving Files

```bash
cp file.txt backup.txt    # Copy file.txt and name the copy backup.txt
mv file.txt docs/         # Move file.txt into docs folder
mv file.txt Documents/    # Move file.txt into Documents folder
```

**Mistake I made:**
```bash
mv file.txt docs/
# Error: mv: cannot move 'file.txt' to 'docs/': Not a directory ❌
# Reason: I hadn't created a folder called 'docs' — it didn't exist!

mv file.txt Documents/
# ✅ This worked because Documents/ folder already exists
```

---

### 6. Deleting Files & Folders

```bash
rm file.txt          # Delete a file
rm -rf a             # Delete folder 'a' and everything inside it (-r=recursive, -f=force)
```

**Mistake I made:**
```bash
rm file.txt
# Error: rm: cannot remove 'file.txt': No such file or directory ❌
# Reason: file.txt was already moved to Documents/ so it wasn't here anymore!

cd Documents
rm file.txt    # ✅ Found it here and deleted it
```

> ⚠️ **Warning:** `rm -rf` permanently deletes — no recycle bin in Linux!

---

### 7. Viewing File Contents

```bash
cat backup.txt    # Show full file content at once
less backup.txt   # View file page by page (press q to quit)
head backup.txt   # Show first 10 lines
tail backup.txt   # Show last 10 lines
tail -f backup.txt  # Live follow a file (Ctrl+C to stop)
```

**What I saw in backup.txt:**
```
#inlcude<stdio.h>
int main(){
//from file.txt to backup.txt
printf("Hello, World!");
return 0;
}
```
> 💡 This file had old C code in it — `cp file.txt backup.txt` copied whatever was inside file.txt!

**tail -f showed live output then I pressed Ctrl+C to stop it** ✅

---

### 8. Finding Files

```bash
find / -name "backup.txt"
# Searched from root / — showed lots of "Permission denied" errors
# This is NORMAL — regular users can't read system/root folders
# It still found the file eventually!

find . -type f -name "*.md"
# Found all .md files from current directory:
# ./Downloads/day01-navigation.md
# ./Downloads/README.md
# ./.config/... (many more)

locate backup.txt
# First time: Command 'locate' not found → had to install it
# sudo apt install plocate  ← how to install it
# After install: /home/wagge/backup.txt ✅

which python3
# Output: /usr/bin/python3  ← python3 is installed here
```

**Why find / showed "Permission denied":**
> Normal users don't have access to system folders like `/proc`, `/snap` internals etc.
> This is Linux security working correctly — not an error on your part! ✅

---

### 9. Absolute vs Relative Path — Key Lesson

| Type | Example | Starts From |
|------|---------|-------------|
| Absolute | `/home/wagge/Documents` | Always from root `/` |
| Relative | `Documents` or `../Downloads` | From where you currently are |

**Mistakes that taught me this:**
```bash
cd home
# ❌ Error: No such file or directory
# Reason: Looked for 'home' INSIDE current directory

cd /home
# ✅ Works — absolute path from root

cd /wagge
# ❌ Error: No such file or directory
# Reason: /wagge doesn't exist — correct is /home/wagge
```

---

### 10. Understanding ls -la Output

```
drwxr-x--- 21 wagge wagge  4096 Mar 25 10:58 .
-rw-r--r--  1 wagge wagge  3771 Mar 31 2024  .bashrc
```

| Column | Meaning |
|--------|---------|
| `d` or `-` | d = directory, - = file |
| `rwxr-x---` | Permissions (read/write/execute) |
| `wagge wagge` | Owner and group |
| `4096` | Size in bytes |
| `Mar 25 10:58` | Last modified |

> 📌 Learning full permissions on **Day 02**

---

### 11. Hidden Files I Noticed

| File | Purpose |
|------|---------|
| `.bashrc` | Terminal settings & shortcuts |
| `.bash_history` | Every command I've ever typed |
| `.ssh` | SSH keys for remote servers |
| `.config` | App configurations |
| `.profile` | Login settings |

---

## 💡 All Key Concepts Learned

- [x] Linux file system starts from `/` (root)
- [x] `pwd` = where am I right now
- [x] `ls`, `ls -a`, `ls -la` — different levels of detail
- [x] Hidden files start with `.`
- [x] `~` = my home directory `/home/wagge`
- [x] Absolute path starts with `/`, relative doesn't
- [x] `touch` creates files, `mkdir` creates folders
- [x] `cp` copies, `mv` moves, `rm` deletes permanently
- [x] `cat`, `less`, `head`, `tail` — different ways to read files
- [x] `tail -f` follows a file live (Ctrl+C to stop)
- [x] `find` searches files (Permission denied on system folders = normal!)
- [x] `locate` is faster than find but needs `sudo apt install plocate` first
- [x] `which` tells you where a program is installed

---

## ❌ Mistakes I Made (and Learned From)

| Mistake | Error | What I Learned |
|---------|-------|----------------|
| `cd home` | No such file or directory | Need `/home` — absolute path |
| `cd /wagge` | No such file or directory | Correct path is `/home/wagge` |
| `cd~` | Command not found | Need space: `cd ~` |
| `mv file.txt docs/` | Not a directory | `docs/` folder didn't exist yet |
| `rm file.txt` (wrong dir) | No such file | File was already moved to Documents/ |
| `find / -name "backup.txt"` | Permission denied (many times) | Normal! Regular users can't access system folders |

---

## 📚 Resources I Used Today
- [Linux Journey](https://linuxjourney.com)
- [OverTheWire Bandit](https://overthewire.org/wargames/bandit/)

---

## ✅ Tomorrow → Day 02: File Permissions & Users
