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
}