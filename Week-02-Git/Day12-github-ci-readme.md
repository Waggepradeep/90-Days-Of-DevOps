# Day 12 — GitHub CI Triggers + README Writing

![Day](https://img.shields.io/badge/Day-12-yellow?style=flat-square)
![Topic](https://img.shields.io/badge/Topic-CI%20Triggers%20%26%20README-blue?style=flat-square)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen?style=flat-square)

> 📅 Date: April 04, 2026
> ⏱️ Time Spent: 3+ hrs
> 🎯 Goal: Create a real GitHub Actions CI workflow and write a professional GitHub profile README

---

## 📌 What I Learned Today

### 1. What is CI/CD?

```
CI = Continuous Integration
CD = Continuous Deployment
```

**Without CI/CD:**
```
Developer writes code → manually tests → manually deploys → hope it works 😬
```

**With CI/CD:**
```
Developer pushes code → GitHub automatically tests → automatically deploys ✅
```

> 💡 Think of CI/CD like a robot that automatically checks your code every time you push!
> No manual testing needed — it happens automatically!

---

### 2. GitHub Actions — How It Works

GitHub Actions is GitHub's built-in CI/CD tool.

**The flow:**
```
You push code to GitHub
        ↓
GitHub Actions detects the push
        ↓
Runs your workflow automatically
        ↓
Shows ✅ green or ❌ red on your repo
```

**Folder structure required:**
```
your-repo/
└── .github/
    └── workflows/
        └── ci.yml  ← your workflow lives here!
```

> 💡 The `.github` folder is hidden (starts with `.`)
> GitHub automatically detects any `.yml` file inside `workflows/`!

---

### 3. YAML (.yml) — What You Need to Know

YAML is just a configuration format — NOT a programming language!

**The only rule that matters:**
> Indentation (spaces) matters — NEVER use tabs!

**Basic structure:**
```yaml
name: What this workflow is called
on: When to trigger it
jobs: What to run
  steps: Individual tasks
```

**Comparison with Bash:**

| | Bash | YAML |
|--|------|------|
| Purpose | Write scripts/logic | Configure settings |
| Has loops/conditions | ✅ Yes | ❌ No |
| How deep to learn | Deep | Basic — just read/edit |
| Used for | Automation scripts | CI/CD pipelines |

---

### 4. My First GitHub Actions Workflow

```yaml
name: DevOps Learning CI

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  check-notes:
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Check all markdown files exist
        run: |
          echo "Checking notes files..."
          ls Week-01-Linux/
          ls Week-02-Git/
          echo "All notes found! ✅"
      
      - name: Count total notes
        run: |
          COUNT=$(find . -name "*.md" | wc -l)
          echo "Total markdown files: $COUNT"
```

**Breaking it down:**

| Part | Meaning |
|------|---------|
| `name` | What this workflow is called |
| `on: push` | Trigger when code is pushed |
| `branches: [main]` | Only trigger on main branch |
| `runs-on: ubuntu-latest` | Run on GitHub's Ubuntu server |
| `uses: actions/checkout@v3` | Download your repo code |
| `run: \|` | Run multiple bash commands |

---

### 5. How I Created and Pushed the Workflow

```bash
# Clone the repo locally
cd ~
git clone git@github.com:Waggepradeep/90-Days-Of-DevOps.git
cd 90-Days-Of-DevOps

# Create the workflows folder
mkdir -p .github/workflows

# Create the workflow file
nano .github/workflows/ci.yml
# (paste the yaml content)

# Push to GitHub
git add .
git commit -m "Add GitHub Actions CI workflow"
git push
```

---

### 6. Reading GitHub Actions Results

After pushing, go to your repo → click **"Actions"** tab:

**What you see:**
```
✅ Green circle = workflow passed
❌ Red circle = workflow failed
🟡 Yellow circle = workflow running
```

**My workflow results:**
```
✅ Set up job
✅ Checkout code
✅ Check all markdown files exist
✅ Count total notes
```

**Error I fixed:**
```
wc -1   ❌ (number 1 — invalid option)
wc -l   ✅ (letter l — count lines)
```

**Warning I got (not an error):**
> `actions/checkout@v3` is getting deprecated
> Fix: change to `actions/checkout@v4` in future

---

### 7. GitHub Profile README

A special GitHub feature — if you create a repo with the **same name as your username**, its README shows on your profile page!

**My repo:** `Waggepradeep/Waggepradeep`
**Shows at:** `github.com/Waggepradeep`

**How I created it:**
1. Created new repo named `Waggepradeep` on GitHub
2. Made it Public with README initialized
3. Cloned locally:
```bash
git clone git@github.com:Waggepradeep/Waggepradeep.git
cd Waggepradeep
nano README.md
```
4. Wrote professional content
5. Pushed:
```bash
git add .
git commit -m "Add professional profile README"
git push
```

**What makes a good profile README:**
- Your name and intro
- Tech stack with badges
- Current focus/projects
- Links to your projects
- Contact info

---

### 8. Markdown Badges

Badges are those colorful labels you see on GitHub repos!

```markdown
![Linux](https://img.shields.io/badge/Linux-FCC624?style=flat&logo=linux&logoColor=black)
![Git](https://img.shields.io/badge/Git-F05032?style=flat&logo=git&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=flat&logo=docker&logoColor=white)
```

**Badge format:**
```
https://img.shields.io/badge/LABEL-COLOR?style=flat&logo=LOGO
```

> Get more badges at: shields.io

---

## 💡 Key Concepts I Understood Today

- [x] CI/CD = automatic testing and deployment on every push
- [x] GitHub Actions = GitHub's built-in CI/CD tool
- [x] Workflows live in `.github/workflows/` folder
- [x] YAML is just configuration — not a programming language
- [x] Spaces matter in YAML — never use tabs!
- [x] `on: push` = trigger workflow on every push
- [x] `runs-on: ubuntu-latest` = run on GitHub's server
- [x] Green ✅ = passed, Red ❌ = failed in Actions tab
- [x] Profile README = repo named same as your username
- [x] Badges make README look professional

---

## ❌ Mistakes I Made (and Learned From)

| Mistake | Error | What I Learned |
|---------|-------|----------------|
| `wc -1` | invalid option | It's letter `l` not number `1`! |
| `nano READEME.md` | Wrong filename | Always double check filename before typing! |
| `action/checkout@v3` | Would fail | It's `actions` (with s) not `action` |

---

## 📚 Resources I Used Today
- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [Shields.io — Badges](https://shields.io)

---

## ✅ Tomorrow → Day 13: Git + GitHub Review + Push everything via terminal
