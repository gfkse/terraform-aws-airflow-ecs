# TODO(ilya_isakov): change backend protocol to HTTPS
module "aws_alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "5.8.0"

  name               = "${var.name}-lb"
  load_balancer_type = "application"
  internal           = true
  security_groups    = concat([aws_security_group.sg_airflow_internal.id], var.lb_security_group_ids)
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
        interval            = 20
        path                = "/api/experimental/test"
        port                = "traffic-port"
        healthy_threshold   = 5
        unhealthy_threshold = 5
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