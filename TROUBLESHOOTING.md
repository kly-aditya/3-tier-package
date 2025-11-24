# Troubleshooting Guide

Common issues and solutions for AWS 3-Tier Architecture deployment.

---

## Table of Contents

1. [Terraform Issues](#terraform-issues)
2. [AWS Credential Issues](#aws-credential-issues)
3. [Network Connectivity Issues](#network-connectivity-issues)
4. [SSH Access Issues](#ssh-access-issues)
5. [Database Issues](#database-issues)
6. [Cost Issues](#cost-issues)
7. [Deployment Failures](#deployment-failures)

---

## Terraform Issues

### Issue: `terraform init` fails

**Error**:
```
Error: Failed to query available provider packages
```

**Solution**:
```bash
# Clear Terraform cache
rm -rf .terraform .terraform.lock.hcl

# Re-initialize
terraform init
```

---

### Issue: State lock error

**Error**:
```
Error: Error acquiring the state lock
```

**Solution**:
```bash
# If you're sure no other process is running:
terraform force-unlock <LOCK_ID>

# Or wait 15 minutes for automatic unlock
```

---

### Issue: Resource already exists

**Error**:
```
Error: creating EC2 Instance: InvalidKeyPair.Duplicate
```

**Solution**:
```bash
# Import existing resource
terraform import aws_key_pair.bastion <key-pair-name>

# Or delete existing resource manually
aws ec2 delete-key-pair --key-name <key-pair-name>
```

---

## AWS Credential Issues

### Issue: No credentials found

**Error**:
```
Error: No valid credential sources found
```

**Solution**:
```bash
# Configure AWS CLI
aws configure

# Verify credentials
aws sts get-caller-identity

# Check credentials file
cat ~/.aws/credentials
```

---

### Issue: Insufficient permissions

**Error**:
```
Error: creating EC2 Instance: UnauthorizedOperation
```

**Solution**:
1. Verify IAM permissions:
```bash
aws iam get-user
aws iam list-attached-user-policies --user-name <your-username>
```

2. Required permissions:
   - EC2 full access
   - RDS full access
   - VPC full access
   - IAM role creation
   - S3 access
   - Secrets Manager access

3. Contact AWS administrator to grant permissions

---

### Issue: Service limit exceeded

**Error**:
```
Error: creating EC2 Instance: InstanceLimitExceeded
```

**Solution**:
```bash
# Check current limits
aws service-quotas list-service-quotas \
  --service-code ec2 \
  --query 'Quotas[?QuotaName==`Running On-Demand Standard (A, C, D, H, I, M, R, T, Z) instances`]'

# Request limit increase via AWS Console:
# Service Quotas → AWS services → Amazon Elastic Compute Cloud (Amazon EC2)
```

---

## Network Connectivity Issues

### Issue: Cannot access web application

**Symptoms**:
- Browser shows "This site can't be reached"
- `curl` times out

**Diagnosis**:
```bash
# Get ALB DNS
WEB_ALB=$(terraform output -raw web_alb_dns_name)

# Test connectivity
curl -v http://$WEB_ALB

# Check ALB status
aws elbv2 describe-load-balancers \
  --names *-web-alb \
  --query 'LoadBalancers[*].[LoadBalancerName,State.Code]'
```

**Solutions**:

1. **ALB not ready**: Wait 2-3 minutes after deployment

2. **No healthy targets**:
```bash
# Check target health
aws elbv2 describe-target-health \
  --target-group-arn $(aws elbv2 describe-target-groups \
    --names *-web-tg --query 'TargetGroups[0].TargetGroupArn' --output text)

# If unhealthy, check instance status
aws ec2 describe-instance-status \
  --filters "Name=tag:Tier,Values=web"
```

3. **Security group issue**:
```bash
# Verify web ALB security group allows port 80
aws ec2 describe-security-groups \
  --filters "Name=tag:Name,Values=*web-alb*" \
  --query 'SecurityGroups[*].IpPermissions'
```

---

### Issue: Instances cannot reach internet

**Symptoms**:
- Cannot install packages
- Cannot download updates

**Diagnosis**:
```bash
# SSH to instance via bastion
ssh -i keys/*-bastion-key.pem ec2-user@<bastion-ip>
ssh -i ~/.ssh/web-key.pem ec2-user@<web-private-ip>

# Test internet connectivity
ping -c 3 8.8.8.8
curl -I https://www.google.com
```

**Solutions**:

1. **NAT Gateway not working**:
```bash
# Check NAT Gateway status
aws ec2 describe-nat-gateways \
  --filter "Name=state,Values=available" \
  --query 'NatGateways[*].[NatGatewayId,State,SubnetId]'

# Verify route table
aws ec2 describe-route-tables \
  --filters "Name=tag:Type,Values=Private" \
  --query 'RouteTables[*].Routes'
```

2. **Security group blocking outbound**:
```bash
# Check egress rules
aws ec2 describe-security-groups \
  --filters "Name=tag:Tier,Values=web" \
  --query 'SecurityGroups[*].IpPermissionsEgress'
```

---

## SSH Access Issues

### Issue: Cannot SSH to bastion

**Error**:
```
ssh: connect to host <ip> port 22: Connection timed out
```

**Solutions**:

1. **Check your IP changed**:
```bash
# Get your current IP
curl ifconfig.me

# Update terraform.tfvars
my_ip = "NEW_IP/32"

# Apply changes
terraform apply -target=module.security
```

2. **Verify security group**:
```bash
aws ec2 describe-security-groups \
  --filters "Name=tag:Name,Values=*bastion*" \
  --query 'SecurityGroups[*].IpPermissions'
```

3. **Check bastion is running**:
```bash
aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=*bastion*" \
  --query 'Reservations[*].Instances[*].[InstanceId,State.Name,PublicIpAddress]'
```

---

### Issue: Permission denied (publickey)

**Error**:
```
Permission denied (publickey,gssapi-keyex,gssapi-with-mic)
```

**Solutions**:

1. **Wrong key file**:
```bash
# List available keys
ls -la keys/

# Use correct key
ssh -i keys/*-bastion-key.pem ec2-user@<bastion-ip>
```

2. **Wrong permissions**:
```bash
# Fix key permissions
chmod 600 keys/*.pem

# Verify
ls -l keys/
```

3. **Wrong username**:
```bash
# Amazon Linux uses 'ec2-user'
ssh -i keys/*-bastion-key.pem ec2-user@<bastion-ip>

# NOT 'root' or 'admin'
```

---

### Issue: Cannot SSH from bastion to web/app instances

**Error**:
```
Permission denied (publickey)
```

**Solution**:
```bash
# Keys should be automatically distributed
# Check if keys exist on bastion
ssh -i keys/*-bastion-key.pem ec2-user@<bastion-ip>
ls -la ~/.ssh/

# If missing, keys are in S3:
aws s3 ls s3://<bucket>/ssh-keys/

# Re-run terraform apply to redistribute keys
```

---

## Database Issues

### Issue: Cannot connect to database

**Error**:
```
psql: could not connect to server: Connection timed out
```

**Solutions**:

1. **Database not ready**:
```bash
# Check RDS status
aws rds describe-db-instances \
  --query 'DBInstances[*].[DBInstanceIdentifier,DBInstanceStatus,Endpoint.Address]'

# Wait until status is 'available'
```

2. **Wrong endpoint**:
```bash
# Get correct endpoint
terraform output db_instance_endpoint

# Use without port
psql -h <endpoint-without-:5432> -U dbadmin -d appdb
```

3. **Security group issue**:
```bash
# Verify DB security group allows app tier
aws ec2 describe-security-groups \
  --filters "Name=tag:Name,Values=*database*" \
  --query 'SecurityGroups[*].IpPermissions'
```

4. **Wrong password**:
```bash
# Get password from Secrets Manager
aws secretsmanager get-secret-value \
  --secret-id $(terraform output -raw db_secret_name) \
  --query SecretString --output text | jq -r .password
```

---

### Issue: Database creation takes too long

**Normal Behavior**:
- RDS Multi-AZ can take 10-15 minutes
- This is expected

**Check Progress**:
```bash
# Monitor status
watch -n 30 'aws rds describe-db-instances \
  --query "DBInstances[*].[DBInstanceIdentifier,DBInstanceStatus]" \
  --output table'
```

---

## Cost Issues

### Issue: Unexpected high costs

**Diagnosis**:
```bash
# Check current month costs
aws ce get-cost-and-usage \
  --time-period Start=2025-11-01,End=2025-11-30 \
  --granularity MONTHLY \
  --metrics BlendedCost \
  --group-by Type=SERVICE

# Identify expensive resources
aws ec2 describe-nat-gateways  # ~$32/month each
aws rds describe-db-instances  # Check instance class
aws elbv2 describe-load-balancers  # ~$17/month each
```

**Solutions**:

1. **Reduce NAT Gateways** (⚠️ reduces HA):
```hcl
# In terraform.tfvars
enable_nat_gateway = false  # Or use 1 instead of 3
```

2. **Smaller instance types**:
```hcl
web_instance_type = "t3.micro"  # Instead of t3.small
db_instance_class = "db.t3.micro"  # Instead of db.t3.small
```

3. **Disable Multi-AZ** (⚠️ reduces HA):
```hcl
db_multi_az = false
```

4. **Use Reserved Instances** (30-40% savings):
```bash
# Purchase via AWS Console:
# EC2 → Reserved Instances → Purchase Reserved Instances
```

---

## Deployment Failures

### Issue: Terraform apply fails midway

**Symptoms**:
- Some resources created
- Error occurs
- Partial deployment

**Solution**:
```bash
# Don't panic! Terraform tracks state

# 1. Check what was created
terraform show

# 2. Fix the error (see error message)

# 3. Re-run apply (it will continue from where it stopped)
terraform apply

# 4. If stuck, target specific module
terraform apply -target=module.web
```

---

### Issue: Destroy fails with dependencies

**Error**:
```
Error: deleting EC2 Instance: DependencyViolation
```

**Solution**:
```bash
# 1. Try again (sometimes resources need time)
terraform destroy

# 2. If still fails, remove specific resource
terraform state rm <resource-address>

# 3. Manual cleanup via AWS Console
# EC2 → Instances → Terminate
# VPC → Delete VPC (deletes all dependencies)
```

---

### Issue: S3 bucket not empty error

**Error**:
```
Error: deleting S3 Bucket: BucketNotEmpty
```

**Solution**:
```bash
# Empty the bucket
aws s3 rm s3://<bucket-name> --recursive

# Retry destroy
terraform destroy
```

---

## Getting Help

### Collect Diagnostic Information

```bash
# 1. Terraform version
terraform version

# 2. AWS CLI version
aws --version

# 3. Current state
terraform show > state.txt

# 4. Error logs
terraform apply 2>&1 | tee terraform-error.log

# 5. AWS resource status
aws ec2 describe-instances > ec2-status.txt
aws rds describe-db-instances > rds-status.txt
aws elbv2 describe-load-balancers > alb-status.txt
```

### Contact Support

Include the following in your support request:
- Error message (full output)
- Terraform version
- AWS region
- What you were trying to do
- Diagnostic files above

---

## Common Error Messages

| Error | Meaning | Solution |
|-------|---------|----------|
| `InvalidKeyPair.Duplicate` | Key pair already exists | Delete existing or import |
| `UnauthorizedOperation` | Insufficient IAM permissions | Check IAM policies |
| `InstanceLimitExceeded` | Hit EC2 instance limit | Request limit increase |
| `DependencyViolation` | Resource has dependencies | Delete dependencies first |
| `BucketNotEmpty` | S3 bucket has objects | Empty bucket first |
| `Connection timed out` | Network/security group issue | Check security groups |
| `Permission denied` | SSH key issue | Check key file and permissions |

---

**Last Updated**: November 2025  
**Version**: 1.0
