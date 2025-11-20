# ==============================================================================
# WEB TIER MODULE - PHASE 6
# ==============================================================================
# Creates:
# - Launch Template with Apache + PHP
# - Auto Scaling Group (3 AZs)
# - IAM Role for CloudWatch Logs + SSM
# ==============================================================================

# ------------------------------------------------------------------------------
# DATA SOURCES
# ------------------------------------------------------------------------------

# Get latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
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
# IAM ROLE FOR WEB INSTANCES
# ------------------------------------------------------------------------------

# IAM Role
resource "aws_iam_role" "web" {
  name = "${var.project_name}-${var.environment}-web-role"

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
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-web-role"
    }
  )
}

# Attach AWS managed policy for SSM (Session Manager)
resource "aws_iam_role_policy_attachment" "web_ssm" {
  role       = aws_iam_role.web.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Attach AWS managed policy for CloudWatch Agent
resource "aws_iam_role_policy_attachment" "web_cloudwatch" {
  role       = aws_iam_role.web.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# Instance Profile
resource "aws_iam_instance_profile" "web" {
  name = "${var.project_name}-${var.environment}-web-profile"
  role = aws_iam_role.web.name

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-web-profile"
    }
  )
}

# ------------------------------------------------------------------------------
# LAUNCH TEMPLATE
# ------------------------------------------------------------------------------

resource "aws_launch_template" "web" {
  name_prefix   = "${var.project_name}-${var.environment}-web-"
  description   = "Launch template for web tier instances"
  image_id      = data.aws_ami.amazon_linux_2023.id
  instance_type = var.instance_type
  key_name = var.ssh_key_name

  # IAM instance profile
  iam_instance_profile {
    name = aws_iam_instance_profile.web.name
  }

  # Security group
  vpc_security_group_ids = [var.web_sg_id]

  # User data script
  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    environment = var.environment
  }))

  # Monitoring
  monitoring {
    enabled = true
  }

  # Metadata options (IMDSv2)
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  # Block device mappings
  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = var.root_volume_size
      volume_type           = "gp3"
      delete_on_termination = true
      encrypted             = true
    }
  }

  # Tags
  tag_specifications {
    resource_type = "instance"

    tags = merge(
      var.common_tags,
      {
        Name = "${var.project_name}-${var.environment}-web-instance"
        Tier = "web"
      }
    )
  }

  tag_specifications {
    resource_type = "volume"

    tags = merge(
      var.common_tags,
      {
        Name = "${var.project_name}-${var.environment}-web-volume"
        Tier = "web"
      }
    )
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-web-launch-template"
    }
  )
}

# ------------------------------------------------------------------------------
# AUTO SCALING GROUP
# ------------------------------------------------------------------------------

resource "aws_autoscaling_group" "web" {
  name_prefix         = "${var.project_name}-${var.environment}-web-asg-"
  vpc_zone_identifier = var.public_subnet_ids
  
  desired_capacity = var.asg_desired_capacity
  min_size         = var.asg_min_size
  max_size         = var.asg_max_size

  health_check_type         = "EC2"  # Will add ELB after Phase 7
  health_check_grace_period = var.health_check_grace_period

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  # Ensure instances are distributed across AZs
  enabled_metrics = [
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupMaxSize",
    "GroupMinSize",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances",
  ]

  # Tags
  tag {
    key                 = "Name"
    value               = "${var.project_name}-${var.environment}-web-instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }

  tag {
    key                 = "Tier"
    value               = "web"
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = var.project_name
    propagate_at_launch = true
  }

  # Wait for instances to be healthy before considering the ASG created
  wait_for_capacity_timeout = "10m"

  lifecycle {
    create_before_destroy = true
  }
}
