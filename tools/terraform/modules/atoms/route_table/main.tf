terraform {
  required_version = ">= 1.11"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.28"
    }
  }
}

resource "aws_route_table" "main" {
  vpc_id = var.vpc_id

  tags = {
    Name = var.name
  }
}
