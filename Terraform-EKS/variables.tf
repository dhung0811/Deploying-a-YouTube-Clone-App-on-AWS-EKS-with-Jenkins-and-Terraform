variable "private_subnets" {
  type = list(string)
    default = ["10.0.2.0/24", "10.0.3.0/24"]
}


variable "azs" {
    type = list(string)
    default = ["us-east-1a", "us-east-1b"]
}