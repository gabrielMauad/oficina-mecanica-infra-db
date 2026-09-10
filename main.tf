terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  # Backend parcial de propósito: nenhum bucket entra hardcoded aqui. Os valores concretos
  # (bucket, key, region) são passados via `-backend-config` no `terraform init` — ver o
  # comando completo no README, seção "Instruções de execução".
  backend "s3" {}
}

provider "aws" {
  region = var.aws_region
}

locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    Repository  = "oficina-mecanica-infra-db"
  }
}
