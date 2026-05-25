variable "vpc_id" {
  default = "vpc-003e2f478e6a9ca59"
}

variable "app" {
      default = {
        frontend = {
          instance_type = "t2.micro"
          port = 80
        }

        cart = {
          instance_type = "t2.micro"
          port = 8003
        }
        shipping = {
          instance_type = "t2.micro"
          port = 8004
        }
        payment = {
          instance_type = "t2.micro"
          port = 8005
        }
        orders = {
          instance_type = "t2.micro"
          port = 8007
        }
        ratings = {
          instance_type = "t2.micro"
          port = 8006
        }
        catalogue = {
          instance_type = "t2.micro"
          port = 8002
        }
        user = {
          instance_type = "t2.micro"
          port = 8001
        }
    }
}

variable "db" {
  default = {
        mysql = {
          instance_type = "t3.medium"
          port = 3036
        }
        mongodb = {
          instance_type = "t2.micro"
          port = 27017
        }
        valkey = {
          instance_type = "t2.micro"

        }
        rabbitmq = {
          instance_type = "t2.micro"
        }
  }
}