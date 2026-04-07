\# Day 16 — IAM: Users, Groups, Roles \& Policies



!\[Day](https://img.shields.io/badge/Day-16-yellow?style=flat-square)

!\[Topic](https://img.shields.io/badge/Topic-IAM-blue?style=flat-square)

!\[Status](https://img.shields.io/badge/Status-Completed-brightgreen?style=flat-square)



> 📅 Date: April 7, 2026

> ⏱️ Time Spent: 3+ hrs

> 🎯 Goal: Understand IAM — Users, Groups, Policies, Roles and create a real IAM user with console access



\---



\## 📌 What I Learned Today



\### 1. What is IAM?



IAM = \*\*Identity and Access Management\*\*



It controls \*\*WHO\*\* can do \*\*WHAT\*\* in your AWS account.



> Think of IAM like a security guard system for your AWS account.

> Without IAM, anyone with your password can do ANYTHING — delete servers, spend thousands of dollars, access all your data!



\*\*Two key questions IAM answers:\*\*

\- \*\*Authentication\*\* → Are you who you say you are? (login)

\- \*\*Authorization\*\* → Are you allowed to do this? (permissions)



\---



\### 2. IAM Core Components



\#### Users

\- Represents a \*\*real person\*\* or application

\- By default, a new IAM user has \*\*zero permissions\*\*

\- Each user gets their own login credentials



```

Root User (you — full access ⚠️ never use daily!)

└── IAM User: devops-user (limited permissions — use this daily ✅)

```



> ⚠️ \*\*Golden Rule:\*\* Never use the root account for daily work!

> Always create an IAM user and use that instead.



\---



\#### Groups

\- A \*\*collection of users\*\*

\- Attach permissions to the group → all users inherit them automatically

\- Much easier than assigning permissions to each user one by one



```

Group: devops-group (AdministratorAccess)

└── User: devops-user

&#x20;   → Inherits AdministratorAccess automatically! ✅

```



\*\*Why use groups?\*\*

```

Without groups: assign policy to user1, user2, user3... (tedious)

With groups:    assign policy to group → all users get it instantly!

```



\---



\#### Policies

\- A \*\*JSON document\*\* that defines what is allowed or denied

\- Says: "Allow or Deny this ACTION on this RESOURCE"



```json

{

&#x20; "Version": "2012-10-17",

&#x20; "Statement": \[

&#x20;   {

&#x20;     "Effect": "Allow",

&#x20;     "Action": "s3:GetObject",

&#x20;     "Resource": "arn:aws:s3:::my-bucket/\*"

&#x20;   }

&#x20; ]

}

```



Reading this policy:

\- \*\*Effect:\*\* Allow ✅ (can do it)

\- \*\*Action:\*\* s3:GetObject (read files from S3)

\- \*\*Resource:\*\* only from `my-bucket`



\*\*Two types of policies:\*\*



| Type | What it is |

|---|---|

| AWS Managed Policy | Pre-built by AWS (e.g. AdministratorAccess, ReadOnlyAccess) |

| Customer Managed Policy | You write it yourself for custom needs |



\---



\#### Roles

\- Like a user, but for \*\*AWS services\*\* (not people)

\- EC2 needs to access S3? Give it a \*\*Role\*\* — not an access key!

\- Roles use \*\*temporary credentials\*\* (more secure than permanent keys)



```

EC2 Instance  → assigned Role → can read from S3 ✅

Lambda        → assigned Role → can write to DynamoDB ✅

```



> 💡 Rule: \*\*Roles for services, Users for people\*\*



\---



\### 3. IAM Security Tools



\#### MFA (Multi-Factor Authentication)

\- Adds a second layer of security on top of password

\- Even if password is stolen, attacker can't login without your phone

\- Enable for root account and all important IAM users



\#### Access Keys

\- Used for \*\*CLI and API access\*\* (not console login)

\- Two parts: `Access Key ID` + `Secret Access Key`

\- Treat like passwords — never share, never commit to GitHub!



```bash

\# ❌ NEVER do this!

git add credentials.txt

git commit -m "added aws keys"

\# Your account WILL get compromised within minutes!

```



\---



\### 4. IAM Best Practices



| Practice | Why It Matters |

|---|---|

| Never use root account daily | Root has unlimited power — too dangerous |

| Create individual IAM users | Track who did what (audit trail) |

| Use groups for permissions | Easier to manage at scale |

| Grant least privilege | Give only what's needed, nothing more |

| Enable MFA for root + users | Extra protection if password is stolen |

| Never share access keys | Each person/service gets their own |

| Rotate access keys regularly | Reduces risk if keys are leaked |



\---



\### 5. Least Privilege Principle



> Give users \*\*only the permissions they need\*\* — nothing more!



```

Bad:  Give everyone AdministratorAccess (dangerous in production!)

Good: Give developers only EC2 + S3 access they actually need

```



> 💡 AdministratorAccess is fine for learning, but in real jobs

> you'll create custom policies with only what's needed!



\---



\## 🛠️ Hands-On Practice



\### Task 1 — Created IAM User

```

IAM → Users → Create user

→ Username: devops-user

→ Console access: enabled ✅

→ Password type: Custom password (set strong password)

→ Users must create new password at next sign-in: checked

→ Clicked Next ✅

```



\### Task 2 — Created Group + Attached Policy

```

Set permissions → Add user to group → Create group

→ Group name: devops-group

→ Policy attached: AdministratorAccess

→ Group created successfully! ✅ (green banner confirmed)

→ devops-user added to devops-group ✅

```



\### Task 3 — Retrieved Credentials

```

Step 4: Retrieve password

→ Console sign-in URL: https://173194475741.signin.aws.amazon.com/console

→ Username: devops-user

→ Password: (hidden)

→ Downloaded .csv file ✅

```



> ⚠️ This is the ONLY time AWS shows you the password — save it immediately!



\### Task 4 — Logged in as IAM User

```

→ Opened sign-in URL in incognito tab

→ Entered: devops-user + password

→ Top right confirmed: devops-user @ Waggepradeep (1731-9447-5741) ✅

```



\*\*What I noticed:\*\*

```

Some widgets showed "Access denied" errors on the dashboard

→ This is NORMAL even with AdministratorAccess

→ Some dashboard widgets (like Security Hub, Trusted Advisor) 

&#x20;  need extra service-level permissions or paid plans

→ Core services (EC2, S3, IAM) work perfectly fine ✅

```



\### Task 5 — Explored IAM Dashboard as devops-user

```

→ Saw Console Home with Solutions, Trusted Advisor, AWS Health sections

→ Region showed: Europe (Stockholm) — switched back to Mumbai ap-south-1

→ Confirmed devops-user can navigate the full AWS Console ✅

```



\---



\## 💡 Key Concepts I Understood Today



\- IAM = controls WHO can do WHAT in AWS

\- \*\*Root account\*\* = unlimited power — never use for daily work

\- \*\*IAM User\*\* = person with login credentials and assigned permissions

\- \*\*Group\*\* = collection of users sharing same permissions (use groups, not direct user policies!)

\- \*\*Policy\*\* = JSON document that says Allow/Deny on specific actions + resources

\- \*\*Role\*\* = like a user but for AWS services (EC2, Lambda etc.)

\- Always use \*\*Least Privilege\*\* — give only what's needed

\- Access keys are for CLI/API — never commit them to GitHub!

\- "Access denied" on some dashboard widgets is normal — not all widgets are free



\---



\## ❌ Mistakes I Made (and Learned From)



| Mistake | What Happened | What I Learned |

|---|---|---|

| Saw "Access denied" after logging in as devops-user | Panicked thinking something was wrong | This is normal — some dashboard widgets need extra permissions or paid plans. Core services still work! |

| Region changed to Europe (Stockholm) after IAM login | Console defaulted to a different region | Always check and reset region to Mumbai (ap-south-1) after logging in! |



\---



\## 🧠 Key Terms



| Term | Meaning |

|---|---|

| IAM | Identity and Access Management |

| Root User | The original account owner — full unlimited access |

| IAM User | A person or app with specific credentials and permissions |

| Group | A collection of IAM users sharing the same policies |

| Policy | JSON document defining Allow/Deny permissions |

| Role | Temporary permissions assigned to AWS services |

| MFA | Multi-Factor Authentication — second login layer |

| Access Key | CLI/API credentials (Key ID + Secret Key) |

| Least Privilege | Give only the minimum permissions needed |

| ARN | Amazon Resource Name — unique identifier for any AWS resource |



\---



\## 📅 What's Coming Next



| Day | Topic |

|---|---|

| Day 17 | EC2 — Launch, SSH, Security Groups |

| Day 18 | S3 — Buckets, Policies, Static Website |

| Day 19 | VPC — Subnets, Route Tables, IGW |

| Day 20 | AWS CLI Setup + Basic Commands |

| Day 21 | Mini Project — Static Site on S3 |



\---



\## 📚 Resources I Used Today



\- \[AWS IAM Documentation](https://docs.aws.amazon.com/IAM/latest/UserGuide/)

\- \[AWS IAM Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)

\- \[AWS Skill Builder](https://skillbuilder.aws)



\---



\## ✅ Tomorrow → Day 17: EC2 — Launch, SSH, Security Groups

