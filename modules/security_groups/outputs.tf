output "public_sg_id" {
  value = aws_security_group.public_sg.id
}

output "private_sg_id" {
  value = aws_security_group.private_sg.id
}

output "default_sg_id" {
  value = aws_security_group.default_sg.id
}
