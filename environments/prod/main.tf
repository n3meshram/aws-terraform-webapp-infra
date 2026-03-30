provider "aws" {
  region = "ap-south-1"
}




module "vpc" {
  source = "../../modules/vpc"

  vpc_cidr    = var.vpc_cidr
  environment = var.environment

  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  azs                  = var.azs
}

module "security_group" {
  source      = "../../modules/security_group"
  vpc_id      = module.vpc.vpc_id
  environment = var.environment
}



module "launch_template" {
  source = "../../modules/launch-template"

  environment       = var.environment
  ami_id            = var.ami_id
  instance_type     = var.instance_type
  
  security_group_id = module.security_group.ec2_sg_id
  instance_profile_name = module.iam.instance_profile_name
}

module "autoscaling" {
  source = "../../modules/autoscaling"

  project            = var.project
  environment = var.environment

  private_subnets    = module.vpc.private_subnets
  target_group_arn   = module.alb.target_group_arn
  launch_template_id = module.launch_template.launch_template_id
  
}


module "alb" {
  source = "../../modules/alb"

  project        = var.project
  environment    = var.environment
  vpc_id         = module.vpc.vpc_id
  public_subnets = module.vpc.public_subnets
  alb_sg_id      = module.security_group.alb_sg_id
}

module "iam" {
  source = "../../modules/iam"
  environment = var.environment
}
