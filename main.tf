terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

### "Global" variables/data for configuring this TF run

variable "aws_account" {
  default = 370059773792
}

variable "aws_region" {
  default = "us-east-1"
}

variable "stack_name" {
  default = "Tagioalisi-Test"
}

variable "stack_suffix" {
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

data "aws_codestarconnections_connection" "fsufitch_github" {
  arn = "arn:aws:codestar-connections:us-east-1:370059773792:connection/25796eae-e1e3-4371-a91b-c419ad0bb32c"
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

### Outputs

output "bot_public_host" {
  value = aws_instance.bot.public_dns
  depends_on = [
    aws_instance.bot
  ]
}

output "web_s3_website" {
  value = format("http://%s", aws_s3_bucket.web.website_endpoint)
  depends_on = [
    aws_s3_bucket.web
  ]
}

output "db" {
  value = format("postgres://%s@%s:%s/%s", aws_db_instance.main.username, aws_db_instance.main.address, aws_db_instance.main.port, aws_db_instance.main.name)
}