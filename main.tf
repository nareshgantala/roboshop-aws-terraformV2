module "networking" {
  source = "./modules/networking"
  vpc_id = var.vpc_id
}

module "sg" {
  source = "./modules/securityGroups"
  vpc_id = var.vpc_id
}

module "alb" {
  source = "./modules/alb"
  public_subnets = module.networking.public_subnets
  private_subnets = module.networking.private_subnets
  public_alb_sg = module.sg.public_alb_sg
  internal_alb_sg = module.sg.internal_alb_sg
  vpc_id = var.vpc_id
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
              "sudo dnf install ansible-core -y",
              "ansible-pull -i localhost, -U https://github.com/nareshgantala/roboshop-aws-ansible.git ${each.key}.yml "
              EOF
  )
}
