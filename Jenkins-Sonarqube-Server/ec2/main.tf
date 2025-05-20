terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.54.1"
    }
  }
}
resource "aws_instance" "jenkins-sonarqube-server" {
  ami = var.ami_id
  instance_type = var.instance_type
  subnet_id = var.subnet_id
  key_name = var.key_name
  associate_public_ip_address = var.associate_ip
  user_data = var.user_data
  vpc_security_group_ids = var.security_group_ids
  lifecycle {
    ignore_changes = [user_data]
  }
  tags = {
    Name = var.name
  }
}