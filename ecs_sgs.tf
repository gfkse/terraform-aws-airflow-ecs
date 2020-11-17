data "aws_vpc" "selected" {
  id = var.vpc_id
}

# TODO: add limitation by security group
module "sg_in_private_internal_all" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "3.16.0"

  name        = "sg_in_private_internal_all"
  description = "Security group for incoming internal traffic in private network."
  vpc_id      = var.vpc_id

  ingress_cidr_blocks = [data.aws_vpc.selected.cidr_block]
  ingress_rules       = ["all-all"]

  tags = var.tags
}

module "sg_out_private_all" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "3.16.0"

  name        = "sg_out_private_all"
  description = "Security group for outgoing traffic in private network."
  vpc_id      = var.vpc_id

  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]

  tags = var.tags
}