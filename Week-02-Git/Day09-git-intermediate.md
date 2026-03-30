# Day 09 — Git Intermediate

![Day](https://img.shields.io/badge/Day-09-yellow?style=flat-square)
![Topic](https://img.shields.io/badge/Topic-Git%20Intermediate-blue?style=flat-square)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen?style=flat-square)

> 📅 Date: March 30, 2026
> ⏱️ Time Spent: 3+ hrs
> 🎯 Goal: Learn Git branches, merge, stash, revert and reset

---

## 📌 What I Learned Today

### 1. Git Branches

Branches let you work on features without touching main code!

```
main ──●──●──●──●
            \
    feature  ●──●──●
```

```bash
git branch                    # see all branches (* = current)
git branch feature-login      # create new branch
git checkout feature-login    # switch to branch
git branch                    # verify (* moved to feature-login)
```

**Shortcut — create and switch in one command:**
```bash
git checkout -b feature-signup  # create + switch at once!
```

**My practice:**
```
git branch        → * main
git branch feature-login  → created
git checkout feature-login → Switched to branch 'feature-login' ✅
git branch        → * feature-login, main
```

---

### 2. Committing on a Branch

```bash
touch login.html
echo '<h1>Login Page</h1>' > login.html
git add .
git commit -m "Add login page"
git log --oneline
```

**Output:**
```
9c63831 (HEAD -> feature-login) Add login page  ← new commit on feature!
f481b5a (main) Add .gitignore...                ← main stayed here!
```

> 💡 `main` stayed behind — feature-login moved forward!
> Main is completely untouched! ✅

---

### 3. git merge — Combine Branches

```bash
git checkout main           # MUST switch to target branch first!
git merge feature-login     # bring feature into main
```

**Output:**
```
Fast-forward
login.html | 1 +
1 file changed, 1 insertion(+) ✅
```

**After merge:**
```
9c63831 (HEAD -> main, feature-login) Add login page
```
> Both branches now point to same commit!
> `login.html` appeared in main! ✅

**Why must you switch to target branch first?**
```
git merge feature-login
= "bring feature-login INTO my current branch"
So you must BE on the branch that receives the code!
```

---

### 4. git stash — Save Work Temporarily

```bash
echo "Work in progress..." >> readme.txt
git status          # shows modified: readme.txt (red)
git stash           # save changes temporarily
git status          # nothing to commit, working tree clean! ✅
cat readme.txt      # "Work in progress..." line is GONE!
git stash pop       # bring changes back
cat readme.txt      # "Work in progress..." is BACK! ✅
```

**Stash commands:**
| Command | Meaning |
|---------|---------|
| `git stash` | Save changes temporarily |
| `git stash pop` | Restore changes + remove from stash |
| `git stash list` | See all stashed items |
| `git stash drop` | Delete a stash without restoring |

**Real world use case:**
> Working on feature → urgent bug fix needed on main
> `git stash` → switch to main → fix bug → switch back → `git stash pop` → continue! 💪

---

### 5. git revert — Safe Undo

```bash
git revert HEAD    # undo last commit safely
```

**Output:**
```
[main 008b6c6] Revert "WIP: work in progress line"
1 file changed, 1 deletion(-) ✅
```

**git log after revert:**
```
008b6c6 (HEAD) Revert "WIP: work in progress line" ← NEW revert commit
45e1082 WIP: work in progress line  ← original still exists!
```

> 💡 `git revert` does NOT delete history
> It ADDS a new commit that reverses the changes
> This is the SAFE way to undo — especially in teams!

---

### 6. git reset — Powerful Undo

```bash
git reset --soft HEAD~1    # undo 1 commit, keep changes STAGED
git reset --mixed HEAD~1   # undo 1 commit, keep changes UNSTAGED
git reset --hard HEAD~1    # undo 1 commit, DELETE changes forever ⚠️
```

**What I practiced:**
```bash
git reset --soft HEAD~1
git log --oneline   # revert commit disappeared!
git status          # changes still staged ✅
```

**HEAD~1 means:**
```
HEAD~1 = 1 commit back
HEAD~2 = 2 commits back
HEAD~3 = 3 commits back
```

---

### 7. git revert vs git reset

| Command | What it does | History | Safe for teams? |
|---------|-------------|---------|-----------------|
| `git revert` | Adds new undo commit | Preserved | ✅ Always safe |
| `git reset --soft` | Undo commit, keep staged | Changed | ⚠️ Local only |
| `git reset --mixed` | Undo commit, keep unstaged | Changed | ⚠️ Local only |
| `git reset --hard` | Undo commit, delete changes | Changed | ❌ Dangerous! |

> 💡 Rule: Use `git revert` for shared branches, `git reset` only for local work!

---

## 💡 Key Concepts I Understood Today

- [x] Branches let you work without touching main code
- [x] `git checkout -b branch-name` creates and switches in one command
- [x] Always switch to TARGET branch before merging
- [x] `git merge feature` brings feature INTO current branch
- [x] Fast-forward merge = no conflicts, clean straight line
- [x] `git stash` temporarily saves uncommitted changes
- [x] `git stash pop` restores them back
- [x] `git revert HEAD` safely undoes last commit
- [x] `git revert` adds new commit — doesn't delete history
- [x] `git reset --soft HEAD~1` undoes commit but keeps changes staged
- [x] `git reset --hard` is dangerous — deletes changes permanently!

---

## ❌ Mistakes I Made (and Learned From)

| Mistake | Error | What I Learned |
|---------|-------|----------------|
| `git stat` | not a git command | Typo! It's `git status` or `git log --stat` |
| Tried to merge from feature branch | Confused about direction | Always switch to TARGET branch first then merge |

---

## 📚 Resources I Used Today
- [Pro Git Book — Branching](https://git-scm.com/book/en/v2/Git-Branching-Branches-in-a-Nutshell)
- [LearnGitBranching](https://learngitbranching.js.org)

---

## ✅ Tomorrow → Day 10: Git Branches Deep Dive — conflicts, rebase
