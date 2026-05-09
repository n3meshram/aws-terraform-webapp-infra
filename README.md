# 🚀 AWS Terraform WebApp Infrastructure (Dev → Stage → Prod)

## 📌 Project Overview

This project demonstrates a **production-style DevOps pipeline** for deploying a web application on AWS using:

* Terraform (Infrastructure as Code)
* Jenkins (CI/CD Pipeline)
* AWS (EC2, ALB, ASG, VPC)
* AWS Secrets Manager (Secure Secret Handling)

---

## 🧠 Architecture

```
GitHub → Jenkins → Terraform → AWS

AWS Components:
- VPC (Public + Private Subnets)
- Application Load Balancer (ALB)
- Auto Scaling Group (ASG)
- EC2 (Private Subnet, SSM enabled)
- Secrets Manager (Password storage)
```

---

## 🔄 CI/CD Flow

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
aws-terraform-webapp-infra/
│
├── environments/
│   ├── dev/
│   ├── stage/
│   └── prod/
│
├── modules/
│   ├── vpc/
│   ├── autoscaling/
│   ├── launch-template/
│   └── iam/
│
├── Jenkinsfile
└── README.md
```

---

## 👨‍💻 Author

Nitin Meshram
DevOps & Cloud Engineer

---

## 📌 Final Note

This project simulates a **real-world DevOps environment** including:

* Multi-environment deployment
* Secure secret management
* CI/CD automation
* Troubleshooting real AWS issues

👉 This is not just a lab — this is **production mindset training**.
