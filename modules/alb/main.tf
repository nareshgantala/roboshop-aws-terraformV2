resource "aws_lb" "public_alb" {
  name               = "roboshop-public-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.public_alb_sg]
  subnets            = var.public_subnets

  enable_deletion_protection = true

  tags = {
    Name = "roboshop-public-alb"
  }
}

resource "aws_lb_target_group" "public_tg"{
  name     = "roboshop-public-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_listener" "public_alb_listener" {
  load_balancer_arn = aws_lb.public_alb.arn
  port              = "80"
  protocol          = "HTTP"
 
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.public_tg.arn
  }
}

resource "aws_autoscaling_group" "frontend" {
  target_group_arns = [aws_lb_target_group.public_tg.arn]
  availability_zones = [data.aws_availability_zones.available]
  desired_capacity   = 1
  max_size           = 2
  min_size           = 1

  launch_template {
    id      = aws_launch_template.frontend.id
    version = "$Latest"
  }
}


resource "aws_launch_template" "frontend" {
  name = "roboshop-template"

  block_device_mappings {
    device_name = "/dev/sdf"

    ebs {
      volume_size = 20
    }
  }

  image_id = "ami-0fdfb4d987b63ae72"

  instance_type = var.instance_type

  key_name = "roboshop_pem"

  vpc_security_group_ids = [var.frontend_sg]
  

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "roboshop-${var.component}-template"
    }
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              sudo dnf install ansible-core -y
              git clone https://github.com/nareshgantala/roboshop-aws-ansible.git /tmp/roboshop-ansible
              cd /tmp/roboshop-ansible
              ansible-playbook -i localhost, ${var.component}.yml
              EOF
  )
}


