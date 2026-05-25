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

resource "aws_lb_target_group" "public_tg"{
  name     = "roboshop-public-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_listener" "public_alb_listener" {
  load_balancer_arn = aws_lb.front_end.arn
  port              = "80"
  protocol          = "HTTP"
 
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.public_tg.arn
  }
}


