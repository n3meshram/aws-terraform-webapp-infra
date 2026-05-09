# 🚀 AWS Terraform WebApp Infrastructure

Production-style multi-environment DevOps infrastructure project using Terraform, Jenkins, GitHub, and AWS.

---

# 📌 Project Goal

This project demonstrates how to:

* Build AWS infrastructure using Terraform
* Use modular Terraform architecture
* Configure remote backend using S3 + DynamoDB
* Implement multi-environment deployments
* Build CI/CD using Jenkins
* Use GitHub PR-based workflow
* Secure applications using AWS Secrets Manager
* Deploy applications behind ALB + ASG
* Troubleshoot real-world deployment issues

This repository is designed for learning real DevOps workflows and troubleshooting.

---

# 🧠 Architecture

```text
GitHub → Jenkins → Terraform → AWS

AWS Components:
- VPC
- Public Subnets
- Private Subnets
- NAT Gateway
- Internet Gateway
- Security Groups
- Application Load Balancer (ALB)
- Launch Template
- Auto Scaling Group (ASG)
- EC2 Instances
- IAM Roles
- AWS Secrets Manager
- SSM Session Manager
```

---

# 📂 Project Structure

```text
aws-terraform-webapp-infra/
│
├── Jenkinsfile
├── README.md
│
├── bootstrap/
│   ├── main.tf
│   ├── outputs.tf
│   ├── provider.tf
│   ├── variables.tf
│   └── versions.tf
│
├── environments/
│   ├── dev/
│   ├── stage/
│   └── prod/
│
├── global/
│   ├── provider.tf
│   └── versions.tf
│
├── modules/
│   ├── alb/
│   ├── autoscaling/
│   ├── iam/
│   ├── launch-template/
│   ├── security_group/
│   └── vpc/
│
└── scripts/
    └── setup-backend.sh
```

---

# 🌍 Branch Strategy

| Branch  | Environment |
| ------- | ----------- |
| develop | Dev         |
| stage   | Stage       |
| main    | Production  |

---

# ⚙️ Prerequisites

Install the following tools:

| Tool      | Version  |
| --------- | -------- |
| Terraform | >= 1.5   |
| AWS CLI   | Latest   |
| Git       | Latest   |
| Jenkins   | Latest   |
| VS Code   | Optional |
| ngrok     | Optional |

---

# 🔧 Verify Installation

## Terraform

```bash
terraform --version
```

---

## AWS CLI

```bash
aws --version
```

---

## Git

```bash
git --version
```

---

## Jenkins

```bash
jenkins --version
```

---

# ☁️ AWS Requirements

Required:

* AWS Account
* IAM User
* Programmatic Access
* AWS CLI Configured

For learning purposes you can temporarily use:

```text
AdministratorAccess
```

---

# 🔐 Configure AWS CLI

```bash
aws configure
```

Provide:

* Access Key
* Secret Key
* Region
* Output Format

Example:

```text
Region: ap-south-1
Output: json
```

---

# 📥 Clone Repository

```bash
git clone https://github.com/n3meshram/aws-terraform-webapp-infra.git

cd aws-terraform-webapp-infra
```

---

# 🚀 STEP 1 — Create Terraform Backend

Terraform remote backend uses:

* S3 Bucket → Terraform State
* DynamoDB → State Locking

---

## Go to Bootstrap Directory

```bash
cd bootstrap
```

---

## Initialize Terraform

```bash
terraform init
```

---

## Create Backend Resources

```bash
terraform apply -auto-approve
```

This creates:

* S3 bucket
* DynamoDB table

---

# 🚀 STEP 2 — Update backend.hcl

After bootstrap completes:

Update backend.hcl inside:

```text
environments/dev/
environments/stage/
environments/prod/
```

---

## Example backend.hcl

```hcl
bucket         = "your-terraform-state-bucket"
key            = "dev/terraform.tfstate"
region         = "ap-south-1"
dynamodb_table = "your-lock-table"
encrypt        = true
```

---

# 🔐 STEP 3 — Create Secrets in AWS

Secrets Manager is used for runtime authentication.

---

## Dev Secret

```bash
aws secretsmanager create-secret \
  --name "/dev/app/password" \
  --secret-string '{"password":"dev@123"}' \
  --region ap-south-1
```

---

## Stage Secret

```bash
aws secretsmanager create-secret \
  --name "/stage/app/password" \
  --secret-string '{"password":"stage@123"}' \
  --region ap-south-1
```

---

## Prod Secret

```bash
aws secretsmanager create-secret \
  --name "/prod/app/password" \
  --secret-string '{"password":"prod@123"}' \
  --region ap-south-1
```

---

# 🚀 STEP 4 — Deploy Dev Environment

```bash
cd environments/dev
```

---

## Initialize Backend

```bash
terraform init \
  -backend-config=backend.hcl \
  -reconfigure
```

---

## Deploy Infrastructure

```bash
terraform apply -var-file=dev.tfvars
```

---

# 🚀 STEP 5 — Deploy Stage Environment

```bash
cd environments/stage
```

---

## Initialize Backend

```bash
terraform init \
  -backend-config=backend.hcl \
  -reconfigure
```

---

## Deploy Infrastructure

```bash
terraform apply -var-file=stage.tfvars
```

---

# 🚀 STEP 6 — Deploy Production Environment

```bash
cd environments/prod
```

---

## Initialize Backend

```bash
terraform init \
  -backend-config=backend.hcl \
  -reconfigure
```

---

## Deploy Infrastructure

```bash
terraform apply -var-file=prod.tfvars
```

---

# 🧪 Application Testing

Get ALB DNS:

```text
EC2 → Load Balancers → DNS Name
```

Open:

```text
http://<ALB-DNS>
```

---

# 🔑 Test Credentials

| Environment | Password  |
| ----------- | --------- |
| Dev         | dev@123   |
| Stage       | stage@123 |
| Prod        | prod@123  |

---

# 🔄 CI/CD Workflow

```text
Feature Branch
      ↓
Pull Request
      ↓
Terraform Plan
      ↓
Merge Branch
      ↓
Terraform Apply
```

---

# ⚙️ Jenkins Setup

Install Jenkins locally.

---

## Install Required Tools on Jenkins Server

* Terraform
* AWS CLI
* Git
* tfsec

---

# 🔐 Configure Jenkins Credentials

Go to:

```text
Manage Jenkins → Credentials
```

Add:

```text
AWS Credentials
```

Credential ID Example:

```text
aws-creds
```

---

# 🌐 GitHub Webhook Setup

If Jenkins is local machine:

Use ngrok:

```bash
ngrok http 8080
```

Copy HTTPS URL.

---

## Configure GitHub Webhook

GitHub Repository:

```text
Settings → Webhooks
```

Payload URL:

```text
https://<ngrok-url>/github-webhook/
```

Content Type:

```text
application/json
```

---

# 🚀 Jenkins Pipeline Features

Implemented:

* Terraform Init
* Terraform Validate
* tfsec Scan
* Terraform Plan
* Terraform Apply
* Drift Detection
* Environment Detection
* PR-based workflow

---

# 🔍 Drift Detection

Terraform drift detection:

```bash
terraform plan -detailed-exitcode
```

---

# 🔐 Security Features

Implemented:

* Private EC2 instances
* SSM access
* IAM Roles
* Security Group isolation
* Secrets Manager integration
* No public SSH

---

# 🛠️ Common Issues & Fixes

## Backend Initialization Error

Error:

```text
Backend initialization required
```

Fix:

```bash
terraform init -backend-config=backend.hcl -reconfigure
```

---

## ALB 502 Bad Gateway

Possible Causes:

* Apache not installed
* User data failure
* NAT Gateway issue
* Target Group unhealthy

Check:

```bash
sudo cat /var/log/cloud-init-output.log
```

---

## Secrets Manager Access Denied

Verify:

* IAM role attached
* Secret exists
* Region configured

---

## Terraform State Lock Error

Check DynamoDB lock table.

Sometimes stale locks must be removed manually.

---

## Merge Conflict Issues

Recommended:

* Small feature branches
* Frequent merges
* Avoid long-lived branches

---

# 🧠 Key Learnings

This project helped understand:

* Terraform state management
* Remote backend architecture
* CI/CD pipelines
* Git branching workflow
* Runtime debugging
* Infrastructure drift
* ALB troubleshooting
* Secrets handling
* Auto Scaling behavior
* Immutable infrastructure concepts

---

# ⚠️ Known Limitations

Current limitations:

* CGI-based application
* No HTTPS
* No WAF
* No monitoring stack
* No secret rotation
* Secrets fetched per request

---

# 🚀 Future Enhancements

Planned improvements:

* Docker
* Amazon ECR
* ECS/EKS
* CloudWatch Monitoring
* Route53
* ACM SSL
* Blue/Green Deployments
* Lambda Secret Rotation
* GitHub Actions

---

# 👨‍💻 Author

Nitin Meshram

DevOps & Cloud Engineer

---

# 📌 Final Note

This project focuses on learning real-world DevOps deployment and troubleshooting workflows.

The goal was not only to deploy infrastructure but also to understand:

* runtime failures
* CI/CD debugging
* Git conflicts
* environment consistency
* infrastructure troubleshooting
* deployment automation

This repository evolved from a learning lab into a production-style infrastructure simulation project.
