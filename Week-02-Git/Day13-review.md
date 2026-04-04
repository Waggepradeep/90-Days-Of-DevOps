# Day 13 — Git + GitHub Review

![Day](https://img.shields.io/badge/Day-13-yellow?style=flat-square)
![Topic](https://img.shields.io/badge/Topic-Git%20%26%20GitHub%20Review-blue?style=flat-square)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen?style=flat-square)

> 📅 Date: April 04, 2026
> ⏱️ Time Spent: 3+ hrs
> 🎯 Goal: Review all Week 02 Git & GitHub concepts and solidify understanding

---

## 📌 Review Quiz — How Much I Remembered

| Question | My Answer | Correct? |
|----------|-----------|----------|
| Command to connect local repo to GitHub? | git pull/clone | ❌ → `git remote add origin` |
| Difference between git pull and git clone? | pull = part, clone = full | ✅ Correct! |
| Where do GitHub Actions workflows live? | .github | ✅ (full path: `.github/workflows/`) |
| Command to show remote connections? | git log --oneline | ❌ → `git remote -v` |
| Difference between merge and rebase? | merge = combine, rebase = sits on top | ✅ Correct! |

**Score: 3.5/5** — Good foundation, two gaps fixed!

---

## 📌 Week 02 Full Summary

### Git Commands — Complete Reference

#### Setup
```bash
git config --global user.name "Waggepradeep"
git config --global user.email "waggepradeep369@gmail.com"
git config --list                    # verify settings
```

#### Starting a Repo
```bash
git init                             # create new local repo
git clone git@github.com:user/repo   # download existing repo
```

#### Daily Workflow
```bash
git status                           # check what changed
git diff                             # see exact changes
git add .                            # stage all changes
git add filename                     # stage specific file
git commit -m "message"             # save to history
git log --oneline                    # view commit history
git log --stat                       # view with file changes
```

#### Undoing Things
```bash
git restore filename                 # undo uncommitted changes
git reset --soft HEAD~1              # undo commit, keep staged
git reset --mixed HEAD~1             # undo commit, keep unstaged
git reset --hard HEAD~1              # undo commit, delete changes ⚠️
git revert HEAD                      # safely undo with new commit ✅
```

#### Branches
```bash
git branch                           # list branches
git branch feature-name              # create branch
git checkout feature-name            # switch branch
git checkout -b feature-name         # create + switch
git merge feature-name               # merge into current branch
git rebase main                      # rebase onto main
git branch -d feature-name          # safe delete
git branch -D feature-name          # force delete
git cherry-pick <hash>               # pick specific commit
```

#### Stash
```bash
git stash                            # save work temporarily
git stash pop                        # restore saved work
git stash list                       # see all stashes
```

#### Remote / GitHub
```bash
git remote add origin git@github.com:user/repo.git  # connect to GitHub
git remote -v                        # view remote connections
git remote remove origin             # remove remote
git push -u origin main             # first push (sets tracking)
git push                             # push after tracking set
git pull                             # download latest changes
git fetch                            # download without merging
```

---

### GitHub Concepts — Complete Reference

| Concept | What it means |
|---------|---------------|
| Repository | A project folder tracked by Git |
| Fork | Your own copy of someone else's repo |
| Clone | Download a repo to your computer |
| Push | Upload local changes to GitHub |
| Pull | Download GitHub changes to local |
| Pull Request | Ask repo owner to accept your changes |
| Branch | Separate line of development |
| Merge | Combine branches together |
| CI/CD | Automatic testing/deployment on push |
| GitHub Actions | GitHub's built-in CI/CD tool |
| SSH Key | Digital key — no password needed |
| .gitignore | Files Git should never track |

---

### Git Concepts — Visual Summary

**The 3 Stages:**
```
Working Directory → Staging Area → Repository
   (edit files)      (git add)     (git commit)
```

**Merge vs Rebase:**
```
MERGE:                        REBASE:
main  ──●──●──M               main  ──●──●──●──●
          \  /                                  \
feature    ●──●               feature            ●──●
(creates merge commit)        (clean linear history)
```

**Fork & PR Flow:**
```
Original Repo → Fork → Clone → Branch → Changes → Push → Pull Request
```

---

### What I Practiced Today

```bash
# Checked remote connection
git remote -v
# origin git@github.com:Waggepradeep/90-Days-Of-DevOps.git ✅

# Viewed full commit history
git log --oneline
# 20+ commits showing entire learning journey! ✅

# Pulled changes made on GitHub website
git pull
# README.md + Day12 notes downloaded ✅

# Verified files
ls Week-02-Git/
# Day08 through Day12 all present ✅
```

---

## 💡 Key Things I Clarified Today

- [x] `git remote add origin` = connects local to GitHub (NOT git pull/clone!)
- [x] `git remote -v` = shows remote connections (NOT git log!)
- [x] `git pull` = update existing local repo
- [x] `git clone` = download repo for first time
- [x] Changes on GitHub website → `git pull` to sync locally
- [x] Changes locally → `git push` to sync to GitHub

---

## ✅ Week 02 Complete!

```
✅ Day 08 — Git Basics
✅ Day 09 — Git Intermediate
✅ Day 10 — Branches, Conflicts, Rebase
✅ Day 11 — GitHub SSH, Push, Pull, Fork, PRs
✅ Day 12 — GitHub CI Triggers + README Writing
✅ Day 13 — Git + GitHub Review
⬜ Day 14 — Terminal Push + Final Review
```

---

## 📚 Resources I Used
- [Pro Git Book](https://git-scm.com/book/en/v2)
- [LearnGitBranching](https://learngitbranching.js.org)
- [GitHub Actions Docs](https://docs.github.com/en/actions)

---

## ✅ Next → Day 14: Final push via terminal + start AWS!
