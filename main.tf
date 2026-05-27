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

module "dns_app" {
  for_each = var.app
  source = "./modules/dns"
  component = each.key
  record = aws_lb.internal_alb.dns_name
  alb_zone_id = aws_lb.internal_alb.zone_id
}

resource "aws_lb" "internal_alb" {
  name               = "roboshop-internal-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [module.sg.internal_alb_sg]
  subnets            = module.networking.private_subnets

  enable_deletion_protection = true

  tags = {
    Name = "roboshop-internal-alb"
  }
}

resource "aws_lb_listener" "Internal_listener" {
  load_balancer_arn = aws_lb.internal_alb.arn
  port              = "80"
  protocol          = "HTTP"
 
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}


