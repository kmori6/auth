terraform {
  required_version = ">= 1.11"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.28"
    }
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id = var.allocation_id
  subnet_id     = var.subnet_id

  tags = {
    Name = var.name
  }
}
