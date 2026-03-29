# Day 06 — Bash Scripting Advanced

![Day](https://img.shields.io/badge/Day-06-yellow?style=flat-square)
![Topic](https://img.shields.io/badge/Topic-Bash%20Advanced-blue?style=flat-square)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen?style=flat-square)

> 📅 Date: March 29, 2026
> ⏱️ Time Spent: 3+ hrs
> 🎯 Goal: Learn arrays, string operations, error handling and build a real backup script

---

## 📌 What I Learned Today

### 1. Arrays

```bash
# Define array
FRUITS=("Apple" "Banana" "Mango" "Orange")

# Access elements
echo "First fruit: ${FRUITS[0]}"    # Apple (starts from 0!)
echo "Second fruit: ${FRUITS[1]}"   # Banana

# All elements
echo "All fruits: ${FRUITS[@]}"     # Apple Banana Mango Orange

# Length of array
echo "Total fruits: ${#FRUITS[@]}"  # 4

# Loop through array
for FRUIT in "${FRUITS[@]}"; do
    echo "Fruit: $FRUIT"
done
```

**Output:**
```
First fruit: Apple
Second fruit: Banana
All fruits: Apple Banana Mango Orange
Total fruits: 4
Fruit: Apple
Fruit: Banana
Fruit: Mango
Fruit: Orange
```

**Key syntax:**
| Syntax | Meaning |
|--------|---------|
| `${ARRAY[0]}` | First element |
| `${ARRAY[@]}` | All elements |
| `${#ARRAY[@]}` | Length/count |

> 💡 Arrays in bash start from index **0** just like Python!

---

### 2. String Operations

```bash
NAME="DevOps Engineer"

echo "Length: ${#NAME}"              # 15
echo "Upper: ${NAME^^}"              # DEVOPS ENGINEER
echo "Lower: ${NAME,,}"              # devops engineer
echo "Replace: ${NAME/DevOps/Cloud}" # Cloud Engineer
echo "Slice: ${NAME:0:6}"            # DevOps (start:length)

# Check if string contains word
if [[ $NAME == *"Engineer"* ]]; then
    echo "Yes! Contains 'Engineer'"
fi
```

**Output:**
```
Length: 15
Upper: DEVOPS ENGINEER
Lower: devops engineer
Replace: Cloud Engineer
Slice: DevOps
Yes! Contains 'Engineer'
```

**String operations table:**
| Operation | Syntax | Example |
|-----------|--------|---------|
| Length | `${#VAR}` | `${#NAME}` → 15 |
| Uppercase | `${VAR^^}` | `${NAME^^}` → DEVOPS |
| Lowercase | `${VAR,,}` | `${NAME,,}` → devops |
| Replace | `${VAR/old/new}` | `${NAME/DevOps/Cloud}` |
| Slice | `${VAR:start:length}` | `${NAME:0:6}` → DevOps |
| Contains | `[[ $VAR == *"word"* ]]` | checks substring |

---

### 3. Error Handling

```bash
#!/bin/bash

# Exit immediately if any command fails
set -e

echo "Step 1: Creating folder..."
mkdir ~/testfolder

echo "Step 2: Creating file..."
touch ~/testfolder/test.txt

echo "Step 3: Done! ✅"

# Check exit status manually
ls ~/testfolder
if [ $? -eq 0 ]; then
    echo "Command succeeded! ✅"
else
    echo "Command failed! ❌"
fi
```

**Output:**
```
Step 1: Creating folder...
Step 2: Creating File...
Step 3: Done!
test.txt
Command succeeded! ✅
```

**Key concepts:**
| Concept | Meaning |
|---------|---------|
| `set -e` | Stop script immediately if any command fails |
| `$?` | Exit code of last command (0=success, other=fail) |
| `exit 1` | Manually exit script with failure code |

---

### 4. Mini Project — Backup Script 🎯

```bash
#!/bin/bash

echo "========================"
echo "Backup Script"
echo "========================"

SOURCE="$HOME/scripts"
BACKUP_DIR="$HOME/backups"
DATE=$(date +%Y-%m-%d_%H-%M-%S)
BACKUP_FILE="backup_$DATE.tar.gz"

# Create backup directory if not exists
if [ ! -d $BACKUP_DIR ]; then
    mkdir -p $BACKUP_DIR
    echo "Created backup directory ✅"
fi

# Create the backup
echo "Starting backup of $SOURCE..."
tar -czf $BACKUP_DIR/$BACKUP_FILE $SOURCE

# Check if backup succeeded
if [ $? -eq 0 ]; then
    echo "Backup successful! ✅"
    echo "File: $BACKUP_DIR/$BACKUP_FILE"
    echo "Size: $(du -sh $BACKUP_DIR/$BACKUP_FILE | cut -f1)"
else
    echo "Backup FAILED! ❌"
    exit 1
fi

echo "Done!"
```

**My output:**
```
========================
Backup Script
========================
Created backup directory ✅
Starting backup of /home/wagge/scripts...
Backup successful! ✅
File: /home/wagge/backups/backup_2026-03-29.tar.gz
Size: 4.0K
Done!
```

**tar flags explained:**
| Flag | Meaning |
|------|---------|
| `-c` | Create archive |
| `-z` | Compress with gzip |
| `-f` | Specify filename |

**date format:**
```bash
$(date +%Y-%m-%d_%H-%M-%S)
# Output: 2026-03-29_13-36-18
# %Y = year, %m = month, %d = day
# %H = hour, %M = minute, %S = second
```

---

## 💡 Key Concepts I Understood Today

- [x] Arrays start from index 0 — `${ARRAY[0]}`
- [x] `${ARRAY[@]}` = all elements, `${#ARRAY[@]}` = count
- [x] `${VAR^^}` uppercase, `${VAR,,}` lowercase
- [x] `${VAR:0:6}` slices string from position 0, length 6
- [x] `[[ $VAR == *"word"* ]]` checks if string contains word
- [x] `set -e` stops script if any command fails
- [x] `$?` = exit code of last command (0=success)
- [x] `tar -czf` creates a compressed backup archive
- [x] `! -d` checks if directory does NOT exist
- [x] `mkdir -p` creates nested directories

---

## ❌ Mistakes I Made (and Learned From)

| Mistake | Error | What I Learned |
|---------|-------|----------------|
| `data +%Y` | command not found | Typo! It's `date` not `data` |
| `$HOME?backups` | Permission denied | Typo! Use `/` not `?` → `$HOME/backups` |
| `$NAME==*"word"*` no spaces | syntax error | Always add spaces in `[[ ]]` conditions |

---

## 📚 Resources I Used Today
- [Bash Scripting Tutorial](https://www.youtube.com/watch?v=ZtqBQ68cfJc)
- [Linux Journey — Bash](https://linuxjourney.com)

---

## ✅ Tomorrow → Day 07: Review + Mini Project (Backup Script Polish)
