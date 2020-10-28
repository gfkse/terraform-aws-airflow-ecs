### SSL Cert ###
data "aws_acm_certificate" "this" {
  domain      = var.certificate_domain_name
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}

### Loadbalancer ###
# TODO(ilya_isakov): change backend protocol to HTTPS
module "aws_alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "5.8.0"

  name               = "${var.name}-lb"
  load_balancer_type = "application"
  internal           = true
  security_groups    = var.lb_security_group_ids
  idle_timeout       = var.lb_idle_timeout
  vpc_id             = var.vpc_id
  subnets            = var.private_subnet_ids

  access_logs = {
    bucket = var.alb_access_logs_bucket
    prefix = "alb/${var.name}-lb"
  }

  target_groups = [
    {
      name_prefix      = "tg-"
      backend_protocol = "HTTP"
      backend_port     = var.lb_target_container_port
      target_type      = "ip"
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/api/experimental/test"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 5
        protocol            = "HTTP"
        matcher             = "200-299"
      }
    }
  ]

  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = data.aws_acm_certificate.this.arn
      target_group_index = 0
    }
  ]

  http_tcp_listeners = [
    {
      port        = 80
      protocol    = "HTTP"
      action_type = "redirect"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  ]

  tags = var.tags
}

### DNS record ###
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
