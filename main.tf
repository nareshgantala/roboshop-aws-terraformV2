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
}




