resource "aws_security_group" "sg_airflow_internal" {
  name        = "sg_airflow_internal"
  description = "Security group for Airflow internal traffic (Elasticache, RDS, ENIs, Datasync task, EFS mount targets)."
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow access from self"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge({ Name = "sg_airflow_internal" }, var.tags)
}
