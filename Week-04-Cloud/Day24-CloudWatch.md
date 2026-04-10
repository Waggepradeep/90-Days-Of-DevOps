# Day 24 — AWS Monitoring, Alerting & Logging (CloudWatch + SNS + EC2)

![Day](https://img.shields.io/badge/Day-24-yellow?style=flat-square)
![Topic](https://img.shields.io/badge/Topic-CloudWatch%20%2B%20SNS%20%2B%20Logging-orange?style=flat-square)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen?style=flat-square)

> 📅 Date: April 09, 2026
> ⏱️ Time Spent: 3+ hrs
> 🎯 Goal: Build a complete monitoring + alerting + logging system on AWS — CPU alarms via CloudWatch, email alerts via SNS, and Nginx log shipping via CloudWatch Agent

---

## 📌 What I Learned Today

### 1. What Problem Does This Solve?

**Without CloudWatch:**
```
EC2 crashes at 3 AM → you find out next morning → users angry 😤
```

**With CloudWatch:**
```
CPU hits 90% → CloudWatch alarm fires → SNS sends email instantly 📧
            → Auto Scaling kicks in   → problem solved automatically ✅
```

> 💡 CloudWatch is the **eyes and ears** of your entire AWS infrastructure!

---

### 2. The Three Pillars of Observability

| Pillar | AWS Service | What it tracks |
|--------|------------|----------------|
| **Metrics** | CloudWatch Metrics | CPU, memory, network numbers |
| **Alerting** | CloudWatch Alarms + SNS | Notify when threshold crossed |
| **Logging** | CloudWatch Agent + Log Groups | Text output from apps/servers |

### 3. How They Connect

```
EC2 → Metrics  → CloudWatch → Alarm → SNS → Email 📧
EC2 → App Logs → CloudWatch Agent → CloudWatch Log Groups → searchable
```

### 4. CloudWatch Alarm States

```
OK               → metric is within threshold
Insufficient Data → not enough data yet (first few minutes)
In Alarm         → metric crossed threshold → alert fires!
```

> 💡 CloudWatch triggers ONLY on **state change** — not continuously.
> OK → In Alarm = 1 email. Won't send again until state changes back to OK and spikes again.

---

## 🛠️ Steps I Performed

### Step 1 — Created CloudWatch Alarm (CPU Monitoring)

- **Metric:** EC2 CPUUtilization
- **Condition:** CPU > 70% for 5 minutes
- **Name:** `devops-cpu-alarm`

Alarm state flow observed:
```
OK → Insufficient Data → In Alarm ✅
```

---

### Step 2 — Created SNS Email Alerts

```
SNS → Topics → Create topic
  Type: Standard
  Name: devops-alerts

SNS → devops-alerts → Create subscription
  Protocol: Email
  Endpoint: [my email address]
```

- Confirmed subscription via email link
- Linked SNS topic to CloudWatch alarm

✅ Email received when alarm triggered!

> ⚠️ Must confirm subscription via email — unconfirmed subscriptions stay "Pending"
> and never receive alerts!

---

### Step 3 — Generated CPU Load (Stress Test)

```bash
# Install stress tool
sudo apt update
sudo apt install stress -y

# Stress all CPUs for 5 minutes
stress --cpu 2 --timeout 300
```

✅ Results:
- CPU spiked to high utilization
- CloudWatch alarm state changed: `OK → In Alarm`
- Email alert received within minutes

---

### Step 4 — Installed CloudWatch Agent

> ⚠️ CloudWatch Agent is NOT available via `apt install` on Ubuntu — must install manually!

```bash
# Download .deb package directly
wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb

# Install
sudo dpkg -i amazon-cloudwatch-agent.deb
```

---

### Step 5 — IAM Role Setup

Created IAM role to allow EC2 to send logs to CloudWatch:

- **Role name:** `EC2-CloudWatch-Role`
- **Trusted entity:** EC2
- **Policy attached:** `CloudWatchAgentServerPolicy`
- Attached role to EC2 instance via:
  `EC2 → Instance → Actions → Security → Modify IAM role`

> 💡 Without the IAM role, the CloudWatch Agent has no permission to send
> logs to CloudWatch — it will run silently but nothing gets shipped!

---

### Step 6 — Configured Log Monitoring (Nginx → CloudWatch)

Created config file at `/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json`:

```json
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/nginx/access.log",
            "log_group_name": "nginx-access-logs",
            "log_stream_name": "{instance_id}"
          },
          {
            "file_path": "/var/log/nginx/error.log",
            "log_group_name": "nginx-error-logs",
            "log_stream_name": "{instance_id}"
          }
        ]
      }
    }
  }
}
```

---

### Step 7 — Started CloudWatch Agent

```bash
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
  -s
```

---

### Step 8 — Validated Logs

```bash
# Check logs locally on EC2
sudo tail -f /var/log/nginx/access.log
```

In AWS Console:
```
CloudWatch → Logs → Log Groups
  → nginx-access-logs ✅
  → nginx-error-logs  ✅
```

✅ Logs in CloudWatch matched terminal output exactly!

---

## 💡 Key Concepts I Understood Today

- CloudWatch Metrics = numbers AWS collects automatically (CPU, network, disk)
- CloudWatch Alarm = fires when metric crosses threshold
- SNS = notification service — delivers alerts via email, SMS, Lambda
- CloudWatch Agent = software installed on EC2 to ship logs and custom metrics
- IAM Role on EC2 = grants permission for EC2 to talk to CloudWatch
- `CloudWatchAgentServerPolicy` = the exact policy needed for log shipping
- Log Group = container for logs from one application/service
- Log Stream = logs from one specific instance (`{instance_id}`)
- Alarm triggers on **state change only** — not continuously
- Monitoring = metrics, Alerting = alarms + SNS, Logging = CloudWatch Agent
- Debugging is a core part of DevOps — service running ≠ correctly configured

---

## ❌ Mistakes I Made (and Learned From)

| Mistake | Error | What I Learned |
|---------|-------|----------------|
| Tried `apt install amazon-cloudwatch-agent` | Package not found | CloudWatch Agent must be installed manually via `.deb` file on Ubuntu |
| Placed config file in wrong path | Agent running but no logs in CloudWatch | Config must be at `/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json` |
| Didn't confirm SNS subscription | Subscription stayed "Pending", no emails | Must click confirmation link in email immediately after creating subscription |
| Expected repeated emails on stress re-run | No email on second stress test | CloudWatch alerts only on state change (OK → In Alarm), not continuously |
| Forgot to install Nginx before configuring log shipping | `/var/log/nginx/access.log` not found | Always verify the app is installed and running before configuring its log path |

---

## 🔥 Key Insight

```
Service running ≠ correctly configured

Always verify:
  → config path is correct
  → IAM role has correct permissions
  → actual output matches expected output
```

This is the real DevOps debugging mindset. 🧠

---

## 📚 Resources I Used Today

- [AWS CloudWatch Docs](https://docs.aws.amazon.com/cloudwatch/)
- [CloudWatch Agent Setup Guide](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Install-CloudWatch-Agent.html)
- [AWS SNS Docs](https://docs.aws.amazon.com/sns/)

---

## ✅ Tomorrow → Day 25: Route 53 + DNS Management
