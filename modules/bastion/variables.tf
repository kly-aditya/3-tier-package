variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name (production, staging, dev)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where bastion will be deployed"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for bastion deployment"
  type        = list(string)
}

variable "bastion_security_group_id" {
  description = "Security group ID for bastion host"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for bastion host"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "SSH key pair name for bastion access"
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH to bastion (your IP)"
  type        = string
}

variable "tags" {
  description = "Common tags to apply to bastion resources"
  type        = map(string)
  default     = {}
}

variable "s3_bucket_name" {
  description = "S3 bucket containing SSH keys"
  type        = string
}

variable "s3_key_prefix" {
  description = "S3 prefix for SSH keys"
  type        = string
  default     = "ssh-keys"
}

variable "region" {
  description = "AWS region"
  type        = string
}