# Day 05 — Bash Scripting Basics

![Day](https://img.shields.io/badge/Day-05-yellow?style=flat-square)
![Topic](https://img.shields.io/badge/Topic-Bash%20Scripting-blue?style=flat-square)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen?style=flat-square)

> 📅 Date: March 29, 2026
> ⏱️ Time Spent: 3+ hrs
> 🎯 Goal: Write real Bash scripts using variables, input, conditions, loops and functions

---

## 📌 What I Learned Today

### 1. Creating & Running a Script

```bash
mkdir ~/scripts      # create scripts folder
cd ~/scripts         # go into it
touch hello.sh       # create script file
nano hello.sh        # open editor
chmod +x hello.sh    # give execute permission
./hello.sh           # run the script!
```

> 💡 `./` means "run from current directory" — without it Linux won't find the script!

---

### 2. The Shebang Line

```bash
#!/bin/bash
```

> **MUST be the first line of every script!**
> Tells Linux to use bash to run this script
> Without it → script might not work correctly!

---

### 3. echo — Print to Screen

```bash
echo "Hello! My Name Is Wagge"
echo "I Am Learning DevOps!"
```

> `echo` = print text to screen (like `print()` in Python)

---

### 4. Variables

```bash
NAME="Wagge"
DAY="Day 05"
TOPIC="Bash Scripting"

echo "My name is $NAME"
echo "Today is $DAY"
echo "Topic: $TOPIC"
echo "Date: $(date)"
```

**Output:**
```
My name is Wagge
Today is Day 05
Topic: Bash Scripting
Date: Sun Mar 29 12:49:16 PM IST 2026
```

**Key rules:**
| Rule | Correct | Wrong |
|------|---------|-------|
| No spaces around = | `NAME="Wagge"` | `NAME = "Wagge"` |
| Use $ to read value | `$NAME` | `NAME` |
| Run command in script | `$(date)` | `date` |

---

### 5. User Input — read

```bash
echo "What is your name?"
read NAME

echo "How old are you?"
read AGE

echo "Hello $NAME! You are $AGE years old!"
```

> `read` = waits for user to type → stores in variable
> Like `input()` in Python!

---

### 6. If / Elif / Else Conditions

```bash
echo "Enter a number:"
read NUM

if [ $NUM -gt 10 ]; then
    echo "$NUM is greater than 10"
elif [ $NUM -eq 10 ]; then
    echo "$NUM is equal to 10"
else
    echo "$NUM is less than 10"
fi
```

**Key rules:**
- Spaces required inside `[ ]` → `[ $NUM -gt 10 ]` ✅ `[$NUM -gt 10]` ❌
- Every `if` must end with `fi`
- `then` goes after the condition

**Comparison operators:**
| Operator | Meaning |
|----------|---------|
| `-gt` | greater than |
| `-lt` | less than |
| `-eq` | equal to |
| `-ne` | not equal to |
| `-ge` | greater than or equal |
| `-le` | less than or equal |
| `-f` | file exists |
| `-d` | directory exists |

---

### 7. For Loop

```bash
for i in 1 2 3 4 5; do
    echo "Number: $i"
done
```

**Output:**
```
Number: 1
Number: 2
Number: 3
Number: 4
Number: 5
```

> `i` takes each value one by one
> `do` = start of loop body
> `done` = end of loop

**Range style:**
```bash
for i in {1..10}; do
    echo "Number: $i"
done
```

---

### 8. While Loop

```bash
COUNT=1
while [ $COUNT -le 5 ]; do
    echo "Count: $COUNT"
    COUNT=$((COUNT + 1))
done
```

**Output:**
```
Count: 1
Count: 2
Count: 3
Count: 4
Count: 5
```

> Keeps running **while** condition is true
> `$((COUNT + 1))` = arithmetic in bash
> Always increment counter or loop runs forever! ⚠️

---

### 9. Functions

```bash
# Define function
greet() {
    echo "Hello $1! Welcome to DevOps!"
}

check_file() {
    if [ -f $1 ]; then
        echo "$1 exists! ✅"
    else
        echo "$1 does NOT exist! ❌"
    fi
}

# Call functions
greet "Wagge"
greet "DevOps"
check_file "hello.sh"
check_file "missing.sh"
```

**Output:**
```
Hello Wagge! Welcome to DevOps!
Hello DevOps! Welcome to DevOps!
hello.sh exists! ✅
missing.sh does NOT exist! ❌
```

> `$1` = first argument passed to function
> `$2` = second argument, `$3` = third, and so on

---

### 10. Mini Project — System Info Script

```bash
#!/bin/bash

echo "================================"
echo "   SYSTEM INFO REPORT"
echo "================================"
echo "Hostname:    $(hostname)"
echo "User:        $(whoami)"
echo "Date:        $(date)"
echo "IP Address:  $(hostname -I | awk '{print $1}')"
echo "Uptime:      $(uptime -p)"
echo "Disk Usage:  $(df -h / | awk 'NR==2{print $5}')"
echo "Memory Used: $(free -h | awk 'NR==2{print $3}')"
echo "================================"
```

**My output:**
```
================================
   SYSTEM INFO REPORT
================================
Hostname:    wagge-HP-Pavilion-Laptop-14-dv2xxx
User:        wagge
Date:        Sun Mar 29 01:36:18 PM IST 2026
IP Address:  10.221.247.200
Uptime:      up 2 hours, 51 minutes
Disk Usage:  30%
Memory Used: 3.1Gi
================================
```

**New commands used:**
| Command | Meaning |
|---------|---------|
| `awk '{print $1}'` | Print first word of output |
| `NR==2` | Select line number 2 |
| `df -h /` | Disk usage of root partition |
| `free -h` | RAM usage in human readable format |
| `uptime -p` | How long system has been running |

---

## 💡 Key Concepts I Understood Today

- [x] Every script starts with `#!/bin/bash` (shebang)
- [x] `chmod +x` gives execute permission to script
- [x] `./script.sh` runs a script from current directory
- [x] Variables: no spaces around `=`, use `$` to read
- [x] `$(command)` runs a command inside a script
- [x] `read` takes user input like `input()` in Python
- [x] `if [ condition ]; then ... elif ... else ... fi`
- [x] Spaces are required inside `[ ]` in conditions
- [x] `for i in ...; do ... done` — for loop
- [x] `while [ condition ]; do ... done` — while loop
- [x] `$((expression))` does arithmetic in bash
- [x] Functions use `$1`, `$2` for arguments
- [x] `-f` checks if file exists, `-d` checks directory

---

## ❌ Mistakes I Made (and Learned From)

| Mistake | Error | What I Learned |
|---------|-------|----------------|
| Missing `fi` | syntax error: unexpected end of file | Every `if` must close with `fi` |
| `[$NUM -gt 10]` no spaces | command not found | Always add spaces inside `[ ]` |

---

## 📚 Resources I Used Today
- [Linux Journey — Bash Scripting](https://linuxjourney.com)
- [Bash Scripting Tutorial](https://www.youtube.com/watch?v=ZtqBQ68cfJc)

---

## ✅ Tomorrow → Day 06: Bash Scripting — Functions & Advanced Practice
