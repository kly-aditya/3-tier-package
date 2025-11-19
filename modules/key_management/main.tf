# ============================================================================
# KEY MANAGEMENT MODULE - Production-Grade SSH Keys
# ============================================================================
# Creates separate SSH key pairs for each tier (bastion, web, app)
# Stores private keys securely in S3
# Manages key lifecycle and access control
# ============================================================================

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

# ============================================================================
# 1. BASTION KEY PAIR
# ============================================================================

resource "tls_private_key" "bastion" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "bastion" {
  key_name   = "${var.project_name}-${var.environment}-bastion-key"
  public_key = tls_private_key.bastion.public_key_openssh

  tags = {
    Name        = "${var.project_name}-${var.environment}-bastion-key"
    Environment = var.environment
    Tier        = "bastion"
    ManagedBy   = "terraform"
  }
}

# Store bastion private key in S3
resource "aws_s3_object" "bastion_private_key" {
  bucket  = var.s3_bucket_name
  key     = "${var.s3_key_prefix}/bastion/${var.project_name}-${var.environment}-bastion-key.pem"
  content = tls_private_key.bastion.private_key_pem

  # Security settings
  server_side_encryption = "AES256"
  acl                    = "private"

  tags = {
    Name        = "Bastion SSH Private Key"
    Environment = var.environment
    Tier        = "bastion"
    ManagedBy   = "terraform"
    Sensitive   = "true"
  }
}

# ============================================================================
# 2. WEB TIER KEY PAIR
# ============================================================================

resource "tls_private_key" "web" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "web" {
  key_name   = "${var.project_name}-${var.environment}-web-key"
  public_key = tls_private_key.web.public_key_openssh

  tags = {
    Name        = "${var.project_name}-${var.environment}-web-key"
    Environment = var.environment
    Tier        = "web"
    ManagedBy   = "terraform"
  }
}

# Store web private key in S3
resource "aws_s3_object" "web_private_key" {
  bucket  = var.s3_bucket_name
  key     = "${var.s3_key_prefix}/web/${var.project_name}-${var.environment}-web-key.pem"
  content = tls_private_key.web.private_key_pem

  # Security settings
  server_side_encryption = "AES256"
  acl                    = "private"

  tags = {
    Name        = "Web Tier SSH Private Key"
    Environment = var.environment
    Tier        = "web"
    ManagedBy   = "terraform"
    Sensitive   = "true"
  }
}

# ============================================================================
# 3. APP TIER KEY PAIR
# ============================================================================

resource "tls_private_key" "app" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "app" {
  key_name   = "${var.project_name}-${var.environment}-app-key"
  public_key = tls_private_key.app.public_key_openssh

  tags = {
    Name        = "${var.project_name}-${var.environment}-app-key"
    Environment = var.environment
    Tier        = "app"
    ManagedBy   = "terraform"
  }
}

# Store app private key in S3
resource "aws_s3_object" "app_private_key" {
  bucket  = var.s3_bucket_name
  key     = "${var.s3_key_prefix}/app/${var.project_name}-${var.environment}-app-key.pem"
  content = tls_private_key.app.private_key_pem

  # Security settings
  server_side_encryption = "AES256"
  acl                    = "private"

  tags = {
    Name        = "App Tier SSH Private Key"
    Environment = var.environment
    Tier        = "app"
    ManagedBy   = "terraform"
    Sensitive   = "true"
  }
}

# ============================================================================
# 4. S3 BUCKET POLICY - Restrict Access to Keys
# ============================================================================

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket_policy" "key_access" {
  bucket = var.s3_bucket_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyInsecureTransport"
        Effect = "Deny"
        Principal = "*"
        Action = "s3:*"
        Resource = [
          "arn:aws:s3:::${var.s3_bucket_name}/${var.s3_key_prefix}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      },
      {
        Sid    = "AllowBastionInstanceAccess"
        Effect = "Allow"
        Principal = {
          AWS = var.bastion_iam_role_arn
        }
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.s3_bucket_name}/${var.s3_key_prefix}/web/*",
          "arn:aws:s3:::${var.s3_bucket_name}/${var.s3_key_prefix}/app/*"
        ]
      },
      {
        Sid    = "AllowTerraformUserAccess"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          "arn:aws:s3:::${var.s3_bucket_name}/${var.s3_key_prefix}/*"
        ]
      }
    ]
  })
}


# ============================================================================
# 5. LOCAL FILES - Save Keys for Local Access
# ============================================================================

# Save bastion key locally for your laptop
resource "local_file" "bastion_private_key" {
  content         = tls_private_key.bastion.private_key_pem
  filename        = "${path.root}/keys/${var.project_name}-${var.environment}-bastion-key.pem"
  file_permission = "0600"
}

# Save web key locally (backup)
resource "local_file" "web_private_key" {
  content         = tls_private_key.web.private_key_pem
  filename        = "${path.root}/keys/${var.project_name}-${var.environment}-web-key.pem"
  file_permission = "0600"
}

# Save app key locally (backup)
resource "local_file" "app_private_key" {
  content         = tls_private_key.app.private_key_pem
  filename        = "${path.root}/keys/${var.project_name}-${var.environment}-app-key.pem"
  file_permission = "0600"
}

