variable "vpc_id" {}

variable "private_subnets" {
  type = list(string)
}

variable "security_groups" {
  type = list(string)
}

variable "component" {
  
}