resource "aws_route53_record" "main" {
  zone_id = "Z09762381HTCZ4LICCNHQ"
  name    = var.component
  type    = "A"
  ttl     = 300
  records = var.record
}