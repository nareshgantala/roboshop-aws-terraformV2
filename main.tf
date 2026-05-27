module "networking" {
  source = "./modules/networking"
  vpc_id = var.vpc_id
}

module "sg" {
  source = "./modules/securityGroups"
  vpc_id = var.vpc_id
}

module "alb" {
  for_each = var.ui
  source = "./modules/alb"
  public_subnets = module.networking.public_subnets
  private_subnets = module.networking.private_subnets
  public_alb_sg = module.sg.public_alb_sg
  internal_alb_sg = module.sg.internal_alb_sg
  vpc_id = var.vpc_id
  component = each.key
  instance_type = each.value["instance_type"]
  frontend_sg = module.sg.frontend_sg
}

module "dns_ui" {
  for_each = var.ui
  source = "./modules/dns"
  component = each.key
  record = module.alb[each.key].public_alb_dns
  alb_zone_id = module.alb[each.key].alb_zone_id
}

module "app_components" {
  for_each = var.app
  source = "./modules/app_components"
  component = each.key
  security_groups = [module.sg.security_group_ids["${each.key}_sg"]]
  private_subnets  = module.networking.private_subnets
  public_subnets = module.networking.public_subnets
  vpc_id = var.vpc_id
  instance_type = each.value["instance_type"]
  load_balancer_arn = aws_lb.internal_alb.arn
  vpc_security_group_ids = [module.sg.security_group_ids["${each.key}_sg"]]
}

# module "dns_app" {
#   for_each = var.app
#   source = "./modules/dns"
#   component = each.key
#   record = aws_lb.internal_alb.dns_name
#   alb_zone_id = aws_lb.internal_alb.zone_id
# }

module "db_ec2" {
  for_each = var.db
  source = "./modules/ec2"
  instance_type = each.value["instance_type"]
  component = each.key
  subnet_id = module.networking.private_subnets[0]
  sg = module.sg.security_group_ids["database_sg"]
}

module "dns" {
  # Merge both maps so the loop runs for all components (user, cart, mysql, shipping, etc.)
  for_each  = merge(var.app, var.db)
  source    = "./modules/dns"
  component = each.key

  # Conditional Logic: If the component exists in var.app, use ALB records. Otherwise, use EC2 Private IP.
  record = contains(keys(var.app), each.key) ? aws_lb.internal_alb.dns_name : module.db_ec2[each.key].private_ip
  
  # For DB components that don't need a Route 53 Alias/Zone ID, pass null or an empty string
  alb_zone_id = contains(keys(var.app), each.key) ? aws_lb.internal_alb.zone_id : null
}


resource "null_resource" "db" {
  for_each = var.db
  provisioner "remote-exec" {
      connection {
    type = "ssh"
    user = "ec2-user"
    private_key = file("/home/ec2-user/roboshop_pem.pem")
    host = module.db_ec2[each.key].private_ip
  }
    inline = [ 
      "sudo dnf install ansible-core -y",
      "sudo ansible-pull -i localhost, -U https://github.com/nareshgantala/roboshop-aws-ansible.git ${each.key}.yml"
     ]
  }
}

resource "aws_lb" "internal_alb" {
  name               = "roboshop-internal-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [module.sg.internal_alb_sg]
  subnets            = module.networking.private_subnets

  enable_deletion_protection = false

  tags = {
    Name = "roboshop-internal-alb"
  }
}

resource "aws_lb_listener" "Internal_listener" {
  load_balancer_arn = aws_lb.internal_alb.arn
  port              = "80"
  protocol          = "HTTP"
 
default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Empty Environment / Path Not Found"
      status_code  = "404"
    }
  }
}

resource "aws_lb_listener_rule" "app_routing" {
  for_each     = var.app
  listener_arn = aws_lb_listener.Internal_listener.arn
  priority     = 100 + index(keys(var.app), each.key) # Generates unique priorities like 101, 102...

  action {
    type             = "forward"
    target_group_arn = module.app_components[each.key].target_group_arn
  }

  condition {
    path_pattern {
      values = ["/${each.key}/*"] # Routes /cart/* to cart, /user/* to user, etc.
    }
  }
}

