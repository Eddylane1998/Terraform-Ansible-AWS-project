terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

locals {
  vpc_id    = "vpc-0ff2bf3f6a6b0abe6"
  subnet_id = "subnet-076ed149f5c3edf12"
  ssh_user  = "Ubuntu"
}

provider "aws" {
  region  = "eu-west-2"
}

data "aws_ami" "amazon-linux-2" {
 most_recent = true


 filter {
   name   = "owner-alias"
   values = ["amazon"]
 }


 filter {
   name   = "name"
   values = ["amzn2-ami-hvm*"]
 }
}

resource "aws_security_group" "nginx" {
  name   = "nginx_access"
  vpc_id = local.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
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

resource "aws_instance" "nginx" {
  ami = "${data.aws_ami.amazon-linux-2.id}"
  subnet_id = local.subnet_id
  instance_type = "t2.micro"
  associate_public_ip_address = true
  security_groups = [aws_security_group.nginx.id]

provisioner "remote-exec" {
  inline = ["echo 'wait until ssh is ready'"]

  connection {
    type = "ssh"
    user = local.ssh_user
    host = aws_instance.nginx.public_ip
  }
}

provisioner "local-exec" {
  command = "ansible-playbook -i ${aws_instance.nginx.public_ip}"
}

  tags = {
    Name = "Terraform_Github_Ansible"
  }
}

output "nginx_ip" {
  value = aws_instance.nginx.public_ip  
}