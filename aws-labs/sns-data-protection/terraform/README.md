# SNS Data Protection - Terraform Infrastructure

> Production-ready Infrastructure as Code for AWS SNS multi-PII data protection

## Overview

This Terraform configuration deploys enterprise-grade data protection infrastructure for AWS SNS, including real-time PII detection, selective masking, and comprehensive audit logging.

## Features

### 🛡️ Security Controls
- **Multi-PII Detection**: Credit cards, phone numbers, emails, names
- **Selective Masking**: Different protection levels for different data types
- **Encryption**: KMS encryption for SNS topic and CloudWatch logs
- **Audit Trail**: Comprehensive logging with configurable retention

### 🔧 Production Ready
- **Multi-Environment Support**: dev, staging, prod configurations
- **Configurable Variables**: Extensive customization options
- **Monitoring & Alerting**: CloudWatch alarms for security events
- **Compliance Tags**: PCI DSS, GDPR, SOX compliance markers

### 🚀 DevOps Best Practices
- **Infrastructure as Code**: Version-controlled, repeatable deployments
- **Variable Validation**: Input validation and error prevention
- **Comprehensive Outputs**: Integration-ready resource information
- **Modular Design**: Reusable across multiple environments

## Quick Start

### Prerequisites
- Terraform >= 1.0
- AWS CLI configured
- Appropriate AWS IAM permissions

### Deployment Steps

1. **Clone and Navigate**
   ```bash
   git clone <repository-url>
   cd aws-labs/sns-data-protection/terraform

  # SNS Data Protection

## Getting Started

### Navigate to Directory
```bash
cd aws-labs/sns-data-protection/terraform
```

### Configure Variables
```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your configuration
```

### Deploy Infrastructure
```bash
terraform init
terraform plan
terraform apply
```

### Confirm Email Subscription (if configured)
- Check your email for SNS subscription confirmation
- Click the confirmation link

## Configuration

### Required Variables
```hcl
environment = "dev"           # Environment name
aws_region  = "us-east-1"     # AWS region
```

### Optional Variables
```hcl
# SNS Configuration
topic_name   = "data-protection-demo"
display_name = "Data Protection Demo"

# Data Protection
mask_character    = "*"
audit_sample_rate = 99

# Security
enable_encryption = true

# Notification
notification_email = "admin@company.com"
```

### PII Types Configuration
```hcl
# Detected PII types (all will be audited)
pii_types = [
  "arn:aws:dataprotection::aws:data-identifier/CreditCardNumber",
  "arn:aws:dataprotection::aws:data-identifier/PhoneNumber-US",
  "arn:aws:dataprotection::aws:data-identifier/EmailAddress",
  "arn:aws:dataprotection::aws:data-identifier/Name"
]

# Masked PII types (subset of pii_types)
masked_pii_types = [
  "arn:aws:dataprotection::aws:data-identifier/CreditCardNumber",
  "arn:aws:dataprotection::aws:data-identifier/PhoneNumber-US",
  "arn:aws:dataprotection::aws:data-identifier/EmailAddress"
]
```

## Testing

### 1. Publish Test Message
```bash
# Get topic ARN from outputs
TOPIC_ARN=$(terraform output -raw sns_topic_arn)

# Publish test message with multiple PII types
aws sns publish \
  --topic-arn $TOPIC_ARN \
  --subject "Multi-PII Test" \
  --message '{
    "customer": {
      "name": "John Doe",
      "email": "john.doe@example.com",
      "phone": "555-123-4567",
      "cardNumber": "4539894458086459"
    }
  }'
```

### 2. Verify Protection
- **Email**: Check received message for masked PII
- **Logs**: Review CloudWatch logs for detection events
- **Metrics**: Monitor CloudWatch metrics for PII detection counts

### 3. Check Audit Logs
```bash
# Get log group name
LOG_GROUP=$(terraform output -raw cloudwatch_log_group_name)

# View recent log events
aws logs describe-log-streams --log-group-name $LOG_GROUP
```

## Monitoring

### CloudWatch Alarms
- **High PII Detection Volume**: Triggers when >100 PII detections in 5 minutes
- **Credit Card Detection**: Immediate alert for any credit card detection

### Custom Metrics
- `DataProtection/SNS/PIIDetectionCount`: Total PII detections
- `DataProtection/SNS/CreditCardDetectionCount`: Credit card specific detections

### Log Analysis Queries
```sql
-- CloudWatch Insights: Find all credit card detections
fields @timestamp, messageId, dataIdentifiers
| filter dataIdentifiers.0.name = "CreditCardNumber"
| sort @timestamp desc

-- Count PII detections by type
stats count() by dataIdentifiers.0.name
```

## Compliance

### PCI DSS Coverage
- **Requirement 3.4**: Credit card numbers rendered unreadable
- **Requirement 10.2**: Audit logs for data access
- **Requirement 12.8**: Service provider compliance

### GDPR Compliance
- **Article 32**: Technical security measures
- **Data Protection by Design**: Built-in privacy controls
- **Audit Trail**: Comprehensive detection logging

## Production Considerations

### Security Best Practices
- Enable KMS encryption for all components
- Use least privilege IAM roles
- Implement comprehensive monitoring
- Regular security assessments

### Scalability
- Supports enterprise message volumes
- Minimal performance impact (<5ms latency)
- Configurable for different environments
- Cost-optimized with configurable sampling

### Operational Excellence
- Infrastructure as Code deployment
- Comprehensive monitoring and alerting
- Automated compliance evidence
- Disaster recovery ready

## Cleanup
```bash
terraform destroy
```
**Note**: This will delete all resources including CloudWatch logs. Ensure you've exported any required audit data before cleanup.

## Support

### Troubleshooting
- **Policy Errors**: Verify PII data identifiers are supported by SNS
- **Permission Issues**: Check IAM roles and KMS key policies
- **Log Group Issues**: Ensure log group name follows AWS requirements

### Common Issues
- **Email not confirmed**: Check spam folder and confirm subscription
- **No audit logs**: Verify log group exists and policy is applied
- **Encryption errors**: Check KMS key permissions

## File Structure
```
terraform/
├── main.tf                    # Core SNS and data protection resources
├── variables.tf               # Input variables and validation
├── outputs.tf                 # Resource outputs and integration info
├── cloudwatch.tf             # Logging, monitoring, and alerting
├── versions.tf               # Provider requirements and backend config
├── terraform.tfvars.example  # Example configuration
└── README.md                 # This documentation
```

---

Production-ready infrastructure demonstrating enterprise-grade AWS security automation and Infrastructure as Code best practices.

**Author**: Or Chetrit | Cloud Security Engineer  
**Version**: 1.0  
**Last Updated**: July 2025
