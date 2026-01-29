terraform {
  required_version = ">= 1.11"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.28"
    }
  }
}

resource "aws_s3_bucket" "s3_bucket" {
  bucket        = var.name
  force_destroy = var.force_destroy

  tags = {
    Name = var.name
  }
}
