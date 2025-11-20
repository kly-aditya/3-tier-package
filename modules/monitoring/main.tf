# ==============================================================================
# CLOUDWATCH DASHBOARD - UNIFIED INFRASTRUCTURE VIEW
# ==============================================================================
# Path: modules/monitoring/main.tf

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project_name}-${var.environment}-infrastructure"

  dashboard_body = jsonencode({
    widgets = [
      # ========================================================================
      # HEADER
      # ========================================================================
      {
        type   = "text"
        x      = 0
        y      = 0
        width  = 24
        height = 1
        properties = {
          markdown = "# ${var.project_name} - ${var.environment} Infrastructure Dashboard"
        }
      },

      # ========================================================================
      # WEB TIER - CPU
      # ========================================================================
      {
        type   = "metric"
        x      = 0
        y      = 1
        width  = 12
        height = 6
        properties = {
          title  = "Web Tier - CPU Utilization"
          region = var.aws_region
          stat   = "Average"
          period = 300
          yAxis = {
            left = {
              min = 0
              max = 100
            }
          }
          metrics = [
            ["AWS/EC2", "CPUUtilization", "AutoScalingGroupName", var.web_asg_name]
          ]
        }
      },

      # ========================================================================
      # APP TIER - CPU
      # ========================================================================
      {
        type   = "metric"
        x      = 12
        y      = 1
        width  = 12
        height = 6
        properties = {
          title  = "App Tier - CPU Utilization"
          region = var.aws_region
          stat   = "Average"
          period = 300
          yAxis = {
            left = {
              min = 0
              max = 100
            }
          }
          metrics = [
            ["AWS/EC2", "CPUUtilization", "AutoScalingGroupName", var.app_asg_name]
          ]
        }
      },

      # ========================================================================
      # WEB ALB - REQUESTS
      # ========================================================================
      {
        type   = "metric"
        x      = 0
        y      = 7
        width  = 12
        height = 6
        properties = {
          title  = "Web ALB - Request Count"
          region = var.aws_region
          stat   = "Sum"
          period = 300
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", var.web_alb_arn_suffix]
          ]
        }
      },

      # ========================================================================
      # WEB ALB - RESPONSE TIME
      # ========================================================================
      {
        type   = "metric"
        x      = 12
        y      = 7
        width  = 12
        height = 6
        properties = {
          title  = "Web ALB - Response Time"
          region = var.aws_region
          stat   = "Average"
          period = 300
          metrics = [
            ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", var.web_alb_arn_suffix]
          ]
        }
      },

      # ========================================================================
      # WEB ALB - TARGET HEALTH
      # ========================================================================
      {
        type   = "metric"
        x      = 0
        y      = 13
        width  = 12
        height = 6
        properties = {
          title  = "Web ALB - Target Health"
          region = var.aws_region
          stat   = "Average"
          period = 60
          metrics = [
            ["AWS/ApplicationELB", "HealthyHostCount", "TargetGroup", var.web_target_group_arn_suffix, "LoadBalancer", var.web_alb_arn_suffix],
            ["AWS/ApplicationELB", "UnHealthyHostCount", "TargetGroup", var.web_target_group_arn_suffix, "LoadBalancer", var.web_alb_arn_suffix]
          ]
        }
      },

      # ========================================================================
      # WEB ALB - ERRORS
      # ========================================================================
      {
        type   = "metric"
        x      = 12
        y      = 13
        width  = 12
        height = 6
        properties = {
          title  = "Web ALB - HTTP Errors"
          region = var.aws_region
          stat   = "Sum"
          period = 300
          metrics = [
            ["AWS/ApplicationELB", "HTTPCode_Target_4XX_Count", "LoadBalancer", var.web_alb_arn_suffix],
            ["AWS/ApplicationELB", "HTTPCode_Target_5XX_Count", "LoadBalancer", var.web_alb_arn_suffix]
          ]
        }
      },

      # ========================================================================
      # APP ALB - REQUESTS
      # ========================================================================
      {
        type   = "metric"
        x      = 0
        y      = 19
        width  = 12
        height = 6
        properties = {
          title  = "App ALB - Request Count"
          region = var.aws_region
          stat   = "Sum"
          period = 300
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", var.app_alb_arn_suffix]
          ]
        }
      },

      # ========================================================================
      # APP ALB - RESPONSE TIME
      # ========================================================================
      {
        type   = "metric"
        x      = 12
        y      = 19
        width  = 12
        height = 6
        properties = {
          title  = "App ALB - Response Time"
          region = var.aws_region
          stat   = "Average"
          period = 300
          metrics = [
            ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", var.app_alb_arn_suffix]
          ]
        }
      },

      # ========================================================================
      # APP ALB - TARGET HEALTH
      # ========================================================================
      {
        type   = "metric"
        x      = 0
        y      = 25
        width  = 12
        height = 6
        properties = {
          title  = "App ALB - Target Health"
          region = var.aws_region
          stat   = "Average"
          period = 60
          metrics = [
            ["AWS/ApplicationELB", "HealthyHostCount", "TargetGroup", var.app_target_group_arn_suffix, "LoadBalancer", var.app_alb_arn_suffix],
            ["AWS/ApplicationELB", "UnHealthyHostCount", "TargetGroup", var.app_target_group_arn_suffix, "LoadBalancer", var.app_alb_arn_suffix]
          ]
        }
      },

      # ========================================================================
      # RDS - CPU
      # ========================================================================
      {
        type   = "metric"
        x      = 12
        y      = 25
        width  = 12
        height = 6
        properties = {
          title  = "RDS - CPU Utilization"
          region = var.aws_region
          stat   = "Average"
          period = 300
          yAxis = {
            left = {
              min = 0
              max = 100
            }
          }
          metrics = [
            ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", var.rds_instance_id]
          ]
        }
      },

      # ========================================================================
      # RDS - CONNECTIONS
      # ========================================================================
      {
        type   = "metric"
        x      = 0
        y      = 31
        width  = 12
        height = 6
        properties = {
          title  = "RDS - Database Connections"
          region = var.aws_region
          stat   = "Average"
          period = 300
          metrics = [
            ["AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", var.rds_instance_id]
          ]
        }
      },

      # ========================================================================
      # RDS - FREE STORAGE
      # ========================================================================
      {
        type   = "metric"
        x      = 12
        y      = 31
        width  = 12
        height = 6
        properties = {
          title  = "RDS - Free Storage Space"
          region = var.aws_region
          stat   = "Average"
          period = 300
          metrics = [
            ["AWS/RDS", "FreeStorageSpace", "DBInstanceIdentifier", var.rds_instance_id]
          ]
        }
      },

      # ========================================================================
      # AUTO SCALING - WEB TIER
      # ========================================================================
      {
        type   = "metric"
        x      = 0
        y      = 37
        width  = 12
        height = 6
        properties = {
          title  = "Auto Scaling - Web Tier"
          region = var.aws_region
          stat   = "Average"
          period = 300
          metrics = [
            ["AWS/AutoScaling", "GroupDesiredCapacity", "AutoScalingGroupName", var.web_asg_name],
            ["AWS/AutoScaling", "GroupInServiceInstances", "AutoScalingGroupName", var.web_asg_name]
          ]
        }
      },

      # ========================================================================
      # AUTO SCALING - APP TIER
      # ========================================================================
      {
        type   = "metric"
        x      = 12
        y      = 37
        width  = 12
        height = 6
        properties = {
          title  = "Auto Scaling - App Tier"
          region = var.aws_region
          stat   = "Average"
          period = 300
          metrics = [
            ["AWS/AutoScaling", "GroupDesiredCapacity", "AutoScalingGroupName", var.app_asg_name],
            ["AWS/AutoScaling", "GroupInServiceInstances", "AutoScalingGroupName", var.app_asg_name]
          ]
        }
      }
    ]
  })
}
