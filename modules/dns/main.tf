resource "aws_route53_record" "mail" {
  zone_id = var.zone_id # Your hosted zone ID
  name    = "${var.component}-dev.roboshop.internal"
  type    = "A"

  # If alb_zone_id is passed, create an ALIAS record (for Apps)
  dynamic "alias" {
    for_each = var.alb_zone_id != null ? [1] : []
    content {
      name                   = var.record
      zone_id                = var.alb_zone_id
      evaluate_target_health = true
    }
  }

  # If alb_zone_id is NOT passed, fall back to standard IP routing (for DBs)
  ttl     = var.alb_zone_id == null ? "300" : null
  records = var.alb_zone_id == null ? [var.record] : null
}