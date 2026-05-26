resource "aws_lb_target_group" "main"{
  name     = "roboshop-${var.component}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_listener" "main" {
  load_balancer_arn = var.load_balancer_arn
  port              = "80"
  protocol          = "HTTP"
 
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

resource "aws_launch_template" "app_main" {

  name = "roboshop-${var.component}-template"

  block_device_mappings {
    device_name = "/dev/sdf"

    ebs {
      volume_size = 20
    }
  }

  image_id = "ami-0fdfb4d987b63ae72"

  instance_type = var.instance_type

  key_name = "roboshop_pem"

  vpc_security_group_ids = var.vpc_security_group_ids

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

resource "aws_autoscaling_group" "app_main" {
  target_group_arns = [aws_lb_target_group.main.arn]
  vpc_zone_identifier = var.public_subnets
  desired_capacity   = 1
  max_size           = 2
  min_size           = 1

  launch_template {
    id      = aws_launch_template.app_main.id
    version = "$Latest"
  }
}