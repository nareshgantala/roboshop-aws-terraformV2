resource "aws_lb" "public_alb" {
  name               = "roboshop-public-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = var.subnets

  enable_deletion_protection = true

  tags = {
    Name = roboshop-public-alb
  }
}