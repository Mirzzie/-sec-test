provider "aws" {
  region = "us-east-1"
}

resource "aws_key_pair" "deployer" {
  key_name   = "ci_deployer_key"
  public_key = file(var.public_key_path)
}

resource "aws_security_group" "staging_sg" {
  name        = "staging-sg"
  description = "Allow SSH and app port"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 3000
    to_port     = 3000
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
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.staging_sg.id]
  user_data              = file("infra/user-data.sh")

  tags = {
    Name = "staging-juiceshop"
  }
}

output "staging_public_ip" {
  value = aws_instance.staging.public_ip
}
