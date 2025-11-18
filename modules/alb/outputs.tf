# WEB ALB MODULE - OUTPUTS
# ==============================================================================

output "alb_id" {
  description = "ID of the Application Load Balancer"
  value       = aws_lb.web.id
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.web.arn
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.web.dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  value       = aws_lb.web.zone_id
}

output "target_group_id" {
  description = "ID of the target group"
  value       = aws_lb_target_group.web.id
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = aws_lb_target_group.web.arn
}

output "target_group_name" {
  description = "Name of the target group"
  value       = aws_lb_target_group.web.name
}

output "listener_http_arn" {
  description = "ARN of the HTTP listener"
  value       = aws_lb_listener.http.arn
}
