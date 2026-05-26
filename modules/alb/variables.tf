variable "public_subnets" {
    type = list(string)
}

variable "private_subnets" {
  type = list(string)
}

variable "public_alb_sg" {
  
}

variable "internal_alb_sg" {
  
}

variable "vpc_id" {}

variable "component" {
  
}

variable "instance_type" {
  
}

variable "frontend_sg" {
}