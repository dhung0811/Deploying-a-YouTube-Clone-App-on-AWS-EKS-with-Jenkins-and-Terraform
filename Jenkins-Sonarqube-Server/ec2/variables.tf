variable "name" {
  type = string
}


variable "ami_id" {
  type = string
}


variable "instance_type" {
  type = string
}


variable "subnet_id" {
  type = string
}


variable "security_group_ids" {
  type = list(string)
}


variable "key_name" {
    type = string
}


variable "associate_ip" {
  type = bool
  default = true
}

variable "user_data" {
  type = string
}

