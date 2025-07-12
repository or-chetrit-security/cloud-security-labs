# CloudWatch Log Group for Data Protection Audit
resource "aws_cloudwatch_log_group" "data_protection_audit" {
  name              = "/aws/vendedlogs/sns-data-protection-audit"
  retention_in_days = var.log_retention_days
  
  # Encryption
  kms_key_id = var.enable_encryption ? aws_kms_key.sns_encryption[0].arn : null
  
  tags = merge(local.common_tags, {
    Name    = "${local.name_prefix}-audit-logs"
    Purpose = "DataProtectionAudit"
    Compliance = "PCI-DSS,GDPR,SOX"
  })
}

# CloudWatch Metric Filter for PII Detections
resource "aws_cloudwatch_log_metric_filter" "pii_detections" {
  name           = "${local.name_prefix}-pii-detections"
  log_group_name = aws_cloudwatch_log_group.data_protection_audit.name
  pattern        = "[timestamp, requestId, messageId=\"messageId\", ...]"

  metric_transformation {
    name      = "PIIDetectionCount"
    namespace = "DataProtection/SNS"
    value     = "1"
    
    default_value = 0
    
    # Add dimensions for better filtering
    dimensions = {
      Environment = var.environment
      TopicName   = aws_sns_topic.data_protection_demo.name
    }
  }
}

# CloudWatch Metric Filter for Credit Card Detections
resource "aws_cloudwatch_log_metric_filter" "credit_card_detections" {
  name           = "${local.name_prefix}-credit-card-detections"
  log_group_name = aws_cloudwatch_log_group.data_protection_audit.name
  pattern        = "[..., dataIdentifiers.name=\"CreditCardNumber\", ...]"

  metric_transformation {
    name      = "CreditCardDetectionCount"
    namespace = "DataProtection/SNS"
    value     = "1"
    
    default_value = 0
    
    dimensions = {
      Environment = var.environment
      TopicName   = aws_sns_topic.data_protection_demo.name
      PIIType     = "CreditCard"
    }
  }
}

# CloudWatch Alarm for High PII Detection Volume
resource "aws_cloudwatch_metric_alarm" "high_pii_detection_volume" {
  alarm_name          = "${local.name_prefix}-high-pii-detection-volume"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "PIIDetectionCount"
  namespace           = "DataProtection/SNS"
  period              = "300"
  statistic           = "Sum"
  threshold           = "100"
  alarm_description   = "This metric monitors high volume PII detection"
  alarm_actions       = var.notification_email != "" ? [aws_sns_topic.data_protection_demo.arn] : []

  dimensions = {
    Environment = var.environment
    TopicName   = aws_sns_topic.data_protection_demo.name
  }

  tags = merge(local.common_tags, {
    Name        = "${local.name_prefix}-high-pii-alarm"
    AlertLevel  = "Warning"
    Purpose     = "SecurityMonitoring"
  })
}

# CloudWatch Alarm for Credit Card Detection
resource "aws_cloudwatch_metric_alarm" "credit_card_detection" {
  alarm_name          = "${local.name_prefix}-credit-card-detection"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CreditCardDetectionCount"
  namespace           = "DataProtection/SNS"
  period              = "60"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "Alert when credit card numbers are detected"
  alarm_actions       = var.notification_email != "" ? [aws_sns_topic.data_protection_demo.arn] : []
  treat_missing_data  = "notBreaching"

  dimensions = {
    Environment = var.environment
    TopicName   = aws_sns_topic.data_protection_demo.name
    PIIType     = "CreditCard"
  }

  tags = merge(local.common_tags, {
    Name        = "${local.name_prefix}-cc-detection-alarm"
    AlertLevel  = "Info"
    Purpose     = "ComplianceMonitoring"
  })
}
