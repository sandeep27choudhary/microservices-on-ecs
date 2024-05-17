# output.tf

output "backend_security_group_id" {
  value = aws_security_group.backend_sg.id
}


