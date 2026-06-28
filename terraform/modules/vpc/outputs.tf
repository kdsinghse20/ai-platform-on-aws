output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnet_id" {
  value = aws_subnet.public[count.index] ####aws_subnet.public.id
}

output "private_app_subnet_id" {
  value = aws_subnet.private_app[count.index] ###aws_subnet.private_app.id
}

output "private_ai_subnet_id" {
  value = aws_subnet.private_ai[count.index] ####aws_subnet.private_ai.id
}
