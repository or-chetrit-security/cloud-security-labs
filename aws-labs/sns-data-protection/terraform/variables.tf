# Environment Configuration
variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

# SNS Configuration
variable "topic_name" {
  description = "Name of the SNS topic"
  type        = string
  default     = "data-protection-demo"
}

variable "display_name" {
  description = "Display name for SNS topic"
  type        = string
  default     = "Data Protection Demo"
}

# Data Protection Configuration
variable "pii_types" {
  description = "List of PII types to protect"
  type        = list(string)
  default = [
    "arn:aws:dataprotection::aws:data-identifier/CreditCardNumber",
    "arn:aws:dataprotection::aws:data-identifier/PhoneNumber-US",
    "arn:aws:dataprotection::aws:data-identifier/EmailAddress",
    "arn:aws:dataprotection::aws:data-identifier/Name"
  ]
}

variable "masked_pii_types" {
  description = "PII types that should be masked (subset of pii_types)"
  type        = list(string)
  default = [
    "arn:aws:dataprotection::aws:data-identifier/CreditCardNumber",
    "arn:aws:dataprotection::aws:data-identifier/PhoneNumber-US",
    "arn:aws:dataprotection::aws:data-identifier/EmailAddress"
  ]
}

variable "mask_character" {
  description = "Character to use for masking PII"
  type        = string
  default     = "*"
  
  validation {
    condition     = length(var.mask_character) == 1
    error_message = "Mask character must be a single character."
  }
}

variable "audit_sample_rate" {
  description = "Sample rate for audit logging (1-100)"
  type        = number
  default     = 99
  
  validation {
    condition     = var.audit_sample_rate >= 1 && var.audit_sample_rate <= 100
    error_message = "Audit sample rate must be between 1 and 100."
  }
}

# CloudWatch Configuration
variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 90
  
  validation {
    condition = contains([
      1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653
    ], var.log_retention_days)
    error_message = "Log retention days must be a valid CloudWatch retention period."
  }
}

# Notification Configuration
variable "notification_email" {
  description = "Email address for SNS notifications (optional)"
  type        = string
  default     = ""
}

# Tagging
variable "cost_center" {
  description = "Cost center for resource billing"
  type        = string
  default     = "Security"
}

variable "owner" {
  description = "Owner of the resources"
  type        = string
  default     = "CloudSecurityTeam"
}

# Security Configuration
variable "enable_encryption" {
  description = "Enable encryption for SNS topic and CloudWatch logs"
  type        = bool
  default     = true
}

variable "kms_key_deletion_window" {
  description = "KMS key deletion window in days"
  type        = number
  default     = 7
  
  validation {
    condition     = var.kms_key_deletion_window >= 7 && var.kms_key_deletion_window <= 30
    error_message = "KMS key deletion window must be between 7 and 30 days."
  }
}
