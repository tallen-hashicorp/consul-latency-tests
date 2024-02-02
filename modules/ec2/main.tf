terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

##################################################################
# Data sources to get VPC, subnet, security group and AMI details
##################################################################
data "aws_ami" "ubuntu" {
    most_recent = true

    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
    }

    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["099720109477"]
}

resource "aws_security_group" "ssh_access" {
  name        = "ssh_access_sg"
  description = "Security group allowing inbound SSH access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "consul_access" {
  name        = "vault_access_sg"
  description = "Security group allowing inbound boundary access"

  ingress {
    from_port   = 8500
    to_port     = 8500
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "internal_traffic" {
  name_prefix = "internal_traffic"
  description = "Allow all internal traffic to EC2 instance"

  # Ingress rule to allow all internal traffic
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["172.31.32.0/20"] # Replace with your internal IP range (e.g., your VPC's CIDR block)
  }

  # Egress rule to allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_eip" "this" {
  count    = var.instance_count  
  domain   = "vpc"
  instance = aws_instance.example[count.index].id
}

resource "aws_key_pair" "ssh_key" {
  key_name   = "my-ssh-key"
  public_key = file("~/.ssh/id_rsa.pub")  # Replace with your public key path
}

resource "aws_instance" "example" {
  count                       = var.instance_count
  ami                         = "${data.aws_ami.ubuntu.id}"
  instance_type               = "t2.micro"
  vpc_security_group_ids      = ["${aws_security_group.ssh_access.id}", "${aws_security_group.internal_traffic.id}", "${aws_security_group.consul_access.id}"]
  key_name                    = "my-ssh-key"
  associate_public_ip_address = true

  tags = {
    Name = "DELETE_ME"
  }
}

