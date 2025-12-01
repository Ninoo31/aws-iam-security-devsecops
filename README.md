# Day 1: AWS IAM Security & Infrastructure as Code

> **Learning Path**: Cloud Security Engineer / DevSecOps  
> **Focus**: IAM Roles, Least Privilege, Secure Cloud Infrastructure  
> **Tools**: Terraform, AWS (VPC, EC2, S3, IAM)

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Setup Instructions](#setup-instructions)
- [Security Concepts Demonstrated](#security-concepts-demonstrated)
- [Testing & Validation](#testing--validation)
- [Key Learnings](#key-learnings)
- [Troubleshooting](#troubleshooting)
- [Cleanup](#cleanup)
- [Next Steps](#next-steps)

---

## 🎯 Overview

This project demonstrates **secure cloud infrastructure deployment** using Infrastructure as Code (Terraform) with a focus on **IAM security best practices**.

### What This Project Demonstrates

✅ **IAM Roles** instead of hardcoded credentials  
✅ **Least Privilege Principle** in action  
✅ **Network Segmentation** (public/private subnets)  
✅ **Security Groups** with IP whitelisting  
✅ **Temporary Credentials** via AWS STS  
✅ **IMDSv2** for enhanced EC2 metadata security  

### Real-World Use Case

This setup mimics a production scenario where:
- An EC2 instance needs to access S3 buckets
- **Zero credentials** are stored on the instance
- Access is controlled via IAM roles
- Permissions can be modified instantly without touching the instance

---

## 🏗️ Architecture
```
┌─────────────────────────────────────────────────────────────┐
│                         AWS Cloud                            │
│                                                               │
│  ┌────────────────────────────────────────────────────┐    │
│  │              VPC (10.0.0.0/16)                     │    │
│  │                                                      │    │
│  │  ┌──────────────────────────────────────────┐     │    │
│  │  │  Public Subnet (10.0.1.0/24)             │     │    │
│  │  │                                            │     │    │
│  │  │  ┌─────────────────────────────────┐     │     │    │
│  │  │  │   EC2 Instance (t3.micro)       │     │     │    │
│  │  │  │   ┌─────────────────────────┐   │     │     │    │
│  │  │  │   │  Instance Profile       │   │     │     │    │
│  │  │  │   │  (ec2-s3-readonly)      │   │     │     │    │
│  │  │  │   └──────────┬──────────────┘   │     │     │    │
│  │  │  └──────────────┼──────────────────┘     │     │    │
│  │  │                 │                          │     │    │
│  │  │                 │ AssumeRole              │     │    │
│  │  └─────────────────┼──────────────────────────┘     │    │
│  │                    │                                │    │
│  │  ┌─────────────────▼─────────────┐                 │    │
│  │  │   Internet Gateway            │                 │    │
│  │  └───────────────────────────────┘                 │    │
│  └────────────────────────────────────────────────────┘    │
│                         │                                   │
│                         │                                   │
│  ┌──────────────────────▼──────────┐  ┌──────────────────┐│
│  │      AWS STS                     │  │   IAM Role       ││
│  │  (Temporary Credentials)         │  │  ec2-s3-readonly ││
│  │  • Access Key (temp)             │  │                  ││
│  │  • Secret Key (temp)             │  │  Permissions:    ││
│  │  • Session Token                 │  │  ✅ s3:GetObject ││
│  │  • Expires: 6 hours              │  │  ✅ s3:ListBucket││
│  └──────────────────────────────────┘  │  ❌ s3:PutObject ││
│                                         │  ❌ s3:DeleteObj ││
│                                         └──────────────────┘│
│                         │                                   │
│  ┌──────────────────────▼──────────────────────────────┐  │
│  │               S3 Bucket                              │  │
│  │          halim-iam-security-2024                     │  │
│  │  ┌────────────────────────────────────────────┐     │  │
│  │  │  • test-file.txt                           │     │  │
│  │  │  • Public access: BLOCKED                  │     │  │
│  │  └────────────────────────────────────────────┘     │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘

Security Layers:
├─ Network: Security Group (SSH from specific IP only)
├─ Identity: IAM Role (no hardcoded credentials)
├─ Authorization: IAM Policy (read-only S3 access)
└─ Metadata: IMDSv2 (prevents SSRF attacks)
```

### Component Interaction Flow
```
1. EC2 starts → 2. Requests credentials → 3. AWS STS validates Trust Policy
                                                      ↓
                                              ✅ "EC2 can assume this role"
                                                      ↓
                                          4. STS generates temporary credentials
                                             (expires in 6 hours)
                                                      ↓
5. EC2 uses credentials → 6. AWS IAM checks permissions → 7. S3 grants/denies access
   automatically             "Does role have s3:GetObject?"      based on policy
```

---

## 📦 Prerequisites

### Required Tools

- **Terraform** >= 1.0
- **AWS CLI** >= 2.0
- **SSH client**
- **Git**

### AWS Account Setup

1. AWS Account (Free Tier eligible)
2. IAM user with permissions:
   - EC2 full access
   - VPC management
   - IAM role/policy management
   - S3 bucket management

### Local Setup
```bash
# Install AWS CLI (macOS)
brew install awscli

# Install AWS CLI (Linux)
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Configure AWS CLI
aws configure
# Enter your Access Key ID
# Enter your Secret Access Key
# Default region: eu-west-3 (or your preferred region)
# Default output format: json

# Verify configuration
aws sts get-caller-identity
```

---

## 📁 Project Structure
```
day1-iam-security/
├── main.tf                    # Root module - orchestrates all resources
├── variables.tf               # Input variables
├── outputs.tf                 # Output values (IPs, bucket names, etc.)
├── terraform.tfvars          # Variable values (⚠️ don't commit with secrets)
│
├── modules/
│   ├── iam/                  # IAM Role & Policy management
│   │   ├── main.tf           # Role, Trust Policy, Permission Policy
│   │   ├── variables.tf      # Module inputs
│   │   └── outputs.tf        # Instance profile name, Role ARN
│   │
│   ├── vpc/                  # Network infrastructure
│   │   ├── main.tf           # VPC, Subnets, IGW, Route Tables, SG
│   │   ├── variables.tf      # CIDR blocks, allowed IPs
│   │   └── outputs.tf        # VPC ID, Subnet IDs, SG ID
│   │
│   └── ec2/                  # Compute resources
│       ├── main.tf           # EC2 instance, S3 bucket
│       ├── variables.tf      # Instance type, subnet, profile
│       └── outputs.tf        # Public IP, bucket name
│
└── README.md                 # This file
```

### Module Responsibilities

| Module | Purpose | Key Resources |
|--------|---------|---------------|
| **iam** | Identity & Access Management | IAM Role, Trust Policy, Permission Policy, Instance Profile |
| **vpc** | Network Infrastructure | VPC, Subnets, Internet Gateway, Route Tables, Security Groups |
| **ec2** | Compute & Storage | EC2 Instance, S3 Bucket, Test File |

---

## 🚀 Setup Instructions

### Step 1: Clone the Repository
```bash
git clone <your-repo-url>
cd day1-iam-security
```

### Step 2: Create SSH Key Pair
```bash
# Generate SSH key
ssh-keygen -t rsa -b 4096 -f ~/.ssh/aws-lab-key -N ""

# Import to AWS
aws ec2 import-key-pair \
  --key-name "lab-key" \
  --public-key-material fileb://~/.ssh/aws-lab-key.pub \
  --region your-region
```

### Step 3: Configure Variables

Get your public IP:
```bash
curl https://ifconfig.me
```

Create `terraform.tfvars`:
```hcl
aws_region  = "eu-north-1"
my_ip       = "YOUR_PUBLIC_IP/32"  # Example: "203.0.113.45/32"
bucket_name = "YOUR-UNIQUE-BUCKET-NAME"  # Must be globally unique
```

⚠️ **Security Note**: Add `terraform.tfvars` to `.gitignore` to prevent committing sensitive data.

### Step 4: Deploy Infrastructure
```bash
# Initialize Terraform (download providers)
terraform init

# Preview changes
terraform plan

# Deploy (type 'yes' when prompted)
terraform apply
```

**Expected output**:
```
Apply complete! Resources: 15 added, 0 changed, 0 destroyed.

Outputs:

ec2_public_ip = "54.123.45.67"
s3_bucket_name = "your-bucket-name""
ssh_command = "ssh -i ~/.ssh/aws-lab-key ec2-user@54.123.45.67"
```

---

## 🔐 Security Concepts Demonstrated

### 1. IAM Roles vs. IAM Users

| Aspect | IAM User (❌ Bad Practice) | IAM Role (✅ Best Practice) |
|--------|---------------------------|----------------------------|
| Credentials | Permanent Access Keys | Temporary via STS |
| Storage | Stored on disk (`~/.aws/credentials`) | Never stored, injected by AWS |
| Rotation | Manual (often forgotten) | Automatic every ~6 hours |
| Revocation | Slow (delete key manually) | Instant (modify policy) |
| Audit | Difficult to trace | Full CloudTrail logging |
| Security Risk | High (if stolen, permanent access) | Low (credentials expire quickly) |

### 2. Trust Policy vs. Permission Policy
```hcl
# TRUST POLICY: "WHO can assume this role?"
# Answer: EC2 service only
data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]  # ← Only EC2 can use this role
    }
  }
}

# PERMISSION POLICY: "WHAT can this role do?"
# Answer: Read S3 only
data "aws_iam_policy_document" "s3_readonly" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",      # ← Can download files
      "s3:ListBucket"      # ← Can list files
    ]
    resources = [
      "arn:aws:s3:::bucket-name",
      "arn:aws:s3:::bucket-name/*"
    ]
  }
}
```

**Real-world analogy**:
- **Trust Policy** = Security badge check at building entrance ("Are you an employee?")
- **Permission Policy** = Keycard access to specific rooms ("Which rooms can you enter?")

### 3. AWS STS (Security Token Service)

**What is STS?**  
The "vending machine" for temporary AWS credentials.

**How it works**:
```
EC2 Instance starts
    ↓
Contacts AWS STS: "I need credentials"
    ↓
STS checks Trust Policy: "Can EC2 assume this role?"
    ✅ YES
    ↓
STS generates temporary credentials:
    • AWS_ACCESS_KEY_ID (starts with "ASIA" - temporary!)
    • AWS_SECRET_ACCESS_KEY
    • AWS_SESSION_TOKEN
    • Expiration: 6 hours
    ↓
EC2 uses credentials automatically
    ↓
Before expiration (~5h 45min), AWS auto-renews
```

**Why temporary credentials are better**:
- ✅ Auto-expire (max 12 hours)
- ✅ Auto-renewed while instance runs
- ✅ If stolen, short-lived impact
- ✅ Zero storage on disk

### 4. Least Privilege Principle

**Definition**: Grant only the minimum permissions needed to perform a task.

**In this project**:
```
❌ Bad: Give EC2 full S3 access (s3:*)
✅ Good: Give only read access (s3:GetObject, s3:ListBucket)

Result:
- ✅ Can list bucket: aws s3 ls s3://bucket/
- ✅ Can read file: aws s3 cp s3://bucket/file.txt -
- ❌ Cannot write: aws s3 cp local.txt s3://bucket/  → Access Denied
- ❌ Cannot delete: aws s3 rm s3://bucket/file.txt  → Access Denied
```

### 5. IMDSv2 (Instance Metadata Service v2)

**Security enhancement** to prevent SSRF attacks.
```hcl
metadata_options {
  http_endpoint               = "enabled"
  http_tokens                 = "required"  # ← Forces IMDSv2
  http_put_response_hop_limit = 1
}
```

**How it protects**:

**IMDSv1 (vulnerable)**:
```bash
# Attacker exploits SSRF vulnerability
curl http://169.254.169.254/latest/meta-data/iam/security-credentials/role-name
# ❌ Gets credentials directly!
```

**IMDSv2 (secure)**:
```bash
# Requires token first
TOKEN=$(curl -X PUT -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" \
  http://169.254.169.254/latest/api/token)

# Then use token to get credentials
curl -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/
# ✅ SSRF attacks blocked!
```

---

## ✅ Testing & Validation

### Test 1: Verify IAM Role is Working
```bash
# SSH into the instance
ssh -i ~/.ssh/aws-lab-key ec2-user@$(terraform output -raw ec2_public_ip)

# Once connected, verify identity
aws sts get-caller-identity
```

**Expected output**:
```json
{
    "UserId": "AROAXXXXXXXXX:i-04285aee8ffa3d9d4",
    "Account": "200651372884",
    "Arn": "arn:aws:sts::200651372884:assumed-role/ec2-s3-readonly-role/i-xxxxx"
}
```

✅ **Success indicator**: The ARN contains `assumed-role` (not `user`)

### Test 2: Verify Read Access (Should Work)
```bash
# List bucket contents
BUCKET=$(aws s3 ls | grep iam-security | awk '{print $3}')
aws s3 ls s3://$BUCKET/

# Download file
aws s3 cp s3://$BUCKET/test-file.txt -
```

**Expected output**:
```
Hello from secure IAM! If you can read this, your role works perfectly.
```

### Test 3: Verify Write is Blocked (Should Fail)
```bash
# Try to delete file
aws s3 rm s3://$BUCKET/test-file.txt
```

**Expected output**:
```
delete failed: s3://bucket/test-file.txt An error occurred (AccessDenied) when calling 
the DeleteObject operation: Access Denied
```

✅ **Success indicator**: Access Denied error (proves least privilege is working)

### Test 4: Network Security

From your local machine (not the EC2):
```bash
# This should work (your IP is whitelisted)
ssh -i ~/.ssh/aws-lab-key ec2-user@<EC2_IP>

# From another IP (friend's computer), this should TIMEOUT
# (Security Group blocks all IPs except yours)
```

---

## 🎓 Key Learnings

### What You Built

✅ Secure cloud infrastructure with zero hardcoded credentials  
✅ Modular Terraform code (reusable components)  
✅ Network segmentation (public/private subnets)  
✅ IAM best practices (roles, least privilege)  
✅ Automated credential rotation via STS  

### Security Principles Applied

| Principle | Implementation | Why It Matters |
|-----------|----------------|----------------|
| **Least Privilege** | Read-only S3 access | Limits blast radius if compromised |
| **Defense in Depth** | Network SG + IAM roles | Multiple security layers |
| **No Secrets in Code** | IAM roles instead of keys | Prevents credential leakage |
| **Temporary Credentials** | AWS STS auto-rotation | Reduces window of exposure |
| **Immutable Infrastructure** | Terraform IaC | Reproducible, version-controlled |

### Common Pitfalls Avoided

❌ **Don't do**: Store AWS keys in `~/.aws/credentials` on EC2  
✅ **Do**: Use IAM roles with temporary credentials

❌ **Don't do**: Give broad `s3:*` permissions  
✅ **Do**: Grant specific actions only (GetObject, ListBucket)

❌ **Don't do**: Allow SSH from `0.0.0.0/0` (entire internet)  
✅ **Do**: Whitelist specific IPs in Security Group

❌ **Don't do**: Use IMDSv1 (vulnerable to SSRF)  
✅ **Do**: Enforce IMDSv2 via `metadata_options`

---

## 🐛 Troubleshooting

### Issue: "Access Denied" when running Terraform

**Symptom**:
```
Error: UnauthorizedOperation: You are not authorized to perform this operation
```

**Solution**:
Check your IAM user permissions. You need:
```json
{
  "Effect": "Allow",
  "Action": [
    "ec2:*",
    "iam:*",
    "s3:*",
    "sts:GetCallerIdentity"
  ],
  "Resource": "*"
}
```

### Issue: Cannot SSH to EC2

**Symptom**:
```
ssh: connect to host X.X.X.X port 22: Operation timed out
```

**Solutions**:
1. Verify your IP in `terraform.tfvars` matches your current public IP:
```bash
   curl https://ifconfig.me
```
2. Check Security Group rules in AWS Console
3. Ensure key permissions: `chmod 400 ~/.ssh/aws-lab-key`

### Issue: "Bucket already exists"

**Symptom**:
```
Error: creating S3 Bucket: BucketAlreadyExists
```

**Solution**:
S3 bucket names must be globally unique. Change `bucket_name` in `terraform.tfvars`:
```hcl
bucket_name = "your-unique-name-12345"
```

### Issue: "No default VPC available"

**Symptom**:
```
Error: Default VPC not found
```

**Solution**:
This project creates its own VPC, so this shouldn't occur. If it does, ensure you're not referencing default VPC in code.

---

## 🧹 Cleanup

**Important**: Always destroy resources to avoid AWS charges!
```bash
# Destroy all resources
terraform destroy
# Type 'yes' when prompted

# Verify everything is deleted
aws ec2 describe-instances --filters "Name=tag:Name,Values=iam-test-instance"
aws s3 ls | grep iam-security
```

**Manual cleanup** (if needed):
```bash
# Delete S3 bucket (if Terraform fails)
aws s3 rb s3://your-bucket-name --force

# Delete key pair
aws ec2 delete-key-pair --key-name lab-key

# Remove local SSH key
rm ~/.ssh/aws-lab-key*
```

---

## 📚 Resources

### Official Documentation
- [AWS IAM Roles](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles.html)
- [AWS STS](https://docs.aws.amazon.com/STS/latest/APIReference/welcome.html)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

### Security Best Practices
- [AWS Security Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)
- [CIS AWS Foundations Benchmark](https://www.cisecurity.org/benchmark/amazon_web_services)

---

## 📝 License

This project is for educational purposes. Feel free to use and modify.

---

## 🤝 Contributing

Improvements welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Submit a pull request

---

## 👤 Author

**Your Name**  
Learning Path: Cloud Security Engineer / DevSecOps

---

## ⭐ Acknowledgments

Built as part of a structured DevSecOps learning program focusing on:
- Cloud security fundamentals
- Infrastructure as Code
- Least privilege access control
- Automated security testing

---

**Last Updated**: November 2025