terraform {
  required_version = ">= 1.11"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.28"
    }
  }
}

resource "aws_route" "main" {
  route_table_id         = var.route_table_id
  destination_cidr_block = var.destination_cidr_block
  gateway_id             = var.gateway_id
  nat_gateway_id         = var.nat_gateway_id
}
