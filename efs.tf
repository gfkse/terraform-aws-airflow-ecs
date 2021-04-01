module "efs" {
  source  = "cloudposse/efs/aws"
  version = "0.22.0"

  name            = var.name
  region          = var.region
  vpc_id          = var.vpc_id
  subnets         = var.private_subnet_ids
  security_groups = [aws_security_group.sg_airflow_internal.id]
  access_points   = jsondecode(file("${path.module}/templates/efs_access_points.json"))
  encrypted       = true

  tags = var.tags
}