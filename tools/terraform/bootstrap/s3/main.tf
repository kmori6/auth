terraform {
  required_version = ">= 1.11"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.28"
    }
  }
}

provider "aws" {
  region = var.region
}

# s3 bucket for tfstate
module "s3_tfstate" {
  source        = "../../modules/atoms/s3"
  name          = "${var.prefix}-tfstate-bucket"
  force_destroy = false
}

# s3 bucket for frontend static website hosting
module "s3_frontend" {
  source        = "../../modules/atoms/s3"
  name          = "${var.prefix}-client-bucket"
  force_destroy = true
}
