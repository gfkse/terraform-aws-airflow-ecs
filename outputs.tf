output "airflow_webserver_url" {
  value = aws_route53_record.this.fqdn
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.this.name
}

output "elasticache_nodes" {
  value = aws_elasticache_cluster.this.cache_nodes
}

output "elasticache_host" {
  value = aws_elasticache_cluster.this.cache_nodes[0].address
}

output "rds_endpoint" {
  description = "Endpoint URL of the RDS Instance usable for connection string"
  value       = aws_db_instance.this.endpoint
}

output "rds_address" {
  description = "Hostname of the RDS Instance usable for connection string"
  value       = aws_db_instance.this.address
}

output "target_group_arn" {
  description = "ARN of the target group. Useful for passing to your Auto Scaling group module."
  value       = element(module.aws_alb.target_group_arns, 0)
}

output "efs_id" {
  description = "EFS id, where logs, DAGs and configs are stored."
  value       = module.efs.id
}

output "efs_arn" {
  description = "EFS arn, where logs, DAGs and configs are stored."
  value       = module.efs.arn
}

output "efs_access_point_ids" {
  description = "Dictionary of EFS access point ids."
  value       = module.efs.access_point_ids
}

output "efs_access_point_arns" {
  description = "Dictionary of EFS access point arns."
  value       = module.efs.access_point_arns
}