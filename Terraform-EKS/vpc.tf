data "aws_vpc" "selected"{
  cidr_block = "10.0.0.0/16"

}

data "aws_security_group" "sg-default" {
  vpc_id = data.aws_vpc.selected.id
  id = "sg-04bd6ff0cb7332a6f"
}

data "aws_subnet" "public_subnet" {
  cidr_block = "10.0.1.0/24"
}

resource "aws_subnet" "private_subnet" {
    count = length(var.private_subnets)
    vpc_id = data.aws_vpc.selected.id
    cidr_block = element(var.private_subnets, count.index)
    availability_zone = element(var.azs, count.index)
}


data "aws_internet_gateway" "ig"{
  filter {
    name = "attachment.vpc-id"
    values = [data.aws_vpc.selected.id]
  }
}


resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = data.aws_subnet.public_subnet.id
  depends_on    = [data.aws_internet_gateway.ig]
}

resource "aws_route_table" "private" {
  vpc_id = data.aws_vpc.selected.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }

  tags = {
    Name = "private"
  }
}

resource "aws_route_table_association" "private" {
  for_each       = toset(aws_subnet.private_subnet[*].id)
  subnet_id      = each.value
  route_table_id = aws_route_table.private.id
}


