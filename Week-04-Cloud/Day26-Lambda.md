# Day 26 — AWS Lambda: Serverless Basics

![Day](https://img.shields.io/badge/Day-26-yellow?style=flat-square)
![Topic](https://img.shields.io/badge/Topic-AWS%20Lambda%20%2B%20Serverless-orange?style=flat-square)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen?style=flat-square)

> 📅 Date: April 10, 2026
> ⏱️ Time Spent: 3+ hrs
> 🎯 Goal: Understand serverless computing, build Lambda functions in Python, trigger them via S3 and EventBridge, invoke via CLI, and understand event-driven architecture

---

## 📌 What I Learned Today

### 1. What Problem Does This Solve?

**Traditional (EC2):**
```
Server runs 24/7 → you pay 24/7
No traffic at 3 AM → still paying 💸
```

**Serverless (Lambda):**
```
No traffic → no server running → $0
Request comes in → Lambda runs instantly → done → server gone
You pay only for actual execution time ✅
```

> 💡 Lambda = run code without managing any servers.
> AWS handles scaling, patching, availability — you just upload your function!

---

### 2. Core Concepts

#### Function
The actual code Lambda runs.

```python
def lambda_handler(event, context):
    return "Hello"
```

#### Event
Input data sent to Lambda when triggered.

```json
{
  "name": "Pradeep"
}
```

#### Trigger
A service that automatically invokes Lambda.

| Trigger | Use Case |
|---------|---------|
| S3 | File uploaded to bucket |
| EventBridge | Scheduled cron job |
| API Gateway | HTTP request hits your API |
| DynamoDB | Table item changed |
| SNS / SQS | Notification or message received |

#### Execution Role
IAM role that gives Lambda permission to access AWS services — CloudWatch, S3, DynamoDB etc.

#### Lambda Architecture

```
User / AWS Service
       ↓
    Trigger
       ↓
Lambda Function (runs your code)
       ↓
CloudWatch Logs / Response
```

---

### 3. Lambda Function Structure (Python)

```python
import json

def lambda_handler(event, context):
    # event → incoming request data
    # context → Lambda runtime info (request ID, timeout, function name)

    return {
        "statusCode": 200,
        "body": json.dumps("Hello")
    }
```

---

### 4. Key Lambda Settings

| Setting | Meaning |
|---------|---------|
| Runtime | Language (Python 3.12, Node.js 20 etc.) |
| Memory | 128MB to 10GB |
| Timeout | Max run time (default 3s, max 15min) |
| Environment variables | Config values injected at runtime |

---

### 5. Cold Start vs Warm Start

```
Cold start → Lambda not used recently → AWS spins up container → slight delay
Warm start → Lambda used recently → container already running → instant ⚡
```

---

### 6. EC2 vs Lambda

| | EC2 | Lambda |
|--|-----|--------|
| Server management | Manual | None — AWS handles it |
| Running | 24/7 | Only when triggered |
| Scaling | Manual / ASG | Automatic |
| Billing | Per hour (uptime) | Per execution |
| Use case | Long-running apps | Event-driven, short tasks |

---

### 7. Lambda Pricing

- First **1 million requests/month** → FREE
- First **400,000 GB-seconds/month** → FREE
- After that → $0.20 per million requests

> 💡 For learning and small projects → Lambda is essentially free!

---

## 🛠️ Steps I Performed

### Part A — Basic Lambda (Hello World)

- **Function name:** `devops-hello`
- **Runtime:** Python 3.12
- **Architecture:** x86_64
- **Execution role:** Auto-created with basic Lambda permissions

```python
import json

def lambda_handler(event, context):
    print("Lambda function triggered!")

    name = event.get("name", "DevOps Engineer")

    return {
        "statusCode": 200,
        "body": json.dumps({
            "message": f"Hello, {name}!",
            "day": "Day 26 - Lambda Basics",
            "status": "serverless is awesome 🚀"
        })
    }
```

---

### Part B — Tested Lambda

**Test event:**
```json
{
  "name": "Your_Name"
}
```

**Output:**
```json
{
  "statusCode": 200,
  "body": "Hello, Your_Name!"
}
```

> 💡 Lambda automatically sends all `print()` output to CloudWatch Logs:
> `CloudWatch → Log groups → /aws/lambda/devops-hello`

---

### Part C — Lambda + S3 Trigger

**Goal:** Run Lambda automatically when a file is uploaded to S3.

**S3 Event Notification:**
- Bucket: `devops-day18-pradeep001`
- Event type: `PUT` (file upload)
- Destination: Lambda function `devops-hello`

**Lambda code for S3 trigger:**

```python
import json

def lambda_handler(event, context):
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = event['Records'][0]['s3']['object']['key']
    size = event['Records'][0]['s3']['object']['size']

    print(f"New file uploaded!")
    print(f"Bucket: {bucket}")
    print(f"File: {key}")
    print(f"Size: {size} bytes")

    return {
        "statusCode": 200,
        "body": json.dumps(f"Processed {key} from {bucket}")
    }
```

**Tested by uploading via CLI:**
```bash
echo "test file" > test.txt
aws s3 cp test.txt s3://devops-day18-pradeep001/
```

**CloudWatch logs showed:**
```
New file uploaded!
Bucket: devops-day18-pradeep001
File: test.txt
Size: 10 bytes
```

✅ S3 → Lambda trigger working!

---

### Part D — Scheduled Lambda (Cron via EventBridge)

**Goal:** Run Lambda every minute automatically — serverless cron job!

- **Trigger:** EventBridge rule
- **Schedule expression:** `rate(1 minute)`

```python
from datetime import datetime

def lambda_handler(event, context):
    now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    print(f"Scheduled Lambda ran at: {now}")

    return {
        "statusCode": 200,
        "body": f"Ran at {now}"
    }
```

**CloudWatch logs showed:**
```
Scheduled Lambda ran at: 2026-05-06 11:00:13
Scheduled Lambda ran at: 2026-05-06 11:01:13
```

✅ Running every minute automatically — no server needed!

---

### Part E — Lambda via CLI

```bash
# List all Lambda functions
aws lambda list-functions --region ap-south-1

# Invoke function from CLI
aws lambda invoke \
  --function-name devops-hello \
  --payload '{"name": "CLI Your_Name"}' \
  --cli-binary-format raw-in-base64-out \
  output.json \
  --region ap-south-1

# Read output
cat output.json

# Get function details (runtime, memory, IAM role, ARN)
aws lambda get-function \
  --function-name devops-hello \
  --region ap-south-1 \
  --output json
```

---

### Cleanup Done ✅

```
EventBridge → Rules → every-minute → Delete
S3 → Event notifications → trigger-lambda-on-upload → Delete
Lambda → devops-hello → Delete
```

---

## 💡 Key Concepts I Understood Today

- Lambda = serverless compute — run code without managing servers
- `lambda_handler(event, context)` = entry point for every Lambda function
- `event` = incoming data, `context` = runtime info (request ID, timeout)
- Triggers invoke Lambda automatically — S3, EventBridge, API Gateway etc.
- Lambda auto-sends all logs to CloudWatch — no setup needed
- `rate(1 minute)` = EventBridge expression for cron-style scheduling
- Lambda is stateless — no data stored between executions
- Use S3 / DynamoDB / RDS for persistent storage alongside Lambda
- Lambda auto-scales — 1 request or 10,000 requests, same setup
- Always delete EventBridge rules after testing — they run forever otherwise

---

## ❌ Mistakes I Made (and Learned From)

| Mistake | Error | What I Learned |
|---------|-------|----------------|
| Tested S3 trigger code manually without S3 event structure | `KeyError: 'Records'` | S3 trigger code must be tested by actually uploading a file to S3 — not with a manual test event that lacks the `Records` key |

---

## 🔑 Mini Interview Questions

**Q: What is serverless?**
A cloud execution model where the cloud provider manages all infrastructure automatically — you only write and upload code.

**Q: What triggers Lambda?**
S3, EventBridge, API Gateway, DynamoDB, SNS, SQS and more.

**Q: Where are Lambda logs stored?**
CloudWatch Logs → `/aws/lambda/function-name`

**Q: Is Lambda always free?**
First 1 million requests/month + 400,000 GB-seconds are always free — enough for most learning projects.

---

## 🛠️ Services Used Today

| Service | Purpose |
|---------|---------|
| AWS Lambda | Run serverless code |
| S3 | File upload trigger |
| CloudWatch | Automatic logs + monitoring |
| EventBridge | Scheduling (cron) |
| IAM | Execution role permissions |
| AWS CLI | Invoke + manage functions |

---

## 📚 Resources I Used Today

- [AWS Lambda Docs](https://docs.aws.amazon.com/lambda/)
- [EventBridge Schedule Expressions](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-scheduled-rule-pattern.html)

---

## ✅ Tomorrow → Day 27: Cloud Security Best Practices
