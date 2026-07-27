output "vpc_id" {
  value = module.vpc.vpc_id
}
output "openwebui_private_ip" {
  value = module.openwebui.private_ip
}

output "ollama_private_ip" {
  value = module.ollama.private_ip
}