terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Uncomment for production environments with remote state
  # backend "s3" {
  #   bucket         = "your-terraform-state-bucket"
  #   key            = "sns-data-protection/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "terraform-locks"
  #   encrypt        = true
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project             = "CloudSecurityLabs"
      Component           = "SNSDataProtection"
      Environment         = var.environment
      ManagedBy          = "Terraform"
      DataClassification = "Sensitive"
      ComplianceScope    = "PCI-DSS,GDPR"
      CostCenter         = var.cost_center
      Owner              = var.owner
    }
  }
}
