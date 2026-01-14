module "networking" {
  source = "./modules/vpc"
}

module "security" {
  source = "./modules/security_groups"
  vpc_id = module.networking.vpc_id

  allowed_ssh_cidr = var.allowed_ssh_cidr
}

module "compute" {
  source            = "./modules/ec2"
  public_subnet_id  = module.networking.public_subnet_id
  private_subnet_id = module.networking.private_subnet_id
  public_sg_id      = module.security.public_sg_id
  private_sg_id     = module.security.private_sg_id

  ami_id        = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
}