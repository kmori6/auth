terraform {
  required_version = ">= 1.11"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.28"
    }
  }
}

resource "aws_route_table_association" "main" {
  subnet_id      = var.subnet_id
  route_table_id = var.route_table_id
}
