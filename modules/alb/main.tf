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


resource "aws_launch_template" "example" {
  name = "roboshop-template"

  block_device_mappings {
    device_name = "/dev/sdf"

    ebs {
      volume_size = 20
    }
  }

  image_id = "ami-0fdfb4d987b63ae72"

  instance_type = "t3.medium"


  key_name = "roboshop_pem"

  vpc_security_group_ids = ["sg-12345678"]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "test"
    }
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              # Install Ansible
              sudo apt-get update -y
              sudo apt-get install ansible git -y

              # Move to a directory, clone your playbook repo
              cd /tmp
              git clone https://github.com/your-username/roboshop-ansible.git
              cd roboshop-ansible

              # Run the playbook locally
              ansible-playbook -i "localhost," -c local roboshop-frontend.yml
              EOF
  )
}
