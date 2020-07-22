# ALB
# module "airflow-docker-ecs-alb" {
#   source = "./modules/tfm_application_load_balancer"
#
#   name               = "af-lb-${var.environment_short}"
#   # dns_zone_id        = var.dns_zone_id
#   public_dns_zone_id = var.public_dns_zone_id
#   vpc_id             = var.vpc_id
#   backend_port       = "8080"
#   health_check_path  = "/api/experimental/test"
#   security_groups    = var.lb_security_group_ids
#   # target_id          = [module.airflow-docker-ecs.arn]             # and this here
#   target_type        = "ip"
#   target_count       = 0
#   tags               = var.tags
#   subnet_ids         = var.private_subnet_ids
#   private_domain     = var.private_domain
# }

### SSL Cert ###
data "aws_acm_certificate" "this" {
  domain      = var.domain_name
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}

# TODO(ilya_isakov): make it possible to provide external bucket
resource "aws_s3_bucket" "log_bucket" {
  bucket        = "logs-lb-${var.name}"
  policy        = data.aws_iam_policy_document.bucket_policy.json
  force_destroy = false
  tags          = var.tags

  lifecycle_rule {
    id      = "log-expiration"
    enabled = "true"

    expiration {
      days = "7"
    }
  }
}

### Loadbalancer ###
# TODO(ilya_isakov): change backend protocol to HTTPS
module "aws_alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "5.8.0"

  name = "${var.name}-lb"
  load_balancer_type  = "application"
  internal            = true
  security_groups     = var.lb_security_group_ids
  idle_timeout        = var.lb_idle_timeout
  vpc_id              = var.vpc_id
  subnets             = var.private_subnet_ids

  access_logs = {
    bucket = "logs-lb-${var.name}"
  }

  target_groups = [
    {
      name_prefix                 = "tg-"
      backend_protocol            = "HTTP"
      backend_port                = var.lb_target_container_port
      target_type                 = "ip"
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
        port = "443"
        protocol = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  ]

  tags = var.tags
}

# TODO(ilya_isakov): old moudle left overs, should be rewritten to make route53 record work

# ### DNS record ###
# resource "aws_route53_record" "this" {
#   zone_id = var.dns_zone_id
#   name    = var.name
#   type    = "A"
#
#   alias {
#     name                   = module.aws_alb.this_lb_dns_name
#     zone_id                = module.aws_alb.this_lb_zone_id
#     evaluate_target_health = true
#   }
# }

# ### Public DNS CNAME record ###
# resource "aws_route53_record" "public" {
#   providers = {
#     aws = "aws.public_dns"
#   }  # aws.public_dns
#   zone_id  = var.public_dns_zone_id
#   name     = var.name
#   type     = "CNAME"
#   ttl      = "60"
#   # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to
#   # force an interpolation expression to be interpreted as a list by wrapping it
#   # in an extra set of list brackets. That form was supported for compatibility in
#   # v0.11, but is no longer supported in Terraform v0.12.
#   #
#   # If the expression in the following list itself returns a list, remove the
#   # brackets to avoid interpretation as a list of lists. If the expression
#   # returns a single list item then leave it as-is and remove this TODO comment.
#   records = [module.aws_alb.dns_name]
# }
