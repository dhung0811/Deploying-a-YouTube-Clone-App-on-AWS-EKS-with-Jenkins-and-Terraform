output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "vpc_public_subnet_id" {
  value = aws_subnet.public_subnet.id
}