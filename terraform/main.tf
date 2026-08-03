# Root Terraform configuration

module "networking" {
  source = "./modules/networking"

  environment = var.environment
}


module "security" {

  source = "./modules/security"

  environment = var.environment

  vpc_id = module.networking.vpc_id

}

module "ecr" {

  source = "./modules/ecr"

  environment = var.environment

}


module "alb" {

  source = "./modules/alb"

  environment = var.environment

  vpc_id = module.networking.vpc_id

  public_subnet_ids = module.networking.public_subnet_ids

  alb_security_group_id = module.security.alb_security_group_id

}

module "ecs" {

  source = "./modules/ecs"

  environment = var.environment

  private_subnet_ids = module.networking.private_subnet_ids

  ecs_security_group_id = module.security.ecs_security_group_id

  target_group_arn = module.alb.target_group_arn

  execution_role_arn = module.security.ecs_execution_role_arn

  repository_url = module.ecr.repository_url
  cpu            = "256"
  memory         = "512"
  container_port = 5000
  desired_count  = 2
  task_role_arn  = module.security.ecs_task_role_arn

}


module "monitoring" {

  source = "./modules/monitoring"

  environment = var.environment

  cluster_name = module.ecs.cluster_name

  service_name = module.ecs.service_name

  alarm_email = var.alarm_email

}


