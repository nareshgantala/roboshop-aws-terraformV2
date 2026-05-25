output "public_alb_sg" {
  value = aws_security_group.public_alb.id
}

output "internal_alb_sg" {
  value = aws_security_group.internal_alb.id
}