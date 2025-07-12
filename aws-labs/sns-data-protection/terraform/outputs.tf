# SNS Topic Outputs
output "sns_topic_arn" {
  description = "ARN of the SNS topic with data protection"
  value       = aws_sns_topic.data_protection_demo.arn
}

output "sns_topic_name" {
  description = "Name of the SNS topic"
  value       = aws_sns_topic.data_protection_demo.name
}

output "sns_topic_display_name" {
  description = "Display name of the SNS topic"
  value       = aws_sns_topic.data_protection_demo.display_name
}

# Data Protection Policy Outputs
output "data_protection_policy_arn" {
  description = "ARN of the data protection policy"
  value       = aws_sns_data_protection_policy.multi_pii_protection.arn
}

output "protected_pii_types" {
  description = "List of PII types being detected and audited"
  value       = var.pii_types
}

output "masked_pii_types" {
  description = "List of PII types being masked"
  value       = var.masked_pii_types
}

# CloudWatch Outputs
output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group for audit trails"
  value       = aws_cloudwatch_log_group.data_protection_audit.name
}

output "cloudwatch_log_group_arn" {
  description = "ARN of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.data_protection_audit.arn
}

# KMS Outputs (if encryption enabled)
output "kms_key_id" {
  description = "ID of the KMS key used for encryption"
  value       = var.enable_encryption ? aws_kms_key.sns_encryption[0].id : null
}

output "kms_key_arn" {
  description = "ARN of the KMS key used for encryption"
  value       = var.enable_encryption ? aws_kms_key.sns_encryption[0].arn : null
  sensitive   = true
}

output "kms_alias_name" {
  description = "Alias name of the KMS key"
  value       = var.enable_encryption ? aws_kms_alias.sns_encryption[0].name : null
}

# Monitoring Outputs
output "pii_detection_alarm_arn" {
  description = "ARN of the PII detection volume alarm"
  value       = aws_cloudwatch_metric_alarm.high_pii_detection_volume.arn
}

output "credit_card_detection_alarm_arn" {
  description = "ARN of the credit card detection alarm"
  value       = aws_cloudwatch_metric_alarm.credit_card_detection.arn
}

# Configuration Outputs
output "environment" {
  description = "Environment name"
  value       = var.environment
}

output "aws_region" {
  description = "AWS region where resources are deployed"
  value       = data.aws_region.current.name
}

output "aws_account_id" {
  description = "AWS account ID where resources are deployed"
  value       = data.aws_caller_identity.current.account_id
  sensitive   = true
}

# Subscription Output (if email provided)
output "email_subscription_arn" {
  description = "ARN of the email subscription (if created)"
  value       = var.notification_email != "" ? aws_sns_topic_subscription.email_notification[0].arn : null
}

# Testing Information
output "test_instructions" {
  description = "Instructions for testing the data protection setup"
  value = <<-EOT
    To test the data protection setup:
    
    1. Publish a test message:
       aws sns publish --topic-arn ${aws_sns_topic.data_protection_demo.arn} --subject "Test" --message '{"customer":{"name":"John Doe","email":"john@example.com","phone":"555-123-4567","cardNumber":"4539894458086459"}}'
    
    2. Check CloudWatch logs:
       aws logs describe-log-streams --log-group-name ${aws_cloudwatch_log_group.data_protection_audit.name}
    
    3. View metrics:
       aws cloudwatch get-metric-statistics --namespace "DataProtection/SNS" --metric-name "PIIDetectionCount" --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) --end-time $(date -u +%Y-%m-%dT%H:%M:%S) --period 300 --statistics Sum
  EOT
}

# Resource Summary
output "resource_summary" {
  description = "Summary of created resources"
  value = {
    sns_topic        = aws_sns_topic.data_protection_demo.name
    log_group        = aws_cloudwatch_log_group.data_protection_audit.name
    kms_encryption   = var.enable_encryption
    email_configured = var.notification_email != ""
    pii_types_count  = length(var.pii_types)
    masked_types_count = length(var.masked_pii_types)
  }
}
