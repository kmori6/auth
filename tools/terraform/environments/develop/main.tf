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
    key    = "environments/develop/terraform.tfstate"
    region = "ap-northeast-1"
  }
}

provider "aws" {
  region = var.region
}

# Provider for us-east-1 (required for CloudFront ACM certificate)
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

# Network Module (VPC, Subnets, IGW, NAT Gateway, Route Tables)
module "network" {
  source = "../../modules/molecules/network"

  prefix             = var.prefix
  vpc_cidr_block     = var.vpc_cidr_block
  public_subnets     = var.vpc_public_subnets
  private_subnets    = var.vpc_private_subnets
  availability_zones = var.vpc_availability_zones
}

# SSL Certificate Module
module "ssl_certificate" {
  source = "../../modules/molecules/ssl_certificate"

  prefix      = var.prefix
  domain_name = var.domain_name
}

# SSL Certificate Module for CloudFront (us-east-1)
module "ssl_certificate_cloudfront" {
  source = "../../modules/molecules/ssl_certificate"

  providers = {
    aws = aws.us_east_1
  }

  prefix      = var.prefix
  domain_name = var.domain_name
}

# Load Balancer Module (ALB, Target Group, HTTPS Listener)
module "load_balancer" {
  source = "../../modules/molecules/load_balancer"

  prefix            = var.prefix
  vpc_id            = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids
  app_port          = var.app_port
  certificate_arn   = module.ssl_certificate.certificate_arn
}

# Route 53 Module (DNS A Record to ALB)
module "route53" {
  source = "../../modules/molecules/dns"

  domain_name      = var.api_domain_name
  hosted_zone_name = var.domain_name
  alb_dns_name     = module.load_balancer.alb_dns_name
  alb_zone_id      = module.load_balancer.alb_zone_id
}

# Auth Module (ECS Fargate)
module "auth" {
  source = "../../modules/molecules/auth"

  prefix                = var.prefix
  region                = var.region
  vpc_id                = module.network.vpc_id
  private_subnet_ids    = module.network.private_subnet_ids
  app_port              = var.app_port
  alb_security_group_id = module.load_balancer.security_group_id
  target_group_arn      = module.load_balancer.target_group_arn
  ecr_repository_url    = var.ecr_repository_url
  container_image_tag   = var.container_image_tag
  ecs_task_cpu          = var.ecs_task_cpu
  ecs_task_memory       = var.ecs_task_memory
  postgres_endpoint_url = module.postgres.db_instance_address
  db_username           = var.db_username
  db_password           = var.db_password
  db_name               = var.db_name
  desired_count         = var.ecs_desired_count
}

# PostgreSQL RDS Module
module "postgres" {
  source = "../../modules/molecules/postgres"

  prefix                = var.prefix
  vpc_id                = module.network.vpc_id
  private_subnet_ids    = module.network.private_subnet_ids
  ecs_security_group_id = module.auth.ecs_security_group_id
  availability_zone     = var.vpc_availability_zones[0]
  db_username           = var.db_username
  db_password           = var.db_password
  db_instance_class     = var.db_instance_class
  db_allocated_storage  = var.db_allocated_storage
  db_engine_version     = var.db_engine_version
}

# Flyway Module (Database Migration)
module "flyway" {
  source = "../../modules/molecules/flyway"

  prefix                    = var.prefix
  region                    = var.region
  flyway_ecr_repository_url = var.flyway_ecr_repository_url
}

# S3 Bucket for Client (data source)
data "aws_s3_bucket" "client" {
  bucket = "auth-client-bucket"
}

# Client Module (CloudFront + S3)
module "client" {
  source = "../../modules/molecules/client"

  prefix                         = var.prefix
  domain_name                    = var.domain_name
  s3_bucket_id                   = data.aws_s3_bucket.client.id
  s3_bucket_arn                  = data.aws_s3_bucket.client.arn
  s3_bucket_regional_domain_name = data.aws_s3_bucket.client.bucket_regional_domain_name
  certificate_arn                = module.ssl_certificate_cloudfront.certificate_arn
}

# Bastion Module (EC2 for PostgreSQL access)
module "bastion" {
  source = "../../modules/molecules/bastion"

  prefix                  = var.prefix
  ami_id                  = var.bastion_ami_id
  vpc_id                  = module.network.vpc_id
  public_subnet_id        = module.network.public_subnet_ids[0]
  rds_security_group_id   = module.postgres.db_security_group_id
  key_name                = var.bastion_key_name
  instance_type           = var.bastion_instance_type
  allowed_ssh_cidr_blocks = var.bastion_allowed_ssh_cidr
}
