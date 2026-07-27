output "instance_id" {
  value = aws_instance.this.id
}

output "private_ip" {
  value = aws_instance.this.private_ip
}

output "private_dns" {
  value = aws_instance.this.private_dns
}

output "availability_zone" {
  value = aws_instance.this.availability_zone
}

output "security_group_ids" {
  value = aws_instance.this.vpc_security_group_ids
}