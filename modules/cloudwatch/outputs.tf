# ==============================================================================
# CLOUDWATCH ALARMS MODULE - OUTPUTS
# ==============================================================================

output "web_high_cpu_alarm_arn" {
  description = "ARN of web tier high CPU alarm"
  value       = aws_cloudwatch_metric_alarm.web_high_cpu.arn
}

output "app_high_cpu_alarm_arn" {
  description = "ARN of app tier high CPU alarm"
  value       = aws_cloudwatch_metric_alarm.app_high_cpu.arn
}

output "web_alb_unhealthy_targets_alarm_arn" {
  description = "ARN of web ALB unhealthy targets alarm"
  value       = aws_cloudwatch_metric_alarm.web_alb_unhealthy_targets.arn
}

output "app_alb_unhealthy_targets_alarm_arn" {
  description = "ARN of app ALB unhealthy targets alarm"
  value       = aws_cloudwatch_metric_alarm.app_alb_unhealthy_targets.arn
}

output "web_alb_5xx_errors_alarm_arn" {
  description = "ARN of web ALB 5xx errors alarm"
  value       = aws_cloudwatch_metric_alarm.web_alb_5xx_errors.arn
}

output "app_alb_5xx_errors_alarm_arn" {
  description = "ARN of app ALB 5xx errors alarm"
  value       = aws_cloudwatch_metric_alarm.app_alb_5xx_errors.arn
}

output "alarm_summary" {
  description = "Summary of all CloudWatch alarms"
  value = {
    web_high_cpu           = aws_cloudwatch_metric_alarm.web_high_cpu.alarm_name
    app_high_cpu           = aws_cloudwatch_metric_alarm.app_high_cpu.alarm_name
    web_alb_unhealthy      = aws_cloudwatch_metric_alarm.web_alb_unhealthy_targets.alarm_name
    app_alb_unhealthy      = aws_cloudwatch_metric_alarm.app_alb_unhealthy_targets.alarm_name
    web_alb_response_time  = aws_cloudwatch_metric_alarm.web_alb_response_time.alarm_name
    app_alb_response_time  = aws_cloudwatch_metric_alarm.app_alb_response_time.alarm_name
    web_alb_5xx_errors     = aws_cloudwatch_metric_alarm.web_alb_5xx_errors.alarm_name
    app_alb_5xx_errors     = aws_cloudwatch_metric_alarm.app_alb_5xx_errors.alarm_name
  }
}
