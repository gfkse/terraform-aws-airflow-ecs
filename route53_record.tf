resource "aws_route53_record" "this" {
  zone_id = var.dns_zone_id
  name    = var.name
  type    = "A"

  alias {
    name                   = module.aws_alb.this_lb_dns_name
    zone_id                = module.aws_alb.this_lb_zone_id
    evaluate_target_health = true
  }
}