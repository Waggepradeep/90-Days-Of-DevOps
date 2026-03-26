# Day 02 — File Permissions & Users

![Day](https://img.shields.io/badge/Day-02-yellow?style=flat-square)
![Topic](https://img.shields.io/badge/Topic-Permissions%20%26%20Users-blue?style=flat-square)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen?style=flat-square)

> 📅 Date: March 26, 2026
> ⏱️ Time Spent: 3+ hrs
> 🎯 Goal: Understand Linux file permissions, users and groups

---

## 📌 What I Learned Today

### 1. Understanding the Permission String

Every file has a permission string visible in `ls -la`:

```
-rwxr--r-- 1 wagge wagge 0 Mar 26 11:38 testfile.txt
│ │   │   │
│ │   │   └── Others → r-- (read only)
│ │   └─────── Group  → r-- (read only)
│ └─────────── Owner  → rwx (read + write + execute)
└───────────── Type   → - = file, d = directory
```

---

### 2. The 3 Permission Types

| Letter | Name | Meaning |
|--------|------|---------|
| `r` | read | Can view the file |
| `w` | write | Can edit the file |
| `x` | execute | Can run it as a program |
| `-` | none | No permission at all |

---

### 3. chmod — Changing Permissions

#### Symbol Method (+/-)
```bash
chmod +x testfile.txt   # Add execute permission
chmod -w testfile.txt   # Remove write permission
chmod +r testfile.txt   # Add read permission
chmod -r testfile.txt   # Remove read permission
```

**What I saw when I practiced:**
```
chmod +x  → -rwxrwxr-x  (execute added to all)
chmod -w  → -r-xr-xr-x  (write removed from all)
chmod -r  → ---x--x--x  (read removed from all!)
chmod +r  → -r-xr-xr-x  (read added back)
chmod +w  → -rwxrwxr-x  (write added back)
```

---

#### Number Method (most used in real DevOps!)

Each permission has a value:
```
r = 4
w = 2
x = 1
- = 0
```

Add them up for each group (Owner, Group, Others):
```
rwx = 4+2+1 = 7
rw- = 4+2+0 = 6
r-x = 4+0+1 = 5
r-- = 4+0+0 = 4
--- = 0+0+0 = 0
```

**Examples I practiced:**
```bash
chmod 777 testfile.txt   # -rwxrwxrwx (everyone gets everything)
chmod 544 testfile.txt   # -r-xr--r-- (owner=r-x, group=r--, others=r--)
chmod 644 testfile.txt   # -rw-r--r-- (most common for files!)
chmod 766 testfile.txt   # -rwxrw-rw-
chmod 755 testfile.txt   # -rwxr-xr-x (most common for scripts/folders!)
chmod 400 testfile.txt   # -r-------- (read only — used for SSH keys!)
chmod 744 testfile.txt   # -rwxr--r--
```

---

### 4. Most Used Permissions in Real DevOps

| Number | Permission | Used For |
|--------|-----------|---------|
| `644` | -rw-r--r-- | Normal files |
| `755` | -rwxr-xr-x | Scripts & folders |
| `400` | -r-------- | SSH private keys |
| `600` | -rw------- | Private config files |
| `777` | -rwxrwxrwx | ⚠️ Never use in production! |

---

### 5. Users & Groups

#### whoami — Who am I?
```bash
whoami
# Output: wagge
```

#### id — Full user info
```bash
id
# Output: uid=1000(wagge) gid=1000(wagge) groups=1000(wagge),4(adm),24(cdrom),27(sudo)...
```

| Part | Meaning |
|------|---------|
| `uid=1000` | User ID — Linux gives every user a unique number |
| `gid=1000` | Main group ID |
| `27(sudo)` | ⭐ In sudo group = has admin powers! |

---

#### /etc/passwd — All users on the system
```bash
cat /etc/passwd | head -5
# root:x:0:0:root:/root:/bin/bash
# daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
# wagge:x:1000:1000:Wagge:/home/wagge:/bin/bash
# devopsuser:x:1001:1001::/home/devopsuser:/bin/sh
```

Format of each line:
```
username : password : uid : gid : info : home_dir : shell
```

| User | UID | Meaning |
|------|-----|---------|
| `root` | 0 | Superuser — full control of system |
| `wagge` | 1000 | Me! Normal user |
| `devopsuser` | 1001 | New user I created |

---

#### /etc/group — All groups on the system
```bash
cat /etc/group | head -5
# root:x:0:
# adm:x:4:syslog,wagge
# wagge:x:1000:
```

---

### 6. Managing Users

#### Creating a user
```bash
sudo useradd devopsuser       # ❌ Creates user WITHOUT home folder
sudo useradd -m devopsuser    # ✅ Creates user WITH home folder (-m flag)
```

#### Setting a password
```bash
sudo passwd devopsuser
# New password: ****
# Retype new password: ****
# passwd: password updated successfully ✅
```

#### Deleting a user
```bash
sudo userdel devopsuser    # Delete user (keep home folder)
sudo userdel -r devopsuser # Delete user AND home folder
```

#### Switching users
```bash
su - devopsuser    # Switch to devopsuser
whoami             # devopsuser ✅
pwd                # /home/devopsuser ✅
exit               # Go back to wagge
whoami             # wagge ✅
```

---

### 7. chown — Change File Owner

```bash
ls -la testfile.txt
# -rwxr--r-- 1 wagge wagge 0 Mar 26 testfile.txt

sudo chown devopsuser testfile.txt
ls -la testfile.txt
# -rwxr--r-- 1 devopsuser wagge 0 Mar 26 testfile.txt ✅ (owner changed!)

sudo chown wagge testfile.txt
ls -la testfile.txt
# -rwxr--r-- 1 wagge wagge 0 Mar 26 testfile.txt ✅ (owner back to wagge)
```

> 💡 `chown` needs `sudo` because changing ownership is an admin action

---

### 8. sudo — Super User Do

```bash
sudo <command>    # Run any command as admin/root
```

> You can use sudo because your user `wagge` is in the `sudo` group (uid=27)!
> Not every user can use sudo — only trusted ones!

---

## 💡 Key Concepts I Understood Today

- [x] Permission string has 3 parts — Owner, Group, Others
- [x] `r=4, w=2, x=1` — number method for chmod
- [x] `chmod 644` = most common for files
- [x] `chmod 755` = most common for scripts/folders
- [x] `chmod 400` = SSH private keys (read only!)
- [x] Every user has a uid, every group has a gid
- [x] `root` has uid=0 — superuser of the system
- [x] `/etc/passwd` stores all user info
- [x] `/etc/group` stores all group info
- [x] `useradd -m` creates user WITH home folder
- [x] `su -` switches to another user
- [x] `chown` changes file ownership
- [x] `sudo` runs commands as admin

---

## ❌ Mistakes I Made (and Learned From)

| Mistake | Error | What I Learned |
|---------|-------|----------------|
| `sudo usedel devopsuser` | command not found | Typo! It's `userdel` not `usedel` |
| `chmod 744 textfile.txt` | cannot access | Typo! File is `testfile` not `textfile` |
| `sudo useradd devopsuser` (no -m) | Warning: no home directory | Always use `useradd -m` to create home folder |

---

## 📚 Resources I Used Today
- [Linux Journey — Permissions](https://linuxjourney.com/lesson/file-permissions)
- [Linux Journey — Users](https://linuxjourney.com/lesson/users-and-groups)

---

## ✅ Tomorrow → Day 03: Processes & Package Manager
