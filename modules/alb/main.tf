# ==============================================================================
# FLEXIBLE ALB MODULE - Can be used for Web ALB or App ALB
# ==============================================================================
# Creates:
# - Application Load Balancer (internet-facing OR internal)
# - Target Group with health checks
# - HTTP Listener
# - Auto Scaling Group Attachment
# ==============================================================================

# APPLICATION LOAD BALANCER
# ------------------------------------------------------------------------------

resource "aws_lb" "this" {
  name               = "${var.project_name}-${var.environment}-${var.tier_name}-alb"
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.subnet_ids

  enable_deletion_protection       = var.enable_deletion_protection
  enable_http2                     = true
  enable_cross_zone_load_balancing = true

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-${var.tier_name}-alb"
      Tier = var.tier_name
    }
  )
}

# ------------------------------------------------------------------------------
# TARGET GROUP
# ------------------------------------------------------------------------------

resource "aws_lb_target_group" "this" {
  name     = "${var.project_name}-${var.environment}-${var.tier_name}-tg"
  port     = var.target_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = var.health_check_healthy_threshold
    unhealthy_threshold = var.health_check_unhealthy_threshold
    timeout             = var.health_check_timeout
    interval            = var.health_check_interval
    path                = var.health_check_path
    matcher             = "200"
    protocol            = "HTTP"
  }

  deregistration_delay = var.deregistration_delay

  stickiness {
    enabled         = var.enable_stickiness
    type            = "lb_cookie"
    cookie_duration = var.stickiness_duration
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-${var.tier_name}-tg"
      Tier = var.tier_name
    }
  )
}

# ------------------------------------------------------------------------------
# LISTENER - HTTP
# ------------------------------------------------------------------------------

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = var.listener_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-${var.tier_name}-listener-http"
    }
  )
}

# ------------------------------------------------------------------------------
# AUTO SCALING GROUP ATTACHMENT
# ------------------------------------------------------------------------------

resource "aws_autoscaling_attachment" "this" {
  autoscaling_group_name = var.asg_name
  lb_target_group_arn    = aws_lb_target_group.this.arn
}
