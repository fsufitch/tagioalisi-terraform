terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

variable "stack_name" {
  default = "Tagioalisi-Test"
}

variable "parameter_suffix" {
  default = "TEST"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

provider "aws" {
  profile = "default"
  region  = "us-east-1"
  default_tags {
    tags = {
      StackName = var.stack_name
    }
  }
}

############# Resources

resource "aws_vpc" "main" {
  cidr_block           = "10.8.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "Tagioalisi Main VPC"
  }
}

resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.8.1.0/24"
  tags = {
    Name = "Tagioalisi Main Subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "Tagioalisi IGW"
  }
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_security_group" "bot" {
  name        = "Tagioalisi Bot SG"
  description = "Rules for managing the traffic of Tagioalisi"
  vpc_id      = aws_vpc.main.id

  ingress {
    protocol    = "icmp"
    from_port   = 8
    to_port     = -1
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow pinging"
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_instance" "bot" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.main.id

  security_groups = [
    aws_security_group.bot.id,
  ]

  tags = {
    Name = "Tagioalisi Bot Instance"
  }
}

########### SSM Parameter "outputs"

resource "aws_ssm_parameter" "bot_public_host" {
  type       = "String"
  name       = format("TAGIOALISI_BOT_PUBLIC_HOST_%s", var.parameter_suffix)
  value      = aws_instance.bot.public_dns
  depends_on = [aws_instance.bot]
}

resource "aws_ssm_parameter" "bot_private_host" {
  type       = "String"
  name       = format("TAGIOALISI_BOT_PRIVATE_HOST_%s", var.parameter_suffix)
  value      = aws_instance.bot.private_dns
  depends_on = [aws_instance.bot]
}

############ Outputs

output "bot_public_host" {
  value = aws_instance.bot.public_dns
  depends_on = [
    aws_instance.bot
  ]
}