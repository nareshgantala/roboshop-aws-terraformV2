resource "aws_lb" "internal_alb" {
  name               = "roboshop-internal-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = var.security_groups
  subnets            = var.private_subnets

  enable_deletion_protection = true

  tags = {
    Name = "roboshop-internal-alb"
  }
}


resource "aws_lb_target_group" "main"{
  name     = "roboshop-${var.component}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.public_alb.arn
  port              = "80"
  protocol          = "HTTP"
 
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.public_tg.arn
  }
}

resource "aws_launch_template" "app_main" {

  name = "roboshop-template"

  block_device_mappings {
    device_name = "/dev/sdf"

    ebs {
      volume_size = 20
    }
  }

  image_id = "ami-0fdfb4d987b63ae72"

  instance_type = each.value

  key_name = "roboshop_pem"

  vpc_security_group_ids = [
    each.key == "cart"      ? module.sg.cart_sg :
    each.key == "catalogue" ? module.sg.catalouge_sg : # Watch out for the typo 'catalouge' in your output!
    each.key == "user"      ? module.sg.user_sg :
    each.key == "orders"    ? module.sg.orders_sg :
    each.key == "shipping"  ? module.sg.shipping_sg :
    each.key == "payment"   ? module.sg.payment_sg :
    module.sg.internal_alb_sg # Fallback default
  ]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "roboshop-${each.key}-template"
    }
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              sudo dnf install ansible-core -y
              git clone https://github.com/nareshgantala/roboshop-aws-ansible.git /tmp/roboshop-ansible
              cd /tmp/roboshop-ansible
              ansible-playbook -i localhost, ${each.key}.yml
              EOF
  )
}





resource "aws_autoscaling_group" "app_main" {
  target_group_arns = [module.alb.public_tg_arn]
  availability_zones = [data.aws_availability_zones.available]
  desired_capacity   = 1
  max_size           = 2
  min_size           = 1

  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }
}