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
# Launch Template
# ------------------------------------------------------------------------------

resource "aws_launch_template" "bastion" {
  name_prefix   = "${var.project_name}-${var.environment}-bastion-"
  description   = "Launch template for Bastion host"
  image_id      = data.aws_ami.amazon_linux_2023.id
  instance_type = var.instance_type
  key_name      = var.key_name

  iam_instance_profile {
    arn = aws_iam_instance_profile.bastion.arn
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [var.bastion_security_group_id]
    delete_on_termination       = true
  }

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
  s3_bucket_name = var.s3_bucket_name
  s3_key_prefix  = var.s3_key_prefix
  project_name   = var.project_name
  environment    = var.environment
  region         = var.region
}))

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"  # IMDSv2 only
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(
      var.tags,
      {
        Name      = "${var.project_name}-${var.environment}-bastion"
        Component = "bastion"
        Phase     = "4"
      }
    )
  }

  tag_specifications {
    resource_type = "volume"
    tags = merge(
      var.tags,
      {
        Name      = "${var.project_name}-${var.environment}-bastion-volume"
        Component = "bastion"
        Phase     = "4"
      }
    )
  }

  tags = merge(
    var.tags,
    {
      Name      = "${var.project_name}-${var.environment}-bastion-lt"
      Component = "bastion"
      Phase     = "4"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# ------------------------------------------------------------------------------
# Auto Scaling Group (for high availability)
# ------------------------------------------------------------------------------

resource "aws_autoscaling_group" "bastion" {
  name_prefix         = "${var.project_name}-${var.environment}-bastion-"
  desired_capacity    = 1
  min_size            = 1
  max_size            = 1
  vpc_zone_identifier = var.public_subnet_ids
  health_check_type   = "EC2"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.bastion.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-${var.environment}-bastion-asg"
    propagate_at_launch = false
  }

  tag {
    key                 = "Component"
    value               = "bastion"
    propagate_at_launch = false
  }

  tag {
    key                 = "Phase"
    value               = "4"
    propagate_at_launch = false
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [desired_capacity]
  }
}

# ------------------------------------------------------------------------------
# Elastic IP for Bastion
# ------------------------------------------------------------------------------

resource "aws_eip" "bastion" {
  domain = "vpc"

  tags = merge(
    var.tags,
    {
      Name      = "${var.project_name}-${var.environment}-bastion-eip"
      Component = "bastion"
      Phase     = "4"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}


