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
  for_each = var.component
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
