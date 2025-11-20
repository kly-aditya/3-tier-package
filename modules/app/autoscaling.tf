# ==============================================================================
# APP TIER AUTO SCALING POLICIES
# ==============================================================================

# TARGET TRACKING SCALING POLICY - CPU BASED
# ------------------------------------------------------------------------------

resource "aws_autoscaling_policy" "app_cpu_target_tracking" {
  name                   = "${var.project_name}-${var.environment}-app-cpu-target-tracking"
  autoscaling_group_name = aws_autoscaling_group.app.name
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

resource "aws_autoscaling_policy" "app_alb_request_count" {
    count = var.enable_alb_request_scaling ? 1 : 0
  name                   = "${var.project_name}-${var.environment}-app-alb-request-tracking"
  autoscaling_group_name = aws_autoscaling_group.app.name
  policy_type            = "TargetTrackingScaling"
  
  enabled = var.enable_alb_request_scaling

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label         = var.alb_target_group_arn_suffix
    }
    target_value       = var.target_requests_per_instance
   
  }
}
