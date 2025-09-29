provider "aws" {
  region = "eu-west-1"
}

# Look up the default VPC
data "aws_vpc" "default" {
  default = true
}

# Fetch your current public IP
data "http" "my_ip" {
  url = "https://ifconfig.me/ip"
}

# Fetch GitHub meta JSON
data "http" "github_meta" {
  url = "https://api.github.com/meta"
}

# Decode JSON and extract Actions runner IPs
locals {
  github_actions_ipv4 = [
    for cidr in jsondecode(data.http.github_meta.response_body).actions :
    cidr
    if can(regex("^\\d+\\.\\d+\\.\\d+\\.\\d+/", cidr))
  ]
}


resource "aws_security_group" "staging_sg" {
  name        = "staging-sg"
  description = "Allow SSH and app port"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    ingress {
    from_port   = 4280
    to_port     = 4280
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # ingress {
  #   description = "DVWA from GitHub Actions"
  #   from_port   = 4280
  #   to_port     = 4280
  #   protocol    = "tcp"
  #   cidr_blocks = local.github_actions_ipv4
  # }
    ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "staging" {
  ami                    = var.ami_id
  instance_type          = "t3.micro"
  key_name               = "sec"
  vpc_security_group_ids = [aws_security_group.staging_sg.id]
  user_data              = file("user-data.sh")

  tags = {
    Name = "staging"
  }
}

output "staging_public_ip" {
  value = aws_instance.staging.public_ip
}
