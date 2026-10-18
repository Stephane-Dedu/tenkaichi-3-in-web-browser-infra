resource "aws_route53_record" "bt3" {
  zone_id = var.zone_id
  name    = var.hostname
  type    = "CNAME"
  ttl     = 300
  records = [var.target]

  lifecycle {
    prevent_destroy = true
  }
}
