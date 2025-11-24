# Pre-Deployment Checklist

Complete this checklist before deploying the AWS 3-Tier Architecture.

---

## ✅ Prerequisites

### Tools Installation

- [ ] **Terraform installed** (>= 1.0)
  ```bash
  terraform version
  ```

- [ ] **AWS CLI installed** (>= 2.0)
  ```bash
  aws --version
  ```

- [ ] **Git installed**
  ```bash
  git --version
  ```

### AWS Account Setup

- [ ] **AWS account created** with admin access

- [ ] **AWS CLI configured**
  ```bash
  aws configure
  # Enter: Access Key ID, Secret Access Key, Region, Output format
  ```

- [ ] **Credentials verified**
  ```bash
  aws sts get-caller-identity
  # Should show your account ID and user ARN
  ```

- [ ] **IAM permissions verified**
  - EC2 full access
  - RDS full access
  - VPC full access
  - IAM role creation
  - S3 access
  - Secrets Manager access
  - CloudWatch access

---

## 📋 Configuration

### Required Information Gathered

- [ ] **Project name decided**: ________________
  - Lowercase, no spaces
  - Example: `mycompany-prod`

- [ ] **Environment name decided**: ________________
  - Options: `production`, `staging`, `development`

- [ ] **AWS region selected**: ________________
  - Default: `ap-southeast-1` (Singapore)
  - Other options: `us-east-1`, `eu-west-1`, etc.

- [ ] **VPC CIDR block decided**: ________________
  - Default: `10.0.0.0/16`
  - Must not conflict with existing VPCs

### S3 Bucket for SSH Keys

- [ ] **S3 bucket name decided**: ________________

- [ ] **S3 bucket created** (if doesn't exist)
  ```bash
  aws s3 mb s3://your-bucket-name
  ```

- [ ] **S3 bucket accessible**
  ```bash
  aws s3 ls s3://your-bucket-name
  ```

### SSH Access

- [ ] **Your public IP obtained**
  ```bash
  curl ifconfig.me
  # Note this IP: ________________
  ```

- [ ] **IP address in CIDR format**: ________________/32
  - Example: `203.0.113.45/32`


## 📁 Repository Setup

### Code Repository

- [ ] **Repository cloned**
  ```bash
  git clone <repo-url>
  cd <repo-directory>
  ```

- [ ] **On correct branch**
  ```bash
  git branch
  # Should show: * main or * master
  ```

- [ ] **Latest code pulled**
  ```bash
  git pull origin main
  ```

### Configuration Files

- [ ] **terraform.tfvars created**
  ```bash
  cp terraform.tfvars.example terraform.tfvars
  ```

- [ ] **terraform.tfvars edited** with your values
  - [ ] `project_name` set
  - [ ] `environment` set
  - [ ] `aws_region` set
  - [ ] `ssh_key_s3_bucket` set
  - [ ] `my_ip` set (optional)
  - [ ] Database settings reviewed
  - [ ] Scaling settings reviewed

- [ ] **terraform.tfvars NOT committed to Git**
  ```bash
  git status
  # Should NOT show terraform.tfvars
  ```

---

## 🔍 Pre-Flight Checks

### Terraform Validation

- [ ] **Terraform initialized**
  ```bash
  terraform init
  # Should complete without errors
  ```

- [ ] **Terraform validated**
  ```bash
  terraform validate
  # Should show: Success! The configuration is valid.
  ```

- [ ] **Terraform plan reviewed**
  ```bash
  terraform plan
  # Review resources to be created (~80-100 resources)
  ```

- [ ] **No errors in plan**

### AWS Service Limits

- [ ] **VPC limit checked** (need 1)
  ```bash
  aws ec2 describe-vpcs --query 'length(Vpcs)'
  # Should be less than your limit (usually 5)
  ```

- [ ] **Elastic IP limit checked** (need 3)
  ```bash
  aws ec2 describe-addresses --query 'length(Addresses)'
  # Should have room for 3 more
  ```

- [ ] **EC2 instance limit checked** (need 7)
  ```bash
  aws service-quotas get-service-quota \
    --service-code ec2 \
    --quota-code L-1216C47A
  # Check you have capacity for 7 instances
  ```

---

## 📝 Documentation Review

### Documents Read

- [ ] **README.md** reviewed
- [ ] **DEPLOYMENT_GUIDE.md** reviewed
- [ ] **QUICK_REFERENCE.md** reviewed
- [ ] **TROUBLESHOOTING.md** bookmarked

### Architecture Understanding

- [ ] **Architecture diagram** reviewed
- [ ] **Network layout** understood
  - 3 Availability Zones
  - 9 Subnets (3 public, 3 private app, 3 private DB)
  - 3 NAT Gateways
  - 2 Load Balancers

- [ ] **Security groups** understood
  - Web ALB → Web tier
  - Web tier → App ALB
  - App ALB → App tier
  - App tier → Database
  - Bastion → All tiers (SSH)

- [ ] **Data flow** understood
  - Internet → Web ALB → Web → App ALB → App → Database

---

## 🛡️ Security Considerations

### Security Best Practices

- [ ] **SSH keys will be auto-generated** (understood)
- [ ] **Database password will be in Secrets Manager** (understood)
- [ ] **VPC Flow Logs will be enabled** (understood)
- [ ] **Multi-AZ deployment** for high availability (understood)

### Access Control

- [ ] **Bastion host** will be the only entry point (understood)
- [ ] **Private subnets** have no direct internet access (understood)
- [ ] **Security groups** follow least privilege (understood)

---

## 📞 Support & Escalation

### Contact Information

- [ ] **AWS support plan** active (if needed)
- [ ] **Team contacts** available
  - DevOps lead: ________________
  - AWS admin: ________________
  - Emergency contact: ________________

### Rollback Plan

- [ ] **Rollback procedure** understood
  ```bash
  terraform destroy
  ```

- [ ] **Backup plan** for existing infrastructure (if any)

---

## 🚀 Ready to Deploy

### Final Checks

- [ ] **All above items checked**
- [ ] **Team notified** of deployment
- [ ] **Maintenance window** scheduled (if needed)
- [ ] **Monitoring** ready to watch deployment

### Deployment Command

```bash
# When ready, run:
terraform apply

# Review the plan one more time
# Type 'yes' to proceed
```

### Post-Deployment

- [ ] **Outputs saved**
  ```bash
  terraform output > infrastructure-details.txt
  ```

- [ ] **Verification tests** run (see DEPLOYMENT_GUIDE.md)

- [ ] **Team notified** of successful deployment

- [ ] **Documentation updated** with actual values
  - Bastion IP
  - Web ALB DNS
  - Database endpoint

---

## 📊 Deployment Timeline

Expected timeline:
- **Preparation**: 30 minutes
- **Terraform apply**: 15-20 minutes
- **Verification**: 10 minutes
- **Total**: ~1 hour

---

## ⚠️ Important Notes

1. **Do NOT commit** `terraform.tfvars` or `keys/` directory to Git
2. **Save outputs** immediately after deployment
3. **Test bastion access** before leaving
4. **Monitor costs** in first 24 hours
5. **Keep this checklist** for future deployments

---

**Checklist Completed**: _____ / _____ / _____  
**Completed By**: ________________  
**Deployment Date**: _____ / _____ / _____  
**Deployment Time**: _____ : _____

---

## ✅ Sign-Off

- [ ] **I have completed all items in this checklist**
- [ ] **I understand the costs involved**
- [ ] **I have approval to proceed**
- [ ] **I am ready to deploy**

**Signature**: ________________  
**Date**: _____ / _____ / _____

---

**Ready to deploy? Run**: `terraform apply`

**Need help? See**: `TROUBLESHOOTING.md`
