# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Local values for consistent naming
locals {
  name_prefix = "${var.environment}-${var.topic_name}"
  
  common_tags = {
    Name        = local.name_prefix
    Environment = var.environment
    CreatedBy   = "Terraform"
  }
}

# KMS Key for encryption (if enabled)
resource "aws_kms_key" "sns_encryption" {
  count = var.enable_encryption ? 1 : 0
  
  description             = "KMS key for SNS topic and CloudWatch logs encryption"
  deletion_window_in_days = var.kms_key_deletion_window
  enable_key_rotation     = true
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EnableIAMUserPermissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "AllowSNSAccess"
        Effect = "Allow"
        Principal = {
          Service = "sns.amazonaws.com"
        }
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = "*"
      },
      {
        Sid    = "AllowCloudWatchLogsAccess"
        Effect = "Allow"
        Principal = {
          Service = "logs.${data.aws_region.current.name}.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-encryption-key"
  })
}

resource "aws_kms_alias" "sns_encryption" {
  count = var.enable_encryption ? 1 : 0
  
  name          = "alias/${local.name_prefix}-encryption"
  target_key_id = aws_kms_key.sns_encryption[0].key_id
}

# SNS Topic
resource "aws_sns_topic" "data_protection_demo" {
  name         = local.name_prefix
  display_name = var.display_name
  
  # Encryption configuration
  kms_master_key_id = var.enable_encryption ? aws_kms_key.sns_encryption[0].arn : null
  
  # Delivery policy for better reliability
  delivery_policy = jsonencode({
    http = {
      defaultHealthyRetryPolicy = {
        minDelayTarget     = 20
        maxDelayTarget     = 20
        numRetries         = 3
        numMaxDelayRetries = 0
        numMinDelayRetries = 0
        numNoDelayRetries  = 0
        backoffFunction    = "linear"
      }
      disableSubscriptionOverrides = false
    }
  })

  tags = merge(local.common_tags, {
    Name                = "${local.name_prefix}-topic"
    DataProtectionScope = "Multi-PII"
    ComplianceLevel     = "High"
  })
}

# Email subscription (if email provided)
resource "aws_sns_topic_subscription" "email_notification" {
  count = var.notification_email != "" ? 1 : 0
  
  topic_arn = aws_sns_topic.data_protection_demo.arn
  protocol  = "email"
  endpoint  = var.notification_email
}

# Data Protection Policy
resource "aws_sns_data_protection_policy" "multi_pii_protection" {
  arn = aws_sns_topic.data_protection_demo.arn
  
  policy = jsonencode({
    Description = "Multi-PII protection for ${var.environment} environment"
    Version     = "2021-06-01"
    Statement = [
      {
        Sid           = "comprehensive-pii-audit"
        DataDirection = "Inbound"
        DataIdentifier = var.pii_types
        Operation = {
          Audit = {
            FindingsDestination = {
              CloudWatchLogs = {
                LogGroup = aws_cloudwatch_log_group.data_protection_audit.name
              }
            }
            SampleRate = tostring(var.audit_sample_rate)
          }
        }
        Principal = ["*"]
      },
      {
        Sid           = "mask-sensitive-pii"
        DataDirection = "Outbound"
        DataIdentifier = var.masked_pii_types
        Operation = {
          Deidentify = {
            MaskConfig = {
              MaskWithCharacter = var.mask_character
            }
          }
        }
        Principal = ["*"]
      }
    ]
    Name = "${local.name_prefix}-protection-policy"
  })

  depends_on = [aws_cloudwatch_log_group.data_protection_audit]
}
