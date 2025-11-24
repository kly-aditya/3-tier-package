# AWS 3-Tier Architecture - Deployment Guide

**Version**: 1.0  
**Last Updated**: November 2025  
**Target Audience**: DevOps Engineers, System Administrators

---

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Pre-Deployment Checklist](#pre-deployment-checklist)
3. [Quick Start (5 Minutes)](#quick-start-5-minutes)
4. [Detailed Deployment Steps](#detailed-deployment-steps)
5. [Post-Deployment Verification](#post-deployment-verification)
6. [Accessing Your Infrastructure](#accessing-your-infrastructure)
7. [Troubleshooting](#troubleshooting)
8. [Cost Estimation](#cost-estimation)
9. [Cleanup](#cleanup)

---

## Prerequisites

### Required Tools

Ensure you have the following installed:

| Tool | Version | Installation |
|------|---------|--------------|
| **Terraform** | >= 1.0 | https://www.terraform.io/downloads |
| **AWS CLI** | >= 2.0 | https://aws.amazon.com/cli/ |
| **Git** | Latest | https://git-scm.com/ |

### AWS Account Requirements

- ✅ AWS Account with admin access (or appropriate IAM permissions)
- ✅ AWS CLI configured with credentials
- ✅ S3 bucket for SSH key storage (will be created if needed)
- ✅ Sufficient service limits:
  - VPCs: 1
  - Elastic IPs: 3
  - NAT Gateways: 3
  - EC2 Instances: 7 (3 web + 3 app + 1 bastion)
  - RDS Instances: 1

### Verify AWS CLI Configuration

```bash
# Check AWS CLI is configured
aws sts get-caller-identity

# Expected output:
# {
#     "UserId": "AIDAXXXXXXXXXXXXXXXXX",
#     "Account": "123456789012",
#     "Arn": "arn:aws:iam::123456789012:user/your-username"
# }
```

---

## Pre-Deployment Checklist

Before deploying, ensure you have:

- [ ] AWS credentials configured (`aws configure`)
- [ ] Terraform installed (`terraform version`)
- [ ] Chosen an AWS region (default: `ap-southeast-1`)
- [ ] Decided on project name (e.g., `mycompany-prod`)
- [ ] Created or identified an S3 bucket for SSH keys
- [ ] Reviewed cost estimation (see below)
- [ ] Obtained approval for infrastructure costs (~$150-200/month)

---

## Quick Start (5 Minutes)

For experienced users who want to deploy immediately:

```bash
# 1. Clone repository
git clone <your-repo-url>
cd <repo-directory>

# 2. Copy and configure variables
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars  # Edit with your values

# 3. Initialize Terraform
terraform init

# 4. Review plan
terraform plan

# 5. Deploy
terraform apply -auto-approve

# 6. Get outputs
terraform output
```

**⏱️ Deployment Time**: ~15-20 minutes

---

## Detailed Deployment Steps

### Step 1: Clone Repository

```bash
git clone <your-repo-url>
cd <repo-directory>
```

### Step 2: Configure Variables

Create your configuration file:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your values:

```hcl
# Required Configuration
project_name = "mycompany-prod"        # Your project name
environment  = "production"            # Environment name
aws_region   = "ap-southeast-1"        # AWS region

# Network Configuration
vpc_cidr                 = "10.0.0.0/16"
availability_zones_count = 3

# Feature Flags
enable_nat_gateway = true              # Required for private subnet internet access
enable_flow_logs   = true              # Recommended for security

# SSH Key Storage
ssh_key_s3_bucket = "your-bucket-name" # S3 bucket for SSH key backup

# Database Configuration
db_instance_class    = "db.t3.micro"   # Start small, scale up later
db_name              = "appdb"
db_master_username   = "dbadmin"
db_multi_az          = true            # High availability

# Scaling Configuration
web_asg_min_size         = 3
web_asg_desired_capacity = 3
web_asg_max_size         = 6

# Your IP for SSH access (optional, for bastion)
my_ip = "YOUR_PUBLIC_IP/32"            # Get from: curl ifconfig.me
```

**Important**: Replace `YOUR_PUBLIC_IP` with your actual IP:
```bash
echo "my_ip = \"$(curl -s ifconfig.me)/32\""
```

### Step 3: Initialize Terraform

```bash
terraform init
```

**Expected Output**:
```
Initializing modules...
Initializing the backend...
Initializing provider plugins...
Terraform has been successfully initialized!
```

### Step 4: Review Deployment Plan

```bash
terraform plan
```

**Review**:
- Number of resources to be created (~80-100 resources)
- Estimated costs
- Resource names and configurations

**Key Resources**:
- 1 VPC
- 9 Subnets (3 public, 3 private app, 3 private DB)
- 3 NAT Gateways
- 2 Application Load Balancers
- 6 Auto Scaling Groups (web + app)
- 1 RDS PostgreSQL instance
- 1 Bastion host
- Security groups, IAM roles, CloudWatch resources

### Step 5: Deploy Infrastructure

```bash
terraform apply
```

Type `yes` when prompted.

**⏱️ Deployment Timeline**:
- VPC and networking: 2-3 minutes
- NAT Gateways: 2-3 minutes
- Load Balancers: 3-4 minutes
- EC2 Instances: 3-5 minutes
- RDS Database: 8-10 minutes
- **Total**: ~15-20 minutes

**Progress Indicators**:
```
module.networking.aws_vpc.main: Creating...
module.networking.aws_subnet.public[0]: Creating...
module.security.aws_security_group.web_alb: Creating...
...
Apply complete! Resources: 87 added, 0 changed, 0 destroyed.
```

### Step 6: Save Outputs

```bash
# View all outputs
terraform output

# Save to file
terraform output > infrastructure-details.txt

# Get specific values
terraform output bastion_public_ip
terraform output web_alb_dns_name
```

---

## Post-Deployment Verification

### 1. Verify Infrastructure

```bash
# Check VPC
aws ec2 describe-vpcs --filters "Name=tag:Name,Values=*${PROJECT_NAME}*"

# Check running instances
aws ec2 describe-instances \
  --filters "Name=instance-state-name,Values=running" \
  --query 'Reservations[*].Instances[*].[InstanceId,Tags[?Key==`Name`].Value|[0],State.Name]' \
  --output table

# Check RDS status
aws rds describe-db-instances \
  --query 'DBInstances[*].[DBInstanceIdentifier,DBInstanceStatus,Endpoint.Address]' \
  --output table
```

### 2. Test Web Access

```bash
# Get Web ALB DNS
WEB_ALB=$(terraform output -raw web_alb_dns_name)

# Test HTTP access
curl -I http://$WEB_ALB

# Expected: HTTP/1.1 200 OK
```

### 3. Test SSH Access to Bastion

```bash
# Get bastion IP
BASTION_IP=$(terraform output -raw bastion_public_ip)

# SSH to bastion
ssh -i keys/*-bastion-key.pem ec2-user@$BASTION_IP

# If successful, you should see Amazon Linux prompt
```

### 4. Verify Database Connectivity

```bash
# From bastion, test database connection
DB_ENDPOINT=$(terraform output -raw db_instance_endpoint)
DB_PASSWORD=$(aws secretsmanager get-secret-value \
  --secret-id $(terraform output -raw db_secret_name) \
  --query SecretString --output text | jq -r .password)

# Test connection
psql -h ${DB_ENDPOINT%:*} -U dbadmin -d appdb
```

---

## Accessing Your Infrastructure

### Web Application

```bash
# Get Web ALB URL
terraform output web_alb_dns_name

# Access in browser
http://<web-alb-dns-name>
```

### SSH Access

#### To Bastion Host

```bash
ssh -i keys/<project>-<env>-bastion-key.pem ec2-user@<bastion-ip>
```

#### To Web Instances (via Bastion)

```bash
# SSH to bastion first
ssh -i keys/<project>-<env>-bastion-key.pem ec2-user@<bastion-ip>

# From bastion, SSH to web instance
ssh -i ~/.ssh/web-key.pem ec2-user@<web-private-ip>
```

#### To App Instances (via Bastion)

```bash
# From bastion
ssh -i ~/.ssh/app-key.pem ec2-user@<app-private-ip>
```

### CloudWatch Dashboard

```bash
# Get dashboard URL
terraform output dashboard_url

# Or navigate to:
# AWS Console → CloudWatch → Dashboards → <project>-<env>-infrastructure
```

### Database Access

```bash
# Get database endpoint
terraform output db_instance_endpoint

# Get password from Secrets Manager
aws secretsmanager get-secret-value \
  --secret-id $(terraform output -raw db_secret_name) \
  --query SecretString --output text | jq -r .password

# Connect via bastion
ssh -i keys/*-bastion-key.pem ec2-user@<bastion-ip>
psql -h <db-endpoint> -U dbadmin -d appdb
```

---

## Troubleshooting

### Issue: Terraform Init Fails

**Error**: `Error: Failed to query available provider packages`

**Solution**:
```bash
# Clear Terraform cache
rm -rf .terraform .terraform.lock.hcl

# Re-initialize
terraform init
```

### Issue: Insufficient Permissions

**Error**: `Error: creating EC2 Instance: UnauthorizedOperation`

**Solution**:
- Verify AWS credentials: `aws sts get-caller-identity`
- Ensure IAM user/role has required permissions
- Check AWS service limits

### Issue: SSH Key Not Found

**Error**: `Error: file not found: keys/*.pem`

**Solution**:
```bash
# Keys are generated during terraform apply
# If missing, check S3 bucket:
aws s3 ls s3://<your-bucket>/ssh-keys/

# Download if needed:
aws s3 cp s3://<your-bucket>/ssh-keys/ ./keys/ --recursive
chmod 600 keys/*.pem
```

### Issue: Cannot Connect to Bastion

**Error**: `Connection timed out`

**Solution**:
1. Check security group allows your IP:
```bash
aws ec2 describe-security-groups \
  --filters "Name=tag:Name,Values=*bastion*" \
  --query 'SecurityGroups[*].IpPermissions'
```

2. Update `my_ip` in `terraform.tfvars` with your current IP
3. Run `terraform apply` to update security group

### Issue: RDS Creation Takes Too Long

**Normal**: RDS Multi-AZ can take 10-15 minutes

**Check Status**:
```bash
aws rds describe-db-instances \
  --query 'DBInstances[*].[DBInstanceIdentifier,DBInstanceStatus]'
```

### Issue: High Costs

**Solution**: See cost optimization section below

---

## Cost Estimation

### Monthly Cost Breakdown (ap-southeast-1)

| Service | Configuration | Monthly Cost (USD) |
|---------|--------------|-------------------|
| **EC2 Instances** | 7 × t3.micro (web/app/bastion) | ~$50 |
| **NAT Gateways** | 3 × NAT Gateway | ~$96 |
| **RDS PostgreSQL** | db.t3.micro Multi-AZ | ~$30 |
| **Application Load Balancers** | 2 × ALB | ~$35 |
| **EBS Volumes** | 7 × 30GB gp3 | ~$20 |
| **Data Transfer** | Moderate usage | ~$10 |
| **CloudWatch** | Logs + Metrics | ~$5 |
| **S3** | VPC Flow Logs | ~$2 |
| **Elastic IPs** | 3 × EIP | ~$3 |
| **Secrets Manager** | 1 secret | ~$0.50 |
| **TOTAL** | | **~$250/month** |

### Cost Optimization Tips

**Reduce to ~$100/month**:
- Use 1 NAT Gateway instead of 3 (⚠️ reduces HA)
- Use t3.micro for all instances
- Disable Multi-AZ for RDS (⚠️ reduces HA)
- Use 1 AZ instead of 3 (⚠️ not recommended)

**Production Recommendations**:
- Keep 3 NAT Gateways for HA
- Keep Multi-AZ RDS
- Use Reserved Instances for 30-40% savings
- Enable AWS Cost Explorer

---

## Cleanup

### Destroy All Resources

```bash
# Review what will be destroyed
terraform plan -destroy

# Destroy infrastructure
terraform destroy

# Type 'yes' when prompted
```

**⏱️ Destruction Time**: ~10-15 minutes

### If S3 Bucket Error Occurs

```bash
# Empty VPC Flow Logs bucket
aws s3 rm s3://<bucket-name> --recursive

# Retry destroy
terraform destroy
```

### Verify Cleanup

```bash
# Check for remaining resources
aws ec2 describe-instances --filters "Name=tag:Project,Values=<project-name>"
aws rds describe-db-instances
aws elbv2 describe-load-balancers
```

### Manual Cleanup (if needed)

```bash
# Delete any remaining resources via AWS Console:
# - EC2 → Instances
# - RDS → Databases
# - VPC → Your VPCs
# - S3 → Buckets (VPC Flow Logs)
```

---

## Support & Contact

For issues or questions:
- **Documentation**: See README.md
- **Architecture**: See architecture diagram
- **Issues**: Open GitHub issue
- **Email**: [Your team email]

---

## Appendix

### A. Required IAM Permissions

Minimum IAM permissions needed:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:*",
        "rds:*",
        "elasticloadbalancing:*",
        "autoscaling:*",
        "cloudwatch:*",
        "logs:*",
        "s3:*",
        "iam:*",
        "secretsmanager:*",
        "kms:*"
      ],
      "Resource": "*"
    }
  ]
}
```

### B. Network Diagram

```
Internet
   ↓
Internet Gateway
   ↓
Web ALB (Public)
   ↓
Web Tier (3 AZs) → NAT Gateways
   ↓
App ALB (Internal)
   ↓
App Tier (3 AZs)
   ↓
RDS PostgreSQL (Multi-AZ)
```

### C. Security Groups Summary

| Group | Inbound | Outbound |
|-------|---------|----------|
| Web ALB | 0.0.0.0/0:80,443 | Web tier:80 |
| Web Tier | Web ALB:80 | App ALB:80, Internet:443 |
| App ALB | Web tier:80 | App tier:3000 |
| App Tier | App ALB:3000 | RDS:5432, Internet:443 |
| RDS | App tier:5432 | None |
| Bastion | Your IP:22 | Web/App:22 |

---

**End of Deployment Guide**
