# Getting Started - For First-Time Users

**Never used Terraform or AWS before? Start here!**

---

## What You're About to Build

A complete, production-ready web application infrastructure on AWS that includes:
- Web servers to serve your website
- Application servers to run your backend code
- A database to store your data
- Load balancers to distribute traffic
- Automatic scaling to handle traffic spikes
- Monitoring and alerts

**Time needed**: 1-2 hours (first time)  
**Cost**: {}

---

## Step 1: Install Required Tools (15 minutes)

### Install Terraform

**Mac**:
```bash
brew install terraform
```

**Windows**:
1. Download from: https://www.terraform.io/downloads
2. Extract to `C:\terraform`
3. Add to PATH

**Linux**:
```bash
wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
unzip terraform_1.6.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/
```

**Verify**:
```bash
terraform version
# Should show: Terraform v1.x.x
```

### Install AWS CLI

**Mac**:
```bash
brew install awscli
```

**Windows**:
Download from: https://aws.amazon.com/cli/

**Linux**:
```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

**Verify**:
```bash
aws --version
# Should show: aws-cli/2.x.x
```

---

## Step 2: Set Up AWS Account (10 minutes)

### Create AWS Account

1. Go to: https://aws.amazon.com/
2. Click "Create an AWS Account"
3. Follow the signup process
4. **Important**: You'll need a credit card

### Create IAM User

1. Log into AWS Console: https://console.aws.amazon.com/
2. Go to: IAM → Users → Add User
3. User name: `terraform-user`
4. Access type: ✅ Programmatic access
5. Permissions: Attach `AdministratorAccess` policy
6. **Save the Access Key ID and Secret Access Key!**

### Configure AWS CLI

```bash
aws configure
```

Enter when prompted:
```
AWS Access Key ID: [paste your access key]
AWS Secret Access Key: [paste your secret key]
Default region name: ap-southeast-1
Default output format: json
```

**Test it works**:
```bash
aws sts get-caller-identity
# Should show your account info
```

---

## Step 3: Prepare for Deployment (15 minutes)

### Get the Code

```bash
# Clone the repository
git clone <repository-url>
cd <repository-directory>

# Look around
ls -la
# You should see: main.tf, modules/, README.md, etc.
```

### Create S3 Bucket for SSH Keys

```bash
# Choose a unique bucket name
# Format: your-company-terraform-keys
aws s3 mb s3://your-company-terraform-keys

# Verify it was created
aws s3 ls
```

### Create Your Configuration

```bash
# Copy the example file
cp terraform.tfvars.example terraform.tfvars

# Edit it (use any text editor)
nano terraform.tfvars
# or
code terraform.tfvars
# or
vim terraform.tfvars
```

### Fill in Your Values

Edit `terraform.tfvars` and change these lines:

```hcl
# Change these to your values:
project_name = "mycompany-prod"           # Your project name
environment  = "production"               # Keep as is
aws_region   = "ap-southeast-1"           # Keep as is (Singapore)

# Change this to your S3 bucket name:
ssh_key_s3_bucket = "your-company-terraform-keys"

# Optional: Add your IP for SSH access
# Get your IP: curl ifconfig.me
# my_ip = "YOUR_IP/32"

# Keep everything else as default for now
```

**Save the file!**

---

## Step 4: Deploy! (20 minutes)

### Initialize Terraform

```bash
terraform init
```

**What this does**: Downloads required plugins

**Expected output**:
```
Initializing modules...
Initializing the backend...
Initializing provider plugins...
Terraform has been successfully initialized!
```

### Preview What Will Be Created

```bash
terraform plan
```

**What this does**: Shows you what will be created (doesn't create anything yet)

**Expected output**:
```
Plan: 87 to add, 0 to change, 0 to destroy.
```

**Review the output**. You should see:
- VPC and subnets
- EC2 instances
- Load balancers
- RDS database
- Security groups
- etc.

### Create the Infrastructure

```bash
terraform apply
```

**What this does**: Actually creates everything in AWS

**You'll be asked**: `Do you want to perform these actions?`

**Type**: `yes` and press Enter

**Now wait**: This takes 15-20 minutes. You'll see progress:
```
module.networking.aws_vpc.main: Creating...
module.networking.aws_subnet.public[0]: Creating...
...
Apply complete! Resources: 87 added, 0 changed, 0 destroyed.
```

### Save the Outputs

```bash
# View outputs
terraform output

# Save to file
terraform output > my-infrastructure.txt
```

**Important outputs**:
- `bastion_public_ip`: IP address to SSH into
- `web_alb_dns_name`: URL of your web application
- `db_instance_endpoint`: Database connection string

---

## Step 5: Verify It Works (10 minutes)

### Test Web Access

```bash
# Get the web URL
terraform output web_alb_dns_name

# Test it (replace with your actual URL)
curl http://your-alb-url.amazonaws.com
```

**Or open in browser**: `http://your-alb-url.amazonaws.com`

### Test SSH Access

```bash
# Get bastion IP
BASTION_IP=$(terraform output -raw bastion_public_ip)

# SSH to bastion
ssh -i keys/*-bastion-key.pem ec2-user@$BASTION_IP
```

**If it works**, you'll see:
```
   ,     #_
   ~\_  ####_        Amazon Linux 2023
  ~~  \_#####\
  ~~     \###|
  ~~       \#/ ___   https://aws.amazon.com/linux/amazon-linux-2023
   ~~       V~' '->
    ~~~         /
      ~~._.   _/
         _/ _/
       _/m/'
[ec2-user@ip-10-0-1-x ~]$
```

**Type `exit` to disconnect**

### Check AWS Console

1. Go to: https://console.aws.amazon.com/
2. Navigate to:
   - **EC2**: See your instances running
   - **VPC**: See your VPC and subnets
   - **RDS**: See your database
   - **CloudWatch**: See your dashboard

---

## Step 6: What's Next?

### You Now Have:

✅ A working 3-tier infrastructure  
✅ Web servers running  
✅ Application servers running  
✅ Database running  
✅ Load balancers distributing traffic  
✅ Monitoring and alerts set up  

### Next Steps:

1. **Deploy Your Application**
   - Copy your web files to web servers
   - Copy your app code to app servers
   - Configure database connection

2. **Set Up Domain Name** (optional)
   - Buy a domain (e.g., example.com)
   - Point it to your ALB DNS name
   - Set up SSL certificate

3. **Monitor Costs**
   - Go to: AWS Console → Billing
   - Set up budget alerts
   - Review costs daily for first week

4. **Learn More**
   - Read: DEPLOYMENT_GUIDE.md
   - Read: QUICK_REFERENCE.md
   - Explore: CloudWatch dashboard

---

## Common Questions

### How much will this cost?

{}

**Breakdown**:
- EC2 instances: {}
- NAT Gateways: {} (most expensive!)
- Database: {}
- Load Balancers: {}
- Other: {}

**To reduce costs**: See DEPLOYMENT_GUIDE.md

### Can I stop it to save money?

**Yes!** To destroy everything:
```bash
terraform destroy
```

Type `yes` when asked.

**Warning**: This deletes EVERYTHING. Make backups first!

### What if something goes wrong?

1. **Don't panic!** Terraform tracks everything
2. Check: TROUBLESHOOTING.md
3. Run `terraform apply` again (it's safe)
4. If stuck, run `terraform destroy` and start over

### How do I update the infrastructure?

1. Edit `terraform.tfvars`
2. Run `terraform plan` to see changes
3. Run `terraform apply` to apply changes

### Where are my SSH keys?

- **Local**: `./keys/` directory
- **S3**: Your S3 bucket under `ssh-keys/`

**Keep them safe!** You need them to access your servers.

---

## Troubleshooting Quick Fixes

### "Permission denied" when SSH

```bash
# Fix key permissions
chmod 600 keys/*.pem
```

### "Connection timed out" when SSH

```bash
# Get your current IP
curl ifconfig.me

# Add to terraform.tfvars:
my_ip = "YOUR_IP/32"

# Apply changes
terraform apply
```

### "Bucket not found" error

```bash
# Create the S3 bucket
aws s3 mb s3://your-bucket-name

# Update terraform.tfvars with correct bucket name
```

### Terraform command not found

```bash
# Check if installed
which terraform

# If not found, reinstall (see Step 1)
```

### AWS credentials error

```bash
# Reconfigure AWS CLI
aws configure

# Test it works
aws sts get-caller-identity
```

---

## Getting Help

### Documentation

1. **Start here**: GETTING_STARTED.md (this file)
2. **Detailed guide**: DEPLOYMENT_GUIDE.md
3. **Problems**: TROUBLESHOOTING.md
4. **Quick commands**: QUICK_REFERENCE.md

### Online Resources

- **Terraform Docs**: https://www.terraform.io/docs
- **AWS Docs**: https://docs.aws.amazon.com/
- **AWS Support**: https://console.aws.amazon.com/support/

### Before Asking for Help

Collect this information:
```bash
# Terraform version
terraform version

# AWS CLI version
aws --version

# Error message (full output)
terraform apply 2>&1 | tee error.log

# Current state
terraform show > state.txt
```

---

## Success Checklist

After completing this guide, you should have:

- [ ] Terraform installed and working
- [ ] AWS CLI configured
- [ ] S3 bucket created
- [ ] terraform.tfvars configured
- [ ] Infrastructure deployed (`terraform apply` succeeded)
- [ ] Web application accessible
- [ ] SSH access to bastion working
- [ ] Outputs saved
- [ ] CloudWatch dashboard visible

**All checked?** Congratulations! 🎉

You now have a production-ready AWS infrastructure!

---

## What You Learned

✅ How to install Terraform  
✅ How to configure AWS CLI  
✅ How to deploy infrastructure as code  
✅ How to verify deployment  
✅ How to access your infrastructure  
✅ How to clean up resources  

---

## Next Learning Steps

1. **Understand the architecture**: Read README.md
2. **Learn Terraform basics**: https://learn.hashicorp.com/terraform
3. **Learn AWS basics**: https://aws.amazon.com/getting-started/
4. **Explore the code**: Look at `main.tf` and `modules/`
5. **Customize**: Try changing instance types, scaling settings

---

**Welcome to Infrastructure as Code!** 🚀

**Questions?** See TROUBLESHOOTING.md or DEPLOYMENT_GUIDE.md
