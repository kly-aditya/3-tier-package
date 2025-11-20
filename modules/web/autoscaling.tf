# ==============================================================================
# WEB TIER AUTO SCALING POLICIES

# ------------------------------------------------------------------------------
# TARGET TRACKING SCALING POLICY - CPU BASED
# ------------------------------------------------------------------------------
# Automatically adjusts capacity to maintain target CPU utilization

resource "aws_autoscaling_policy" "web_cpu_target_tracking" {
  name                   = "${var.project_name}-${var.environment}-web-cpu-target-tracking"
  autoscaling_group_name = aws_autoscaling_group.web.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = var.target_cpu_utilization
    
    
  }
}

# ------------------------------------------------------------------------------
# TARGET TRACKING SCALING POLICY - ALB REQUEST COUNT (Optional)
# ------------------------------------------------------------------------------
# Scale based on requests per target (can be disabled)

resource "aws_autoscaling_policy" "web_alb_request_count" {
    count = var.enable_alb_request_scaling ? 1 : 0
  name                   = "${var.project_name}-${var.environment}-web-alb-request-tracking"
  autoscaling_group_name = aws_autoscaling_group.web.name
  policy_type            = "TargetTrackingScaling"
  
  enabled = var.enable_alb_request_scaling  # Disabled by default

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label         = var.alb_target_group_arn_suffix
    }
    target_value       = var.target_requests_per_instance
    
  }
}

# ------------------------------------------------------------------------------
# SCHEDULED SCALING (OPTIONAL - Commented out by default)
# ------------------------------------------------------------------------------
# Uncomment if you want to pre-scale for known traffic patterns

# resource "aws_autoscaling_schedule" "web_scale_up_morning" {
#   scheduled_action_name  = "${var.project_name}-${var.environment}-web-morning-scale-up"
#   min_size               = 4
#   max_size               = 6
#   desired_capacity       = 4
#   recurrence             = "0 8 * * MON-FRI"  # 8 AM weekdays
#   autoscaling_group_name = aws_autoscaling_group.web.name
# }

# resource "aws_autoscaling_schedule" "web_scale_down_evening" {
#   scheduled_action_name  = "${var.project_name}-${var.environment}-web-evening-scale-down"
#   min_size               = 3
#   max_size               = 6
#   desired_capacity       = 3
#   recurrence             = "0 18 * * MON-FRI"  # 6 PM weekdays
#   autoscaling_group_name = aws_autoscaling_group.web.name
# }