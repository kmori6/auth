terraform {
  required_version = ">= 1.11"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.28"
    }
  }
}

# Bastion Security Group
resource "aws_security_group" "bastion" {
  name        = "${var.prefix}-bastion-sg"
  description = "Security group for bastion host"
  vpc_id      = var.vpc_id

  # Allow SSH from specific IP (or anywhere for development)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidr_blocks
    description = "Allow SSH access"
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "${var.prefix}-bastion-sg"
  }
}

# Update RDS Security Group to allow access from Bastion
resource "aws_security_group_rule" "rds_from_bastion" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastion.id
  security_group_id        = var.rds_security_group_id
  description              = "Allow PostgreSQL access from Bastion"
}

# IAM Role for Bastion (SSM Session Manager)
resource "aws_iam_role" "bastion" {
  name = "${var.prefix}-bastion-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "${var.prefix}-bastion-role"
  }
}

# Attach AWS managed policy for SSM
resource "aws_iam_role_policy_attachment" "bastion_ssm" {
  role       = aws_iam_role.bastion.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "bastion" {
  name = "${var.prefix}-bastion-profile"
  role = aws_iam_role.bastion.name
}

# Bastion EC2 Instance
resource "aws_instance" "bastion" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.public_subnet_id
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.bastion.name
  key_name                    = var.key_name

  user_data = <<-EOF
              #!/bin/bash
              # Update system
              apt-get update -y
              
              # Install PostgreSQL client
              apt-get install -y postgresql-client
              
              # Install useful tools
              apt-get install -y vim wget curl
              EOF

  tags = {
    Name = "${var.prefix}-bastion"
  }
}
