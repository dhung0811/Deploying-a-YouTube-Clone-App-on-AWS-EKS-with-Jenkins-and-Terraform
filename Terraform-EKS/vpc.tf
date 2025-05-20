data "aws_vpc" "selected"{
  cidr_block = "10.0.0.0/16"

}

data "aws_security_group" "sg-default" {
  vpc_id = data.aws_vpc.selected.id
  id = "sg-04bd6ff0cb7332a6f"
}

resource "aws_subnet" "private_subnet" {
    count = length(var.private_subnets)
    vpc_id = data.aws_vpc.selected.id
    cidr_block = element(var.private_subnets, count.index)
    availability_zone = element(var.azs, count.index)
}

