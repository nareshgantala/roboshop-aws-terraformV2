resource "aws_route53_record" "main" {
  zone_id = "Z09762381HTCZ4LICCNHQ"
  name    = var.component
  type    = "A"
  ttl     = 300
    alias {
    name                   = var.record
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}