# Day 11 — GitHub: SSH, Push, Pull, Fork & Pull Requests

![Day](https://img.shields.io/badge/Day-11-yellow?style=flat-square)
![Topic](https://img.shields.io/badge/Topic-GitHub%20Collaboration-blue?style=flat-square)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen?style=flat-square)

> 📅 Date: March 31, 2026
> ⏱️ Time Spent: 3+ hrs
> 🎯 Goal: Connect local Git to GitHub and understand how real teams collaborate

---

## 🧠 Big Picture — What is GitHub vs Git?

Before anything, understand this difference:

| | Git | GitHub |
|--|-----|--------|
| What | Tool on your computer | Website on the internet |
| Purpose | Track changes locally | Store + share code online |
| Works without internet? | ✅ Yes | ❌ No |
| Who made it | Linus Torvalds | Microsoft |

> 💡 Think of it like this:
> **Git** = your diary where you write notes
> **GitHub** = the cloud where you back up and share that diary!

---

## 📌 What I Learned Today

### 1. SSH Key — What & Why

#### The Problem Without SSH:
Every time you push code to GitHub → GitHub asks:
```
Username: Waggepradeep
Password: ************
```
> This gets annoying VERY fast! 😤

#### The Solution — SSH Key:
SSH key = a special digital lock+key pair
- **Private key** → stays on YOUR computer (never share this!)
- **Public key** → you give to GitHub

When you push code:
```
Your Computer ──(private key)──► GitHub ──(checks public key)──► ✅ Authenticated!
```
> No username/password needed ever again! 🎉

#### How I Set It Up:
```bash
# Step 1 — Generate the key pair
ssh-keygen -t ed25519 -C "waggepradeep369@gmail.com"
# Press Enter for all questions (default location, no passphrase)

# Step 2 — View your public key
cat ~/.ssh/id_ed25519.pub
# Output: ssh-ed25519 AAAAC3NzaC1... waggepradeep369@gmail.com

# Step 3 — Copy that output and add it to GitHub:
# GitHub → Settings → SSH and GPG keys → New SSH key → Paste → Save

# Step 4 — Test the connection
ssh -T git@github.com
# Output: Hi Waggepradeep! You've successfully authenticated ✅
```

---

### 2. git remote — Connecting Local to GitHub

**remote** = a link between your local repo and GitHub repo

```bash
# Add GitHub as remote (SSH way — recommended!)
git remote add origin git@github.com:Waggepradeep/git-practice.git

# Wrong way (HTTPS — asks for password every time)
git remote add origin https://github.com/Waggepradeep/git-practice.git

# View remotes
git remote -v
# origin  git@github.com:Waggepradeep/git-practice.git (fetch)
# origin  git@github.com:Waggepradeep/git-practice.git (push)

# Remove a remote (if you made a mistake)
git remote remove origin
```

> 💡 `origin` is just a nickname for your GitHub repo URL
> You could call it anything but `origin` is the convention everyone uses!

---

### 3. git push — Upload Code to GitHub

```bash
# First push (sets up tracking)
git push -u origin main

# After first push, just use:
git push
```

**What `-u` does:**
> `-u` = sets up tracking so next time you just type `git push`
> without `-u` you'd have to type `git push origin main` every time!

**What I saw when I pushed:**
```
Enumerating objects: 32, done.
Writing objects: 100% (32/32), 2.70 KiB ✅
To github.com:Waggepradeep/git-practice.git
* [new branch] main -> main ✅
branch 'main' set up to track 'origin/main' ✅
```

> All 32 commits — my entire local history — uploaded to GitHub! 🎉

---

### 4. git pull — Download Changes from GitHub

**When do you use git pull?**
- Someone else pushed new code to GitHub
- You made changes directly on GitHub website
- You're working on two computers

```bash
git pull origin main

# After setting up tracking with -u, just use:
git pull
```

**What I practiced:**
1. Went to GitHub website
2. Edited `readme.txt` directly on GitHub
3. Added line: `This line was added directly on GitHub!`
4. Committed on GitHub website
5. Then ran `git pull` on my terminal

**Result:**
```
1 file changed, 1 insertion(+) ✅
cat readme.txt → showed the new line! ✅
```

---

### 5. git clone — Download Entire Repo

**Clone** = download a complete copy of any GitHub repo to your computer

```bash
git clone git@github.com:Waggepradeep/git-practice.git

# Clone to a specific folder name
git clone git@github.com:Waggepradeep/awesome.git my-folder
```

**Difference between clone and pull:**

| | git clone | git pull |
|--|-----------|----------|
| When to use | First time downloading a repo | Updating existing local repo |
| Creates new folder | ✅ Yes | ❌ No |
| Need existing repo locally | ❌ No | ✅ Yes |

---

### 6. Fork — Your Own Copy of Someone's Repo

#### What is a Fork?

Imagine the `sindresorhus/awesome` repo has millions of files.
You want to add your own resource to it.
But you **can't directly edit** someone else's repo!

**Fork solves this:**
```
sindresorhus/awesome (original)
        │
        │  Fork (click button on GitHub)
        ▼
Waggepradeep/awesome (YOUR copy)
        │
        │  Now you can edit freely!
        ▼
   Make changes → Pull Request → ask original owner to accept!
```

#### How I Forked:
1. Went to `github.com/sindresorhus/awesome`
2. Clicked **"Fork"** button (top right)
3. Clicked **"Create fork"**
4. GitHub created `Waggepradeep/awesome` — my own copy! ✅

#### Clone the fork locally:
```bash
git clone git@github.com:Waggepradeep/awesome.git
cd awesome
git remote -v
# origin git@github.com:Waggepradeep/awesome.git ✅
```

> 💡 You can't fork your OWN repo — only someone else's!
> Error: "Cannot fork because you own this repository"

---

### 7. Pull Request (PR) — Contributing to Open Source

#### What is a Pull Request?

After forking and making changes, you want the original owner to add your changes to their repo.

**The full flow:**
```
Step 1: Fork → Waggepradeep/awesome (your copy)
Step 2: Clone → download to your computer
Step 3: Create branch → git checkout -b add-devops-resource
Step 4: Make changes → add your content
Step 5: Push → git push origin add-devops-resource
Step 6: Pull Request → ask sindresorhus to merge your changes!
```

#### What I Did:
```bash
# Create a new branch for my changes
git checkout -b add-devops-resource

# Edit the file
nano awesome.md
# Added: - [90 Days Of DevOps](https://github.com/Waggepradeep/90-Days-Of-DevOps)

# Commit and push
git add .
git commit -m "Add 90 Days Of DevOps Resource"
git push origin add-devops-resource
```

**GitHub then showed:**
```
Create a pull request for 'add-devops-resource'
https://github.com/Waggepradeep/awesome/pull/new/add-devops-resource
```

**On GitHub:**
1. Clicked **"Compare & pull request"**
2. Added title: `Add 90 Days Of DevOps Learning Resource`
3. Clicked **"Create pull request"**

**Result:**
```
PR #4060 opened! ✅
Waggepradeep wants to merge 1 commit into sindresorhus:main
Status: Open
```

#### What the PR Template Was:
> When you open a PR on big repos, they show a **PR template** — a checklist of rules you must follow before they accept your contribution.
> It's not an error — it's the repo owner saying "follow these rules first!"

---

### 8. HTTPS vs SSH — Which to Use?

| | HTTPS | SSH |
|--|-------|-----|
| URL format | `https://github.com/user/repo.git` | `git@github.com:user/repo.git` |
| Authentication | Username + Password every time | Key pair — no password! |
| Setup | Easy | Needs SSH key setup |
| Recommended | ❌ No | ✅ Yes for DevOps! |

**Fix HTTPS to SSH:**
```bash
git remote remove origin
git remote add origin git@github.com:Waggepradeep/repo.git
```

---

### 9. Complete GitHub Workflow Summary

```bash
# ── FIRST TIME SETUP ──
ssh-keygen -t ed25519 -C "your@email.com"  # generate SSH key
cat ~/.ssh/id_ed25519.pub                   # copy public key to GitHub
ssh -T git@github.com                       # test connection

# ── START A NEW PROJECT ──
git init                                    # initialize local repo
git remote add origin git@github.com:...   # connect to GitHub
git push -u origin main                     # first push

# ── DAILY WORKFLOW ──
git pull                                    # get latest changes
# ... make changes ...
git add .
git commit -m "meaningful message"
git push                                    # upload changes

# ── CONTRIBUTE TO OPEN SOURCE ──
# 1. Fork on GitHub website
git clone git@github.com:YourUsername/repo.git  # clone YOUR fork
git checkout -b feature-branch              # create branch
# ... make changes ...
git push origin feature-branch             # push branch
# 2. Create Pull Request on GitHub website
```

---

## 💡 Key Concepts I Understood Today

- [x] Git = local tool, GitHub = cloud storage for code
- [x] SSH key = digital lock that replaces username/password forever
- [x] Private key stays on computer, public key goes to GitHub
- [x] `git remote add origin` connects local repo to GitHub
- [x] `origin` = nickname for your GitHub repo URL
- [x] `git push -u origin main` = first push, sets up tracking
- [x] `git pull` = download latest changes from GitHub
- [x] `git clone` = download entire repo for the first time
- [x] Fork = your own copy of someone else's GitHub repo
- [x] You can't fork your own repo!
- [x] Pull Request = asking repo owner to accept your changes
- [x] PR template = rules the repo owner sets for contributions
- [x] Always use SSH not HTTPS for DevOps work!

---

## ❌ Mistakes I Made (and Learned From)

| Mistake | Error | What I Learned |
|---------|-------|----------------|
| `cat /.ssh/id_ed25519.pub` | No such file | Need `~/.ssh` not `/.ssh` |
| Used HTTPS instead of SSH | Asked for username/password | Always use `git@github.com:` format |
| Tried to fork own repo | Cannot fork | Fork only works on OTHER people's repos |

---

## 📚 Resources I Used Today
- [GitHub SSH Docs](https://docs.github.com/en/authentication/connecting-to-github-with-ssh)
- [Pro Git Book](https://git-scm.com/book/en/v2)

---

## ✅ Tomorrow → Day 12: GitHub Advanced — CI triggers, Actions basics
