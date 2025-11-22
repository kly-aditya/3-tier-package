# Bastion Module - Main Configuration

# Get latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

# ------------------------------------------------------------------------------
# IAM Role for Bastion Host
# ------------------------------------------------------------------------------

# IAM role for bastion instance
resource "aws_iam_role" "bastion" {
  name_prefix = "${var.project_name}-${var.environment}-bastion-"
  description = "IAM role for Bastion host"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name      = "${var.project_name}-${var.environment}-bastion-role"
      Component = "bastion"
      Phase     = "4"
    }
  )
}

#  IAM POLICY: S3 Access for SSH Keys
# ============================================================================

resource "aws_iam_role_policy" "bastion_s3_keys" {
  name = "${var.project_name}-${var.environment}-bastion-s3-keys"
  role = aws_iam_role.bastion.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.s3_bucket_name}",
          "arn:aws:s3:::${var.s3_bucket_name}/${var.s3_key_prefix}/web/*",
          "arn:aws:s3:::${var.s3_bucket_name}/${var.s3_key_prefix}/app/*"
        ]
      }
    ]
  })
}

# ============================================================================
# IAM POLICY: EC2 Describe for Helper Scripts
# ============================================================================

resource "aws_iam_role_policy" "bastion_ec2_describe" {
  name = "${var.project_name}-${var.environment}-bastion-ec2-describe"
  role = aws_iam_role.bastion.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceStatus",
          "ec2:DescribeTags"
        ]
        Resource = "*"
      }
    ]
  })
}



# Attach SSM managed policy for Session Manager (optional, but recommended)
resource "aws_iam_role_policy_attachment" "bastion_ssm" {
  role       = aws_iam_role.bastion.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Attach CloudWatch policy for logging
resource "aws_iam_role_policy_attachment" "bastion_cloudwatch" {
  role       = aws_iam_role.bastion.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# Secrets Manager read access
resource "aws_iam_role_policy_attachment" "bastion_secrets_manager" {
  role       = aws_iam_role.bastion.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

# Instance profile
resource "aws_iam_instance_profile" "bastion" {
  name_prefix = "${var.project_name}-${var.environment}-bastion-"
  role        = aws_iam_role.bastion.name

  tags = merge(
    var.tags,
    {
      Name      = "${var.project_name}-${var.environment}-bastion-profile"
      Component = "bastion"
      Phase     = "4"
    }
  )
}

# ------------------------------------------------------------------------------
# EC2 Instance - Single Bastion Host
# ------------------------------------------------------------------------------

resource "aws_instance" "bastion" {
  ami           = data.aws_ami.amazon_linux_2023.id
  instance_type = var.instance_type
  key_name      = var.key_name
  
  # Network configuration
  subnet_id                   = var.public_subnet_ids[0]
  vpc_security_group_ids      = [var.bastion_security_group_id]
  associate_public_ip_address = true

  # IAM role
  iam_instance_profile = aws_iam_instance_profile.bastion.name

  # User data script
  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    s3_bucket_name = var.s3_bucket_name
    s3_key_prefix  = var.s3_key_prefix
    project_name   = var.project_name
    environment    = var.environment
    region         = var.region
  }))

  # IMDSv2 (security best practice)
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  # Enable detailed monitoring
  monitoring = true

  # Root volume
  root_block_device {
    volume_type           = "gp3"
    volume_size           = 20
    delete_on_termination = true
    encrypted             = true
  }

  # Tags
  tags = merge(
    var.tags,
    {
      Name      = "${var.project_name}-${var.environment}-bastion"
      Component = "bastion"
      Phase     = "4"
    }
  )

  volume_tags = merge(
    var.tags,
    {
      Name      = "${var.project_name}-${var.environment}-bastion-volume"
      Component = "bastion"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# ------------------------------------------------------------------------------
# Elastic IP - Automatically Attached to Bastion Instance
# ------------------------------------------------------------------------------

resource "aws_eip" "bastion" {
  instance = aws_instance.bastion.id
  domain   = "vpc"

  tags = merge(
    var.tags,
    {
      Name      = "${var.project_name}-${var.environment}-bastion-eip"
      Component = "bastion"
      Phase     = "4"
    }
  )

  depends_on = [aws_instance.bastion]
}


