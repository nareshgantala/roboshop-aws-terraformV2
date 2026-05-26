output "public_alb_sg" {
  value = aws_security_group.public_alb.id
}

output "internal_alb_sg" {
  value = aws_security_group.internal_alb.id
}

output "frontend_sg" {
  value = aws_security_group.frontend_sg.id
}

output "cart_sg" {
  value = aws_security_group.cart_sg.id
}

output "catalouge_sg" {
  value = aws_security_group.catalogue_sg.id
}

output "user_sg" {
  value = aws_security_group.user_sg.id
}

output "orders_sg" {
  value = aws_security_group.orders_sg.id
}

output "ratings_sg" {
  value = aws_security_group.ratings_sg.id
}

output "payment_sg" {
  value = aws_security_group.payment_sg.id
}

output "shipping_sg" {
  value = aws_security_group.shipping_sg
}

output "mysql_sg" {
  value = aws_security_group.mysql_sg.id
}

output "rabbitmq_sg" {
  value = aws_security_group.rabbitmq_sg.id
}

output "valkey_sg" {
  value = aws_security_group.valkey_sg.id
}

