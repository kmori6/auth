terraform {
  required_version = ">= 1.11"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.28"
    }
  }

  backend "s3" {
    bucket = "auth-tfstate-bucket"
    key    = "bootstrap/ecr/terraform.tfstate"
    region = "ap-northeast-1"
  }
}

provider "aws" {
  region = var.region
}

# ECR for container images
module "ecr_repository" {
  source = "../../modules/atoms/ecr"
  name   = "${var.prefix}-ecr"
}

# ECR for flyway
module "ecr_flyway_repository" {
  source = "../../modules/atoms/ecr"
  name   = "${var.prefix}-flyway-ecr"
}
