# Day 08 — Git Basics

![Day](https://img.shields.io/badge/Day-08-yellow?style=flat-square)
![Topic](https://img.shields.io/badge/Topic-Git%20Basics-blue?style=flat-square)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen?style=flat-square)

> 📅 Date: March 30, 2026
> ⏱️ Time Spent: 3+ hrs
> 🎯 Goal: Understand Git fundamentals — init, add, commit, log, diff, restore, .gitignore

---

## 📌 What I Learned Today

### 1. Installing & Configuring Git

```bash
sudo apt install git       # install git
git --version              # verify → git version 2.43.0

git config --global user.name "Waggepradeep"
git config --global user.email "waggepradeep369@gmail.com"
git config --global init.defaultBranch main
git config --list          # verify settings
```

---

### 2. How Git Works — The 3 Stages

```
Working Directory → Staging Area → Repository
   (edit files)      (git add)     (git commit)
```

| Stage | Description |
|-------|-------------|
| Working Directory | Where you edit files |
| Staging Area | Files ready to be committed |
| Repository | Permanent saved history |

---

### 3. Creating a Repository

```bash
mkdir ~/git-practice
cd ~/git-practice
git init
ls -la
```

**Output:**
```
Initialized empty Git repository in /home/wagge/git-practice/.git/
```

> 💡 `git init` creates a hidden `.git` folder
> Everything Git tracks lives inside `.git`
> **Never delete `.git`** — you'll lose all history!

---

### 4. git status — Most Used Command

```bash
git status
```

**3 possible states:**

| State | Color | Meaning |
|-------|-------|---------|
| Untracked | Red | New file, Git doesn't know about it |
| Modified | Red | Changed file, not staged yet |
| Staged | Green | Ready to commit |
| Clean | - | Nothing to commit |

---

### 5. git add — Stage Files

```bash
git add readme.txt    # add specific file
git add .             # add ALL changed files
git add *.html        # add all html files
```

---

### 6. git commit — Save to History

```bash
git commit -m "Initial commit: add readme.txt"
```

**Output:**
```
[main (root-commit) 4fbe5c4] Initial commit: add readme.txt
1 file changed, 1 insertion(+)
```

> 💡 `4fbe5c4` = commit hash — unique ID for every commit
> Always write **meaningful commit messages**!

**Good commit messages:**
```
✅ "Add user login feature"
✅ "Fix bug in payment system"
✅ "Update README with setup instructions"
❌ "fix"
❌ "changes"
❌ "asdfgh"
```

---

### 7. git log — View History

```bash
git log             # full details
git log --oneline   # compact one line per commit
git log --stat      # shows files changed in each commit
```

**My git log --oneline:**
```
f481b5a (HEAD -> main) Add .gitignore to ignore secrets and logs
4b9d609 Checking git diff through readme.txt
214799f Add index.html and Update readme.txt
4fbe5c4 Initial commit: add readme.txt
```

> `HEAD -> main` = where you currently are
> Latest commit is always at top

---

### 8. git diff — See What Changed

```bash
git diff readme.txt    # diff of specific file
git diff .             # diff of all files
```

**Output explained:**
```
--- a/readme.txt    ← old version
+++ b/readme.txt    ← new version
+This is a new line ← + means ADDED (green)
-Old line           ← - means REMOVED (red)
```

> Run `git diff` BEFORE `git add` to review changes!

---

### 9. git restore — Undo Changes

```bash
git restore readme.txt    # undo uncommitted changes
git restore .             # undo ALL uncommitted changes
```

> ⚠️ Only works for **uncommitted** changes!
> Once committed → use `git revert` instead

---

### 10. .gitignore — Ignore Files

```bash
nano .gitignore
```

**My .gitignore:**
```
passwords.txt
secrets.env
app.log
*.log        # ignore ALL .log files
node_modules/  # ignore entire folder
```

> Before .gitignore → passwords.txt, secrets.env, app.log showed as untracked
> After .gitignore → only .gitignore itself shows! ✅

**Always ignore:**
- Password files
- API keys / .env files
- Log files
- node_modules/
- __pycache__/
- .DS_Store (Mac)

---

### 11. Full Workflow Summary

```bash
# 1. Initialize
git init

# 2. Make changes
touch file.txt
echo "content" > file.txt

# 3. Check status
git status

# 4. See what changed
git diff

# 5. Stage changes
git add .

# 6. Commit
git commit -m "meaningful message"

# 7. View history
git log --oneline
```

---

## 💡 Key Concepts I Understood Today

- [x] `git init` creates a `.git` folder — never delete it!
- [x] 3 stages: Working Directory → Staging → Repository
- [x] `git status` shows current state of files
- [x] `git add .` stages all changes
- [x] Every commit gets a unique hash (e.g. `4fbe5c4`)
- [x] `git log --oneline` shows clean history
- [x] `git diff` shows what changed before staging
- [x] `git restore` undoes uncommitted changes
- [x] `.gitignore` prevents sensitive files from being committed
- [x] `HEAD -> main` means you're at the latest commit

---

## ❌ Mistakes I Made (and Learned From)

| Mistake | Error | What I Learned |
|---------|-------|----------------|
| `echo "<h1>Hello!</h1>"` | bash: !: event not found | Use single quotes `'` with `!` in bash |
| `git log --online` | unrecognized argument | Typo! It's `--oneline` not `--online` |

---

## 📚 Resources I Used Today
- [Pro Git Book](https://git-scm.com/book/en/v2)
- [LearnGitBranching](https://learngitbranching.js.org)

---

## ✅ Tomorrow → Day 09: Git — log, diff, restore, .gitignore (deeper)
