module "alb" {

  source = "../../modules/alb"

  project_name = "ai-ollama"
  environment  = "dev"

  vpc_id = module.vpc.vpc_ids

  public_subnet_ids = module.vpc.public_subnet_ids

  alb_security_group_id = module.security_groups.alb_security_group_id

  target_instance_id = module.openwebui.instance_id

}