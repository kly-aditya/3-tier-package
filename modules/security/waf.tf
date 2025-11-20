# ==============================================================================
# AWS WAF WEB ACL - WEB APPLICATION FIREWALL
# ==============================================================================

# Protects web ALB from common web exploits and DDoS attacks

# ------------------------------------------------------------------------------
# WAF WEB ACL
# ------------------------------------------------------------------------------

resource "aws_wafv2_web_acl" "web_alb" {
  count = var.enable_waf ? 1 : 0

  name  = "${var.project_name}-${var.environment}-web-waf"
  scope = "REGIONAL"  # For ALB, use REGIONAL. For CloudFront, use CLOUDFRONT

  default_action {
    allow {}  # Allow all traffic by default, block only what matches rules
  }

  # --------------------------------------------------------------------------
  # RULE 1: AWS Managed - Core Rule Set
  # --------------------------------------------------------------------------
  # Protects against OWASP Top 10 vulnerabilities
  # - SQL injection
  # - Cross-site scripting (XSS)
  # - Local file inclusion (LFI)
  # - Remote file inclusion (RFI)

  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 1

    override_action {
      none {}  # Use rule group's actions as-is
    }

    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesCommonRuleSet"

        # Exclude specific rules if needed (e.g., for false positives)
        # excluded_rule {
        #   name = "SizeRestrictions_BODY"
        # }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.project_name}-${var.environment}-waf-common-rules"
      sampled_requests_enabled   = true
    }
  }

  # --------------------------------------------------------------------------
  # RULE 2: AWS Managed - Known Bad Inputs
  # --------------------------------------------------------------------------
  # Blocks requests with patterns known to be malicious

  rule {
    name     = "AWSManagedRulesKnownBadInputsRuleSet"
    priority = 2

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.project_name}-${var.environment}-waf-bad-inputs"
      sampled_requests_enabled   = true
    }
  }

  # --------------------------------------------------------------------------
  # RULE 3: AWS Managed - Amazon IP Reputation List
  # --------------------------------------------------------------------------
  # Blocks IPs with poor reputation (botnets, scrapers, etc.)

  rule {
    name     = "AWSManagedRulesAmazonIpReputationList"
    priority = 3

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesAmazonIpReputationList"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.project_name}-${var.environment}-waf-ip-reputation"
      sampled_requests_enabled   = true
    }
  }

  # --------------------------------------------------------------------------
  # RULE 4: Rate-Based Rule (DDoS Protection)
  # --------------------------------------------------------------------------
  # Blocks IPs making more than 2000 requests in 5 minutes
  # Adjust limit based on legitimate traffic patterns

  rule {
    name     = "RateLimitRule"
    priority = 4

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = var.waf_rate_limit
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.project_name}-${var.environment}-waf-rate-limit"
      sampled_requests_enabled   = true
    }
  }

  # --------------------------------------------------------------------------
  # RULE 5: Geo-Blocking (Optional - Commented Out)
  # --------------------------------------------------------------------------
  # Uncomment to block specific countries
  # Example: Block traffic from high-risk countries

  # rule {
  #   name     = "GeoBlockRule"
  #   priority = 5
  #
  #   action {
  #     block {}
  #   }
  #
  #   statement {
  #     geo_match_statement {
  #       country_codes = ["CN", "RU", "KP"]  # China, Russia, North Korea
  #     }
  #   }
  #
  #   visibility_config {
  #     cloudwatch_metrics_enabled = true
  #     metric_name                = "${var.project_name}-${var.environment}-waf-geo-block"
  #     sampled_requests_enabled   = true
  #   }
  # }

  # --------------------------------------------------------------------------
  # Web ACL Visibility Config
  # --------------------------------------------------------------------------

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.project_name}-${var.environment}-web-waf"
    sampled_requests_enabled   = true
  }

  tags = merge(
    var.tags,
    {
      Name      = "${var.project_name}-${var.environment}-web-waf"
      Component = "security"
      Purpose   = "web-application-firewall"
    }
  )
}

# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# WAF LOGGING (OPTIONAL)
# ------------------------------------------------------------------------------
# Sends WAF logs to CloudWatch Logs for analysis
# Note: This can be expensive for high-traffic sites

resource "aws_cloudwatch_log_group" "waf" {
  count = var.enable_waf && var.enable_waf_logging ? 1 : 0

  name              = "/aws/waf/${var.project_name}-${var.environment}"
  retention_in_days = var.waf_log_retention_days

  tags = merge(
    var.tags,
    {
      Name      = "${var.project_name}-${var.environment}-waf-logs"
      Component = "security"
    }
  )
}

resource "aws_wafv2_web_acl_logging_configuration" "web_alb" {
  count = var.enable_waf && var.enable_waf_logging ? 1 : 0

  resource_arn            = aws_wafv2_web_acl.web_alb[0].arn
  log_destination_configs = [aws_cloudwatch_log_group.waf[0].arn]

  # Redact sensitive data from logs
  redacted_fields {
    single_header {
      name = "authorization"
    }
  }

  redacted_fields {
    single_header {
      name = "cookie"
    }
  }
}
