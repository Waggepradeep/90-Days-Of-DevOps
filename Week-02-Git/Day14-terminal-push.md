# Day 14 — Push All Notes via Terminal + Week 02 Review

![Day](https://img.shields.io/badge/Day-14-yellow?style=flat-square)
![Topic](https://img.shields.io/badge/Topic-Terminal%20Push%20%26%20Week%20Review-blue?style=flat-square)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen?style=flat-square)

> 📅 Date: April 05, 2026
> ⏱️ Time Spent: 3+ hrs
> 🎯 Goal: Push all notes via terminal, update README, and complete Week 02

---

## 📌 What I Did Today

### 1. The Real DevOps Workflow — Practiced Today!

Today I used the **full Git + GitHub workflow** completely from terminal:

```bash
# Step 1 — Go to repo
cd ~/90-Days-Of-DevOps

# Step 2 — Check status
git status
git log --oneline

# Step 3 — Check remote connection
git remote -v

# Step 4 — Pull latest changes from GitHub
git pull

# Step 5 — Add new notes file
nano Week-02-Git/Day13-review.md
# (paste content)

# Step 6 — Stage, commit and push
git add .
git commit -m "Add Day 13 Git and GitHub review notes"
git push

# Step 7 — Verify on GitHub
# → Week-02-Git/Day13-review.md appeared! ✅
```

> 💡 This is exactly what DevOps engineers do every single day at work!

---

### 2. What Each Command Did Today

| Command | What it did |
|---------|-------------|
| `git remote -v` | Confirmed SSH connection to GitHub |
| `git log --oneline` | Saw all 20+ commits — entire learning history! |
| `git status` | Checked what was untracked/modified |
| `git pull` | Downloaded Day 12 notes added on GitHub website |
| `nano Week-02-Git/Day13-review.md` | Created Day 13 notes file |
| `git add .` | Staged all changes |
| `git commit -m "..."` | Saved to local history |
| `git push` | Uploaded to GitHub |

---

### 3. Two Ways to Add Files to GitHub

Today I practiced BOTH methods:

**Method 1 — GitHub Website (manual)**
```
Go to repo → Add file → Create new file → paste content → Commit
```
> Easy but slow for multiple files!

**Method 2 — Terminal (proper DevOps way)**
```bash
nano filename.md    # create/edit file
git add .           # stage
git commit -m "..."  # commit
git push            # upload
```
> Fast, powerful, professional! ✅

**When changes are made on website → sync locally:**
```bash
git pull   # brings website changes to your computer
```

---

## 📌 Week 02 Complete Summary

### Everything I Learned in Week 02:

#### Git Basics (Day 08)
```bash
git init          # create repo
git add .         # stage changes
git commit -m ""  # save to history
git log           # view history
git status        # check state
git diff          # see changes
```

#### Git Intermediate (Day 09)
```bash
git stash         # save work temporarily
git stash pop     # restore saved work
git revert HEAD   # safely undo commit
git reset --soft HEAD~1  # undo commit keep staged
git reset --hard HEAD~1  # undo commit delete changes ⚠️
```

#### Branches & Conflicts (Day 10)
```bash
git branch feature      # create branch
git checkout feature    # switch branch
git checkout -b feature # create + switch
git merge feature       # merge into current
git rebase main         # rebase onto main
git cherry-pick <hash>  # pick specific commit
```

#### GitHub (Day 11)
```bash
ssh-keygen -t ed25519   # generate SSH key
ssh -T git@github.com   # test connection
git remote add origin git@github.com:user/repo.git
git push -u origin main # first push
git pull                # download changes
git clone git@...       # download repo
```

#### CI Triggers + README (Day 12)
```yaml
# .github/workflows/ci.yml
name: DevOps Learning CI
on:
  push:
    branches: [ main ]
jobs:
  check-notes:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - run: ls Week-01-Linux/
```

#### Review (Day 13)
- `git remote add origin` = connects local to GitHub
- `git remote -v` = shows remote connections
- `git pull` vs `git clone` differences
- Full Git command reference

---

### 4. My Git Log After Week 02

```
d194915 Add Day 13 Git and GitHub review notes
9da8eba Create README for GitHub CI Triggers and Actions
3612007 Update GitHub username in README.md
2ea7e8d Add GitHub Action CI workflow
602cd2f Create Day 11 GitHub tutorial notes
5fb7e3b Add Day 10 notes on Git branches and rebase
d9a5bfe Add Day 09 notes on Git Intermediate concepts
cad205b Create Day 08 notes on Git basics
4a41d7a Add Week 01 review and System Health Monitor project
...
0d8de02 Add files via upload  ← first ever commit!
```

> 20+ commits — entire learning journey documented! 💪

---

### 5. Repo Structure After Week 02

```
90-Days-Of-DevOps/
├── README.md ✅ (updated with correct topics)
├── .github/
│   └── workflows/
│       └── ci.yml ✅ (CI runs on every push!)
├── Week-01-Linux/
│   ├── Day01-navigation.md ✅
│   ├── Day02-permissions.md ✅
│   ├── Day03-processes.md ✅
│   ├── Day04-networking.md ✅
│   ├── Day05-bash-basics.md ✅
│   ├── Day06-bash-advanced.md ✅
│   └── Day07-review-project.md ✅
└── Week-02-Git/
    ├── Day08-git-basics.md ✅
    ├── Day09-git-intermediate.md ✅
    ├── Day10-branches.md ✅
    ├── Day11-github.md ✅
    ├── Day12-github-ci-readme.md ✅
    ├── Day13-review.md ✅
    └── Day14-terminal-push.md ✅
```

---

## 💡 Key Things I Understand After Week 02

- [x] Git tracks changes locally — GitHub stores them online
- [x] SSH key = no password needed for GitHub ever again
- [x] `git push` = local → GitHub
- [x] `git pull` = GitHub → local
- [x] `git clone` = download repo for first time
- [x] Branches = safe way to work without breaking main
- [x] Merge conflicts are normal — just fix and commit
- [x] Rebase = cleaner history than merge
- [x] GitHub Actions = automatic CI on every push
- [x] Profile README = first thing recruiters see!
- [x] Always use terminal — it's faster than GitHub website

---

## 🏆 Week 02 Complete!

```
✅ Day 08 — Git Basics
✅ Day 09 — Git Intermediate
✅ Day 10 — Branches, Conflicts, Rebase
✅ Day 11 — GitHub SSH, Push, Pull, Fork, PRs
✅ Day 12 — CI Triggers + README Writing
✅ Day 13 — Git + GitHub Review
✅ Day 14 — Terminal Push + Week Complete
```

> 🎯 Two weeks done! Linux + Git + GitHub — all solid!
> Next up → **Week 03: AWS Cloud! ☁️**

---

## 📚 Resources I Used
- [Pro Git Book](https://git-scm.com/book/en/v2)
- [LearnGitBranching](https://learngitbranching.js.org)
- [GitHub Actions Docs](https://docs.github.com/en/actions)

---

## ✅ Next → Week 03: AWS Cloud Fundamentals!
