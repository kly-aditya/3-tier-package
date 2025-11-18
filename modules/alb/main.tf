# Creates:
# - Application Load Balancer (internet-facing)
# - Target Group with health checks
# - HTTP Listener
# ==============================================================================

# ------------------------------------------------------------------------------
# APPLICATION LOAD BALANCER
# ------------------------------------------------------------------------------

resource "aws_lb" "web" {
  name               = "${var.project_name}-${var.environment}-web-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.web_alb_sg_id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = var.enable_deletion_protection
  enable_http2              = true
  enable_cross_zone_load_balancing = true

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-web-alb"
      Tier = "web"
    }
  )
}

# ------------------------------------------------------------------------------
# TARGET GROUP
# ------------------------------------------------------------------------------

resource "aws_lb_target_group" "web" {
  name     = "${var.project_name}-${var.environment}-web-tg"
  port     = 80
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
      Name = "${var.project_name}-${var.environment}-web-tg"
      Tier = "web"
    }
  )
}

# ------------------------------------------------------------------------------
# LISTENER - HTTP
# ------------------------------------------------------------------------------

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.web.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-web-listener-http"
    }
  )
}

# ------------------------------------------------------------------------------
# AUTO SCALING GROUP ATTACHMENT
# ------------------------------------------------------------------------------

resource "aws_autoscaling_attachment" "web" {
  autoscaling_group_name = var.web_asg_name
  lb_target_group_arn    = aws_lb_target_group.web.arn
}
