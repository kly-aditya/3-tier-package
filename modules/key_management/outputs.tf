# ============================================================================
# KEY MANAGEMENT MODULE - OUTPUTS
# ============================================================================

output "bastion_key_pair_name" {
  description = "Name of the bastion SSH key pair"
  value       = aws_key_pair.bastion.key_name
}

output "web_key_pair_name" {
  description = "Name of the web tier SSH key pair"
  value       = aws_key_pair.web.key_name
}

output "app_key_pair_name" {
  description = "Name of the app tier SSH key pair"
  value       = aws_key_pair.app.key_name
}

output "bastion_private_key_pem" {
  description = "Bastion private key in PEM format (SENSITIVE)"
  value       = tls_private_key.bastion.private_key_pem
  sensitive   = true
}

output "web_private_key_pem" {
  description = "Web tier private key in PEM format (SENSITIVE)"
  value       = tls_private_key.web.private_key_pem
  sensitive   = true
}

output "app_private_key_pem" {
  description = "App tier private key in PEM format (SENSITIVE)"
  value       = tls_private_key.app.private_key_pem
  sensitive   = true
}

output "keys_s3_location" {
  description = "S3 location for all SSH keys"
  value = {
    bastion = "s3://${var.s3_bucket_name}/${var.s3_key_prefix}/bastion/${var.project_name}-${var.environment}-bastion-key.pem"
    web     = "s3://${var.s3_bucket_name}/${var.s3_key_prefix}/web/${var.project_name}-${var.environment}-web-key.pem"
    app     = "s3://${var.s3_bucket_name}/${var.s3_key_prefix}/app/${var.project_name}-${var.environment}-app-key.pem"
  }
}

output "local_keys_directory" {
  description = "Local directory containing private keys"
  value       = "${path.root}/keys/"
}
