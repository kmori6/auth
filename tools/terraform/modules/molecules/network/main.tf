terraform {
  required_version = ">= 1.11"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.28"
    }
  }
}

# VPC
module "vpc" {
  source = "../../atoms/vpc"

  cidr_block = var.vpc_cidr_block
  name       = "${var.prefix}-vpc"
}

# Public Subnets
module "public_subnet" {
  source = "../../atoms/subnet"

  for_each = { for idx, cidr in var.public_subnets : idx => cidr }

  vpc_id            = module.vpc.id
  cidr_block        = each.value
  availability_zone = var.availability_zones[each.key]
  name              = "${var.prefix}-public-subnet-${each.key}"
}

# Private Subnets
module "private_subnet" {
  source = "../../atoms/subnet"

  for_each = { for idx, cidr in var.private_subnets : idx => cidr }

  vpc_id            = module.vpc.id
  cidr_block        = each.value
  availability_zone = var.availability_zones[each.key]
  name              = "${var.prefix}-private-subnet-${each.key}"
}

# Internet Gateway
module "internet_gateway" {
  source = "../../atoms/internet_gateway"

  vpc_id = module.vpc.id
  name   = "${var.prefix}-igw"
}

# Elastic IP for NAT Gateway
module "eip" {
  source = "../../atoms/eip"
  name   = "${var.prefix}-nat-eip"
}

# NAT Gateway (placed in first public subnet)
module "nat_gateway" {
  source = "../../atoms/nat_gateway"

  allocation_id = module.eip.id
  subnet_id     = module.public_subnet[0].id
  name          = "${var.prefix}-ngw"

  depends_on = [module.internet_gateway]
}

# Public Route Table
module "public_route_table" {
  source = "../../atoms/route_table"
  vpc_id = module.vpc.id
  name   = "${var.prefix}-public-route-table"
}

# Public Route - Route to Internet Gateway
module "public_route" {
  source                 = "../../atoms/route"
  route_table_id         = module.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = module.internet_gateway.id
}

# Public Route Table Association - Associate with all Public Subnets
module "public_route_table_association" {
  source = "../../atoms/route_table_association"

  for_each = module.public_subnet

  subnet_id      = each.value.id
  route_table_id = module.public_route_table.id
}

# Private Route Table
module "private_route_table" {
  source = "../../atoms/route_table"
  vpc_id = module.vpc.id
  name   = "${var.prefix}-private-route-table"
}

# Private Route - Route to NAT Gateway
module "private_route" {
  source                 = "../../atoms/route"
  route_table_id         = module.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = module.nat_gateway.id
}

# Private Route Table Association - Associate with all Private Subnets
module "private_route_table_association" {
  source = "../../atoms/route_table_association"

  for_each = module.private_subnet

  subnet_id      = each.value.id
  route_table_id = module.private_route_table.id
}
