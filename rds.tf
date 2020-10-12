resource "aws_db_instance" "this" {
  allocated_storage         = var.rds_airflow_docker_storage
  storage_type              = "gp2"
  engine                    = "postgres"
  engine_version            = "10.13"
  instance_class            = var.rds_airflow_docker_instance_class
  name                      = local.rds_name  # this is not a Name tag for resouce, this is a name of db
  identifier                = "rds-${var.name}"
  username                  = var.rds_airflow_docker_username
  password                  = var.rds_airflow_docker_password
  final_snapshot_identifier = "final-snapshot-${var.name}"
  vpc_security_group_ids    = var.rds_security_group_ids
  db_subnet_group_name      = aws_db_subnet_group.this.name
  backup_retention_period   = 7
  maintenance_window        = "Mon:00:00-Mon:03:00"
  backup_window             = "03:46-04:46"
  tags = merge(
    var.tags,
    {
      "Name" = local.rds_name
    },
  )
  copy_tags_to_snapshot = "true"
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.name}-db_subnet_group"
  subnet_ids = var.private_subnet_ids
  tags = merge(
    var.tags,
    {
      "Name" = var.name
    },
  )
}
