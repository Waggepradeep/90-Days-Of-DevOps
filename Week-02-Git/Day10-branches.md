# Day 10 — Git Branches Deep Dive + Rebase

![Day](https://img.shields.io/badge/Day-10-yellow?style=flat-square)
![Topic](https://img.shields.io/badge/Topic-Branches%20%26%20Rebase-blue?style=flat-square)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen?style=flat-square)

> 📅 Date: March 31, 2026
> ⏱️ Time Spent: 3+ hrs
> 🎯 Goal: Learn merge conflicts, rebase, cherry-pick and branch deletion

---

## 📌 What I Learned Today

### 1. Merge Conflicts — What & Why

A conflict happens when **two branches edit the same line differently** and Git can't decide which to keep.

**How I created a conflict on purpose:**
```bash
# On main branch
nano readme.txt  # added "This line was added on MAIN branch"
git add .
git commit -m "Add line on main branch"

# On feature-login branch
git checkout feature-login
nano readme.txt  # added "This line was added on FEATURE branch"
git add .
git commit -m "Add line on feature branch"

# Merge → CONFLICT!
git checkout main
git merge feature-login
```

**Output:**
```
CONFLICT (content): Merge conflict in readme.txt
Automatic merge failed; fix conflicts and then commit the result.
```

---

### 2. Reading Conflict Markers

When you open the conflicted file you see:
```
<<<<<<< HEAD
This line was added on MAIN branch
=======
This line was added on FEATURE branch
>>>>>>> feature-login
```

| Marker | Meaning |
|--------|---------|
| `<<<<<<< HEAD` | Start of YOUR branch version |
| `=======` | Separator between versions |
| `>>>>>>> feature-login` | Start of INCOMING branch version |

---

### 3. Fixing a Merge Conflict

**Step 1 — Open the file:**
```bash
nano readme.txt
```

**Step 2 — Delete conflict markers and decide what to keep:**
```
# Option A: Keep both lines
This line was added on MAIN branch
This line was added on FEATURE branch

# Option B: Keep only main
This line was added on MAIN branch

# Option C: Keep only feature
This line was added on FEATURE branch
```

**Step 3 — Stage and commit:**
```bash
git add .
git commit -m "Fix merge conflict in readme.txt"
```

**Result:**
```
cf19bd1 (HEAD -> main) Fix merge conflict in readme.txt ✅
```

---

### 4. git rebase — Cleaner History

Rebase moves your branch commits ON TOP of another branch — creating a **clean linear history**!

**Before rebase:**
```
main     ──●──●──●──● (about page)
                  \
feature-signup     ●──● (signup page)
```

**After rebase:**
```
main     ──●──●──●──● (about page)
                      \
feature-signup         ●──● (signup page on top of main!)
```

**How to rebase:**
```bash
git checkout feature-signup   # go to feature branch
git rebase main               # rebase onto main
```

**Output:**
```
Successfully rebased and updated refs/heads/feature-signup ✅
```

---

### 5. Merge vs Rebase — Key Differences

| | Merge | Rebase |
|--|-------|--------|
| History | Creates merge commit | Clean linear history |
| Conflicts | Resolved once | Resolved per commit |
| Safety | Always safe | ⚠️ Never on shared branches! |
| Best for | Team shared branches | Local feature branches |

> 💡 **Golden Rule:** Never rebase a branch that others are working on!

---

### 6. Branch Deletion

```bash
git branch -d branch-name   # safe delete (refuses if not merged)
git branch -D branch-name   # force delete (even if not merged)
```

**What I learned:**
```bash
git branch -d feature-login  # ✅ Deleted (was merged)
git branch -d feature-signup # ❌ Error: not fully merged
git branch -D feature-signup # ✅ Force deleted!
```

> 💡 Always clean up old branches after merging!

---

### 7. git cherry-pick — Explained Simply

#### What is cherry-pick?

Imagine you have two branches:
```
main        ──●──●──●
                     
feature     ──●──●──● (fix-bug) ──● (add-login) ──● (wip-stuff)
```

You want ONLY the `fix-bug` commit on main — NOT the whole feature branch!

**Cherry-pick lets you pick ONE specific commit and apply it to your current branch!**

```bash
git cherry-pick <commit-hash>
```

#### Real world example:

```
Branch: hotfix
Commits:
  abc123 Fix critical login bug  ← you want THIS one!
  def456 Work in progress code   ← you don't want this
  ghi789 Experimental feature    ← you don't want this

# You're on main and want only the bug fix:
git cherry-pick abc123
```

#### When to use cherry-pick:

| Situation | Use cherry-pick? |
|-----------|-----------------|
| Bug fix on feature branch needed on main | ✅ Yes |
| Want entire feature branch | ❌ No, use merge |
| Accidentally committed to wrong branch | ✅ Yes |
| Want a specific commit from old branch | ✅ Yes |

#### Why my cherry-pick showed "empty":

```bash
git cherry-pick 9c63831  # Add login page
# Result: "cherry-pick is now empty"
```

> This happened because `login.html` was already in the branch history!
> Cherry-pick only works when the commit doesn't already exist in your current branch!

#### Cherry-pick commands:

```bash
git cherry-pick <hash>           # pick one commit
git cherry-pick <hash1> <hash2>  # pick multiple commits
git cherry-pick --abort          # cancel cherry-pick
git cherry-pick --skip           # skip current commit
git cherry-pick --continue       # continue after fixing conflict
```

---

### 8. Branch Commands Summary

```bash
git branch                    # list all branches
git branch new-branch         # create branch
git checkout new-branch       # switch to branch
git checkout -b new-branch    # create + switch in one command
git branch -d branch-name     # safe delete
git branch -D branch-name     # force delete
git merge branch-name         # merge into current branch
git rebase main               # rebase current onto main
git cherry-pick <hash>        # pick specific commit
```

---

## 💡 Key Concepts I Understood Today

- [x] Conflicts happen when two branches edit the same line differently
- [x] Conflict markers: `<<<<<<<`, `=======`, `>>>>>>>`
- [x] Fix conflict → remove markers → keep what you want → add → commit
- [x] `git rebase` creates clean linear history — no merge commit
- [x] Never rebase shared branches — only local ones!
- [x] `-d` = safe delete, `-D` = force delete
- [x] Cherry-pick picks ONE specific commit from any branch
- [x] Cherry-pick shows "empty" if commit already exists in branch

---

## ❌ Mistakes I Made (and Learned From)

| Mistake | Error | What I Learned |
|---------|-------|----------------|
| `git cherry-pick 078d4d` | bad revision | Typo in hash — copy carefully! |
| `git brach -d` | not a git command | Typo! It's `git branch` not `git brach` |
| `git branch -d feature-signup` | not fully merged | Use `-D` to force delete unmerged branch |
| Cherry-pick showed empty | nothing to commit | Commit already existed in branch history |
| `git branch -d test` while on test | cannot delete | Must switch to different branch first! |

---

## 📚 Resources I Used Today
- [Pro Git Book — Branching](https://git-scm.com/book/en/v2/Git-Branching-Branches-in-a-Nutshell)
- [LearnGitBranching](https://learngitbranching.js.org)

---

## ✅ Tomorrow → Day 11: GitHub — push, pull, forks, PRs
