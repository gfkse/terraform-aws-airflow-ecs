data "aws_acm_certificate" "this" {
  domain      = var.certificate_domain_name
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}