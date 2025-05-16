terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.54.1"
    }
  }
}
resource "aws_security_group" "this" {
  name = var.name
  vpc_id = var.vpc_id


  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port = ingress.value.from_port
      to_port   = ingress.value.to_port
      protocol  = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
      security_groups = ingress.value.security_groups
    }
  }


  egress = [{
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks  = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
    self       = false
    security_groups = []
    ipv6_cidr_blocks = []
    prefix_list_ids = []
  }]

  tags = {
    Name = var.name
  }
}