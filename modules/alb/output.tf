output "public_tg_arn" {
  value = aws_lb_target_group.public_tg.arn
}

output "public_alb_dns" {
  value = aws_lb.public_alb.dns_name
}

output "alb_zone_id" {
  value = aws_lb.public_alb.zone_id
}