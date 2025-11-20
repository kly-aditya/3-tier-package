# ==============================================================================
# CLOUDWATCH ALARMS - ALL COMPONENTS
# ==============================================================================
# Add this file as: modules/cloudwatch/main.tf (new module)
# OR add to an existing monitoring module

# ------------------------------------------------------------------------------
# WEB TIER ALARMS
# ------------------------------------------------------------------------------

# High CPU Alarm - Web Tier
resource "aws_cloudwatch_metric_alarm" "web_high_cpu" {
  alarm_name          = "${var.project_name}-${var.environment}-web-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300  # 5 minutes
  statistic           = "Average"
  threshold           = var.high_cpu_threshold
  alarm_description   = "Web tier CPU utilization is too high"
  alarm_actions       = var.alarm_actions  # SNS topic ARNs

  dimensions = {
    AutoScalingGroupName = var.web_asg_name
  }

  tags = merge(
    var.common_tags,
    {
      Name      = "${var.project_name}-${var.environment}-web-high-cpu"
      Component = "monitoring"
      Tier      = "web"
    }
  )
}

# ------------------------------------------------------------------------------
# APP TIER ALARMS
# ------------------------------------------------------------------------------

# High CPU Alarm - App Tier
resource "aws_cloudwatch_metric_alarm" "app_high_cpu" {
  alarm_name          = "${var.project_name}-${var.environment}-app-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = var.high_cpu_threshold
  alarm_description   = "App tier CPU utilization is too high"
  alarm_actions       = var.alarm_actions

  dimensions = {
    AutoScalingGroupName = var.app_asg_name
  }

  tags = merge(
    var.common_tags,
    {
      Name      = "${var.project_name}-${var.environment}-app-high-cpu"
      Component = "monitoring"
      Tier      = "app"
    }
  )
}

# ------------------------------------------------------------------------------
# WEB ALB ALARMS
# ------------------------------------------------------------------------------

# Unhealthy Target Count - Web ALB
resource "aws_cloudwatch_metric_alarm" "web_alb_unhealthy_targets" {
  alarm_name          = "${var.project_name}-${var.environment}-web-alb-unhealthy-targets"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 60  # 1 minute
  statistic           = "Maximum"
  threshold           = 0
  alarm_description   = "Web ALB has unhealthy targets"
  alarm_actions       = var.alarm_actions
  treat_missing_data  = "notBreaching"

  dimensions = {
    TargetGroup  = var.web_target_group_arn_suffix
    LoadBalancer = var.web_alb_arn_suffix
  }

  tags = merge(
    var.common_tags,
    {
      Name      = "${var.project_name}-${var.environment}-web-alb-unhealthy"
      Component = "monitoring"
      Tier      = "web-alb"
    }
  )
}

# Target Response Time - Web ALB
resource "aws_cloudwatch_metric_alarm" "web_alb_response_time" {
  alarm_name          = "${var.project_name}-${var.environment}-web-alb-slow-response"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Average"
  threshold           = var.response_time_threshold
  alarm_description   = "Web ALB response time is too high"
  alarm_actions       = var.alarm_actions
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = var.web_alb_arn_suffix
  }

  tags = merge(
    var.common_tags,
    {
      Name      = "${var.project_name}-${var.environment}-web-alb-slow-response"
      Component = "monitoring"
      Tier      = "web-alb"
    }
  )
}

# 5xx Errors - Web ALB
resource "aws_cloudwatch_metric_alarm" "web_alb_5xx_errors" {
  alarm_name          = "${var.project_name}-${var.environment}-web-alb-5xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Sum"
  threshold           = var.error_5xx_threshold
  alarm_description   = "Web ALB is receiving too many 5xx errors from targets"
  alarm_actions       = var.alarm_actions
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = var.web_alb_arn_suffix
  }

  tags = merge(
    var.common_tags,
    {
      Name      = "${var.project_name}-${var.environment}-web-alb-5xx-errors"
      Component = "monitoring"
      Tier      = "web-alb"
    }
  )
}

# ------------------------------------------------------------------------------
# APP ALB ALARMS
# ------------------------------------------------------------------------------

# Unhealthy Target Count - App ALB
resource "aws_cloudwatch_metric_alarm" "app_alb_unhealthy_targets" {
  alarm_name          = "${var.project_name}-${var.environment}-app-alb-unhealthy-targets"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Maximum"
  threshold           = 0
  alarm_description   = "App ALB has unhealthy targets"
  alarm_actions       = var.alarm_actions
  treat_missing_data  = "notBreaching"

  dimensions = {
    TargetGroup  = var.app_target_group_arn_suffix
    LoadBalancer = var.app_alb_arn_suffix
  }

  tags = merge(
    var.common_tags,
    {
      Name      = "${var.project_name}-${var.environment}-app-alb-unhealthy"
      Component = "monitoring"
      Tier      = "app-alb"
    }
  )
}

# Target Response Time - App ALB
resource "aws_cloudwatch_metric_alarm" "app_alb_response_time" {
  alarm_name          = "${var.project_name}-${var.environment}-app-alb-slow-response"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Average"
  threshold           = var.response_time_threshold
  alarm_description   = "App ALB response time is too high"
  alarm_actions       = var.alarm_actions
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = var.app_alb_arn_suffix
  }

  tags = merge(
    var.common_tags,
    {
      Name      = "${var.project_name}-${var.environment}-app-alb-slow-response"
      Component = "monitoring"
      Tier      = "app-alb"
    }
  )
}

# 5xx Errors - App ALB
resource "aws_cloudwatch_metric_alarm" "app_alb_5xx_errors" {
  alarm_name          = "${var.project_name}-${var.environment}-app-alb-5xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Sum"
  threshold           = var.error_5xx_threshold
  alarm_description   = "App ALB is receiving too many 5xx errors from targets"
  alarm_actions       = var.alarm_actions
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = var.app_alb_arn_suffix
  }

  tags = merge(
    var.common_tags,
    {
      Name      = "${var.project_name}-${var.environment}-app-alb-5xx-errors"
      Component = "monitoring"
      Tier      = "app-alb"
    }
  )
}

# ------------------------------------------------------------------------------
# RDS ALARMS (OPTIONAL - Bonus!)
# ------------------------------------------------------------------------------

# High CPU - RDS
resource "aws_cloudwatch_metric_alarm" "rds_high_cpu" {
  count               = var.enable_rds_alarms ? 1 : 0
  alarm_name          = "${var.project_name}-${var.environment}-rds-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "RDS CPU utilization is too high"
  alarm_actions       = var.alarm_actions

  dimensions = {
    DBInstanceIdentifier = var.rds_instance_id
  }

  tags = merge(
    var.common_tags,
    {
      Name      = "${var.project_name}-${var.environment}-rds-high-cpu"
      Component = "monitoring"
      Tier      = "database"
    }
  )
}

# Low Free Storage - RDS
resource "aws_cloudwatch_metric_alarm" "rds_low_storage" {
  count               = var.enable_rds_alarms ? 1 : 0
  alarm_name          = "${var.project_name}-${var.environment}-rds-low-storage"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 5368709120  # 5 GB in bytes
  alarm_description   = "RDS free storage space is running low"
  alarm_actions       = var.alarm_actions

  dimensions = {
    DBInstanceIdentifier = var.rds_instance_id
  }

  tags = merge(
    var.common_tags,
    {
      Name      = "${var.project_name}-${var.environment}-rds-low-storage"
      Component = "monitoring"
      Tier      = "database"
    }
  )
}
