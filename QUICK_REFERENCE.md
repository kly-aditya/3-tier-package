# Quick Reference Card

**AWS 3-Tier Architecture - Command Cheat Sheet**

---

## 🚀 Deployment Commands

```bash
# Initialize
terraform init

# Plan
terraform plan

# Deploy
terraform apply -auto-approve

# Destroy
terraform destroy
```

---

## 📊 Get Information

```bash
# All outputs
terraform output

# Specific output
terraform output bastion_public_ip
terraform output web_alb_dns_name
terraform output db_instance_endpoint

# Save outputs to file
terraform output > outputs.txt
```

---

## 🔐 SSH Access

```bash
# Bastion
ssh -i keys/*-bastion-key.pem ec2-user@<bastion-ip>

# Web instance (from bastion)
ssh -i ~/.ssh/web-key.pem ec2-user@<web-private-ip>

# App instance (from bastion)
ssh -i ~/.ssh/app-key.pem ec2-user@<app-private-ip>
```

---

## 🗄️ Database Access

```bash
# Get DB password
aws secretsmanager get-secret-value \
  --secret-id $(terraform output -raw db_secret_name) \
  --query SecretString --output text | jq -r .password

# Connect (from bastion)
psql -h <db-endpoint> -U dbadmin -d appdb
```

---

## 🔍 Verification Commands

```bash
# Test web access
curl -I http://$(terraform output -raw web_alb_dns_name)

# List running instances
aws ec2 describe-instances \
  --filters "Name=instance-state-name,Values=running" \
  --query 'Reservations[*].Instances[*].[Tags[?Key==`Name`].Value|[0],InstanceId,PrivateIpAddress]' \
  --output table

# Check RDS status
aws rds describe-db-instances \
  --query 'DBInstances[*].[DBInstanceIdentifier,DBInstanceStatus]' \
  --output table

# Check ALB health
aws elbv2 describe-target-health \
  --target-group-arn $(aws elbv2 describe-target-groups \
    --names *-web-tg --query 'TargetGroups[0].TargetGroupArn' --output text)
```

---

## 📈 Monitoring

```bash
# CloudWatch dashboard URL
terraform output dashboard_url

# View recent logs
aws logs tail /aws/ec2/web --follow

# Check alarms
aws cloudwatch describe-alarms \
  --alarm-name-prefix $(terraform output -raw project_name)
```

---

## 🛠️ Troubleshooting

```bash
# Get your current IP
curl ifconfig.me

# Update security group with new IP
# Edit terraform.tfvars: my_ip = "NEW_IP/32"
terraform apply -target=module.security

# Check security group rules
aws ec2 describe-security-groups \
  --filters "Name=tag:Project,Values=$(terraform output -raw project_name)"

# View Terraform state
terraform show

# List all resources
terraform state list
```

---

## 💰 Cost Management

```bash
# Estimate costs (requires AWS Cost Explorer)
aws ce get-cost-and-usage \
  --time-period Start=2025-11-01,End=2025-11-30 \
  --granularity MONTHLY \
  --metrics BlendedCost

# List expensive resources
aws ec2 describe-nat-gateways  # ~$32/month each
aws rds describe-db-instances  # Check instance class
aws elbv2 describe-load-balancers  # ~$17/month each
```

---

## 🧹 Cleanup

```bash
# Empty S3 bucket (if destroy fails)
aws s3 rm s3://$(terraform output -raw vpc_flow_logs_s3_bucket) --recursive

# Destroy all
terraform destroy -auto-approve

# Force remove stuck resources
terraform state rm <resource-address>
```

---

## 📦 Backup & Export

```bash
# Backup Terraform state
cp terraform.tfstate terraform.tfstate.backup

# Export SSH keys
aws s3 sync s3://$(terraform output -raw ssh_key_s3_bucket)/ssh-keys/ ./keys-backup/

# Export database
ssh -i keys/*-bastion-key.pem ec2-user@<bastion-ip>
pg_dump -h <db-endpoint> -U dbadmin appdb > backup.sql
```

---

## 🔄 Updates

```bash
# Update specific module
terraform apply -target=module.web

# Refresh state
terraform refresh

# Import existing resource
terraform import aws_instance.example i-1234567890abcdef0
```

---

## 📝 Configuration Files

| File | Purpose |
|------|---------|
| `terraform.tfvars` | Your configuration (DO NOT COMMIT) |
| `terraform.tfvars.example` | Template for configuration |
| `main.tf` | Root module |
| `variables.tf` | Variable definitions |
| `outputs.tf` | Output definitions |
| `modules/` | Reusable modules |
| `keys/` | Generated SSH keys (DO NOT COMMIT) |

---

## 🌐 Important URLs

```bash
# Web Application
http://$(terraform output -raw web_alb_dns_name)

# CloudWatch Dashboard
$(terraform output -raw dashboard_url)

# AWS Console - EC2
https://console.aws.amazon.com/ec2/

# AWS Console - RDS
https://console.aws.amazon.com/rds/

# AWS Console - VPC
https://console.aws.amazon.com/vpc/
```

---

## 🆘 Emergency Contacts

- **AWS Support**: https://console.aws.amazon.com/support/
- **Terraform Docs**: https://www.terraform.io/docs
- **Project Issues**: [Your GitHub/GitLab URL]

---

## 📊 Default Values

| Parameter | Default Value |
|-----------|--------------|
| VPC CIDR | 10.0.0.0/16 |
| Availability Zones | 3 |
| Web Instances | 3 (t3.micro) |
| App Instances | 3 (t3.micro) |
| RDS Instance | db.t3.micro |
| NAT Gateways | 3 |
| Region | ap-southeast-1 |

---

**Last Updated**: November 2025  
**Version**: 1.0
