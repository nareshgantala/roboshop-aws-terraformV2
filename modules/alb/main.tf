resource "aws_lb" "public_alb" {
  name               = "roboshop-public-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.public_alb_sg]
  subnets            = var.public_subnets

  enable_deletion_protection = true

  tags = {
    Name = roboshop-public-alb
  }
}


resource "aws_lb" "internal_alb" {
  name               = "roboshop-internal-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [var.internal_alb_sg]
  subnets            = var.private_subnets

  enable_deletion_protection = true

  tags = {
    Name = roboshop-internal-alb
  }
}
