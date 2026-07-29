output "vpc_id" {
  value = module.vpc.vpc_id
}
output "openwebui_private_ip" {
  value = module.openwebui.private_ip
}

output "ollama_private_ip" {
  value = module.ollama.private_ip
}

output "ollama_instance_id" {
  value = module.ollama.instance_id
}

output "openwebui_instance_id" {
  value = module.openwebui.instance_id
}

output "alb_dns_name" {
  value = module.alb.alb_dns_name
}