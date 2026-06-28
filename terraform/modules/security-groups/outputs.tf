#output "alb_sg_id" {
#  value = aws_security_group.alb.id
#}

#output "openwebui_sg_id" {
#  value = aws_security_group.openwebui.id
#}

#output "ollama_sg_id" {
#  value = aws_security_group.ollama.id
#}

output "alb_security_group_id" {
  value = aws_security_group.alb.id
}

output "openwebui_security_group_id" {
  value = aws_security_group.openwebui.id
}

output "ollama_security_group_id" {
  value = aws_security_group.ollama.id
}

