resource "aws_elasticache_cluster" "this" {
  cluster_id           = var.name
  engine               = "redis"
  engine_version       = "5.0.5"
  node_type            = var.elasticache_node_type
  num_cache_nodes      = 1
  parameter_group_name = aws_elasticache_parameter_group.this.name
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.this.name
  security_group_ids   = [aws_security_group.sg_airflow_internal.id]
  tags                 = var.tags
}

resource "aws_elasticache_subnet_group" "this" {
  name       = "${var.name}-cache-subnet"
  subnet_ids = [element(var.private_subnet_ids, 0)]
}

resource "aws_elasticache_parameter_group" "this" {
  name   = "af-cache-params"
  family = "redis5.0"

  parameter {
    name  = "activerehashing"
    value = "yes"
  }
}
