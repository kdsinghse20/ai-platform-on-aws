output "alb_sg_id" {
  value = aws_security_group.alb.id
}

output "openwebui_sg_id" {
  value = aws_security_group.openwebui.id
}

output "ollama_sg_id" {
  value = aws_security_group.ollama.id
}
