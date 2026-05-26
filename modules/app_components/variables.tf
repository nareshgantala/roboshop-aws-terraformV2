variable "vpc_id" {}

variable "private_subnets" {
  type = list(string)
}

variable "security_groups" {
  type = list(string)
}

variable "component" {
  
}

variable "load_balancer_arn" {
  
}

variable "vpc_security_group_ids" {
  type = list(string)
}
variable "public_subnets" {
  
}