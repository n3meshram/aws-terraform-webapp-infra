# 🚀 AWS Terraform WebApp Infrastructure (Dev → Stage → Prod)

## 📌 Overview

This project demonstrates a production-style DevOps workflow using:

* Terraform (Infrastructure as Code)
* Jenkins (CI/CD Pipeline)
* AWS (VPC, ALB, ASG, EC2, IAM)
* AWS Secrets Manager
* GitHub Webhooks
* Multi-Environment Deployment (Dev → Stage → Prod)

---

# 🧠 Architecture

```text
GitHub → Jenkins → Terraform → AWS

AWS Resources:
- VPC
- Public / Private Subnets
- NAT Gateway
- Security Groups
- Application Load Balancer
- Auto Scaling Group
- EC2 Instances
- IAM Roles
- AWS Secrets Manager
- S3 Backend
- DynamoDB Lock Table
```

---

# 📂 Project Structure

<<<<<<< HEAD
```
Feature Branch → PR → Terraform Plan
Merge → Terraform Apply
```

### Branch Strategy

| Branch  | Environment |
| ------- | ----------- |
| develop | Dev         |
| stage   | Stage       |
| main    | Production  |

---

## ⚙️ Key Features Implemented

### ✅ 1. Infrastructure as Code (Terraform)

* Modular structure (VPC, ASG, IAM, Launch Template)
* Environment-based tfvars (dev/stage/prod)

---

### ✅ 2. CI/CD Pipeline (Jenkins)

* PR-based Terraform Plan
* Controlled Apply on merge
* Environment detection via branch

---

### ✅ 3. Secure Secret Handling

#### Phase 1: SSM Parameter Store

* Stored password securely
* EC2 fetched password at runtime

#### Phase 2: Secrets Manager (Current)

* Secrets stored as JSON
* Retrieved dynamically using AWS CLI + `jq`
* No plaintext secrets stored on instance

---

### ✅ 4. Runtime Authentication (Demo App)

* Apache + CGI-based login system
* Password fetched dynamically from Secrets Manager
* No secrets exposed in UI

---

### ✅ 5. Auto Scaling & Launch Template

* AMI-based deployment
* ASG handles instance replacement
* Launch template updates trigger refresh

---

### ✅ 6. Drift Detection

* Terraform detects manual AWS changes
* Integrated into pipeline using:

  ```
  terraform plan -detailed-exitcode
  ```

---

### ✅ 7. tfplan Implementation

* Plan and Apply separation
* Ensures consistent deployments

---

### ✅ 8. Troubleshooting Experience

Handled real-world issues:

* SSM Agent offline
* IAM role misconfiguration
* IMDSv2 token issue
* NAT / SG issues
* Terraform destroy dependency failures
* Launch Template base64 encoding issue

---

## 🔐 AWS Secrets Manager Setup

This project uses AWS Secrets Manager to securely store application passwords for each environment.

---

### 📌 Secret Naming Convention

| Environment | Secret Name           |
| ----------- | --------------------- |
| Dev         | `/dev/app/password`   |
| Stage       | `/stage/app/password` |
| Prod        | `/prod/app/password`  |

---

## 🚀 Create Secrets

### ✅ Dev Secret

```bash
aws secretsmanager create-secret \
  --name "/dev/app/password" \
  --secret-string '{"password":"Dev@123"}' \
  --region ap-south-1
```

---

### ✅ Stage Secret

```bash
aws secretsmanager create-secret \
  --name "/stage/app/password" \
  --secret-string '{"password":"Stage@123"}' \
  --region ap-south-1
```

---

### ✅ Prod Secret

```bash
aws secretsmanager create-secret \
  --name "/prod/app/password" \
  --secret-string '{"password":"Prod@123"}' \
  --region ap-south-1
```

---

## 🔍 Verify Secret

```bash
aws secretsmanager get-secret-value \
  --secret-id "/prod/app/password" \
  --region ap-south-1
```

---

## ⚙️ IAM Permissions Required

The EC2 IAM role must allow:

```json
{
  "Effect": "Allow",
  "Action": [
    "secretsmanager:GetSecretValue"
  ],
  "Resource": "*"
}
```

> Note: For learning purposes `*` is used. In production, use least-privilege IAM policies.

---

## 🧠 How It Works

During EC2 startup, the application dynamically retrieves the password from AWS Secrets Manager using AWS CLI and `jq`.

Example:

```bash
APP_PASSWORD=$(aws secretsmanager get-secret-value \
  --secret-id "/${environment}/app/password" \
  --query SecretString \
  --output text | jq -r '.password')
```

This ensures:

* No hardcoded passwords
* Environment isolation
* Centralized secret management

---

## 🧪 Test Login

Access the application:

```text
http://<ALB-DNS>
```

Use the password configured in AWS Secrets Manager for the corresponding environment.

### Login Behavior

| Input Password | Result         |
| -------------- | -------------- |
| Correct        | Access Granted |
| Incorrect      | Access Denied  |

---

## ⚠️ Known Limitations

* CGI-based backend (for learning only)
* Secrets Manager policy is currently wide (`*`)
* No automated rotation yet
* No monitoring/alerting implemented

---

## 🚀 Future Enhancements

* 🔄 Secrets Manager automatic rotation (Lambda)
* 📊 CloudWatch monitoring & alerts
* 🗄️ RDS integration (stateful app)
* 🔐 IAM least-privilege policies
* 🐳 Containerization (Docker + ECS/EKS)

---

## 🧠 Key Learnings

* Terraform manages **state, not all AWS resources**
* Drift ≠ new resources, drift = modified resources
* Launch Templates require **base64 encoded user_data**
* Secrets should **never be stored on disk**
* CI/CD must enforce **plan → apply separation**

---

## 📂 Project Structure

```
=======
```text
>>>>>>> 6cb9ec2 (update readme.md)
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

# ⚙️ Prerequisites

Install the following tools:

```bash
terraform --version
aws --version
git --version
jenkins --version
```

---

# 🔐 AWS Account Setup

## Step 1 — Configure AWS CLI

```bash
aws configure
```

Provide:

* AWS Access Key
* AWS Secret Key
* Region: ap-south-1

---

# 🚀 Step 2 — Clone Repository

```bash
git clone https://github.com/n3meshram/aws-terraform-webapp-infra.git

cd aws-terraform-webapp-infra
```

---

# 🗂️ Step 3 — Create Terraform Backend

This project uses:

* S3 bucket → Terraform remote state
* DynamoDB table → State locking

---

## Option 1 — Using Terraform Bootstrap (Recommended)

```bash
cd bootstrap

terraform init
terraform apply -auto-approve
```

---

## Option 2 — Using Shell Script

```bash
chmod +x scripts/setup-backend.sh

./scripts/setup-backend.sh
```

---

# 🔍 Step 4 — Get Backend Outputs

Example:

```bash
terraform output
```

Example output:

```text
bucket_name = webapp-tf-state-xxxx
dynamodb_table = webapp-terraform-lock
```

---

# ⚙️ Step 5 — Configure Backend Files

Update backend.hcl files:

## Dev

File:

```text
environments/dev/backend.hcl
```

```hcl
bucket         = "webapp-tf-state-xxxx"
key            = "dev/terraform.tfstate"
region         = "ap-south-1"
dynamodb_table = "webapp-terraform-lock"
```

---

## Stage

File:

```text
environments/stage/backend.hcl
```

```hcl
bucket         = "webapp-tf-state-xxxx"
key            = "stage/terraform.tfstate"
region         = "ap-south-1"
dynamodb_table = "webapp-terraform-lock"
```

---

## Prod

File:

```text
environments/prod/backend.hcl
```

```hcl
bucket         = "webapp-tf-state-xxxx"
key            = "prod/terraform.tfstate"
region         = "ap-south-1"
dynamodb_table = "webapp-terraform-lock"
```

---

# 🔐 Step 6 — Create AWS Secrets

## Dev Secret

```bash
aws secretsmanager create-secret \
  --name "/dev/app/password" \
  --secret-string '{"password":"Dev@123"}'
```

---

## Stage Secret

```bash
aws secretsmanager create-secret \
  --name "/stage/app/password" \
  --secret-string '{"password":"Stage@123"}'
```

---

## Prod Secret

```bash
aws secretsmanager create-secret \
  --name "/prod/app/password" \
  --secret-string '{"password":"Prod@123"}'
```

---

# 🚀 Step 7 — Deploy DEV Environment

```bash
cd environments/dev

terraform init \
  -backend-config=backend.hcl \
  -reconfigure

terraform validate

terraform plan -var-file=dev.tfvars

terraform apply -var-file=dev.tfvars
```

---

# 🚀 Step 8 — Deploy STAGE Environment

```bash
cd environments/stage

terraform init \
  -backend-config=backend.hcl \
  -reconfigure

terraform apply -var-file=stage.tfvars
```

---

# 🚀 Step 9 — Deploy PROD Environment

```bash
cd environments/prod

terraform init \
  -backend-config=backend.hcl \
  -reconfigure

terraform apply -var-file=prod.tfvars
```

---

# 🌐 Access Application

```text
http://<ALB-DNS>
```

---

# 🔐 Authentication Flow

* User enters password on UI
* Apache CGI script calls AWS Secrets Manager
* Password validation happens dynamically
* No plaintext password stored on EC2

---

# ⚙️ Jenkins CI/CD Pipeline

## Pipeline Features

* PR → Terraform Plan
* Merge → Terraform Apply
* Multi-environment deployments
* Drift detection
* tfsec security scanning
* AWS credentials injection

---

# 🔄 Branch Strategy

| Branch    | Environment |
| --------- | ----------- |
| feature/* | Plan only   |
| develop   | Dev         |
| stage     | Stage       |
| main      | Production  |

---

# 🔐 Jenkins Credentials Required

## AWS Credentials

Type:

```text
AWS Credentials
```

ID:

```text
aws-creds
```

---

## GitHub Token

Required permissions:

* repo
* repo:status

---

# 🧪 Testing

## Successful Login

| Environment | Password  |
| ----------- | --------- |
| Dev         | Dev@123   |
| Stage       | Stage@123 |
| Prod        | Prod@123  |

---

# ⚠️ Known Limitations

* CGI-based backend
* Wide IAM permissions for learning
* No HTTPS yet
* No automated secret rotation
* No monitoring/alerting

---

# 🚀 Future Improvements

* Docker containerization
* EKS deployment
* HTTPS using ACM
* CloudWatch monitoring
* RDS integration
* Secrets rotation
* Least privilege IAM

---

# 🧠 Key Learnings

* Terraform backend requires:

  * backend block
  * backend config

* CI/CD pipelines should be stateless

* Environment isolation is critical

* Secrets should never be hardcoded

* Drift detection is important in production

---

# 👨‍💻 Author

Nitin Meshram
DevOps & Cloud Engineer

---

# 📌 Final Note

This project reflects a real-world DevOps workflow involving:

* Infrastructure automation
* CI/CD pipelines
* Multi-environment deployment
* Secret management
* Troubleshooting production-style issues


