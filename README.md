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

This is not just a Terraform lab — it is production mindset training.
