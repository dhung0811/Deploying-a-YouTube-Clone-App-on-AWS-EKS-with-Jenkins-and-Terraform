
module "vpc" {
  source = "./vpc"
  name = "jenkins-sonarqube-vpc"
  description = "VPC for Jenkins and Sonarqube"
  vpc_cidr_block = "10.0.0.0/16"
  public_cidr_block = "10.0.1.0/24"
}


module "public_sg" {
  source = "./sg"
  name   = "jenkins-sonarqube-public-sg"
  vpc_id = module.vpc.vpc_id

  ingress_rules = [
    {
      from_port = 22
      to_port   = 22
      protocol  = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      security_groups = []
    },
    {
      from_port = 80
      to_port   = 80
      protocol  = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      security_groups = []
    },
    {
      from_port = 443
      to_port   = 443
      protocol  = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      security_groups = []
    },
    {
      from_port = 8080
      to_port   = 8080
      protocol  = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      security_groups = []
    },
    {
      from_port = 9000
      to_port   = 9000
      protocol  = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      security_groups = []
    },
  ]
}

data "template_file" "user_data" {
  template = file("./install.sh")
}

module "ec2" {
  source = "./ec2"
  name = "jenkins-sonarqube-server"
  ami_id = "ami-084568db4383264d4"
  instance_type = "t3.medium"
  subnet_id = module.vpc.vpc_public_subnet_id
  key_name = "ec2-key1"
  associate_ip = true
  security_group_ids = [module.public_sg.security_group_id]
  user_data = data.template_file.user_data.rendered
}