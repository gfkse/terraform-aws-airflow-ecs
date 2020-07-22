output "ecs_service_id" {
  value = aws_ecs_service.this.id
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

### alb
# output "arn" {
#   description = "ARN of the ALB itself. Useful for debug output, for example when attaching a WAF."
#   value       = element(module.aws_alb.https_listener_arns, 0)
# }
#
# output "arn_suffix" {
#   description = "ARN suffix of our ALB - can be used with CloudWatch"
#   value       = module.aws_alb.load_balancer_arn_suffix
# }
#
# output "dns_name" {
#   description = "The DNS name of the ALB presumably to be used with a friendlier CNAME."
#   value       = module.aws_alb.dns_name
# }
#
# output "id" {
#   description = "The ID of the ALB we created."
#   value       = module.aws_alb.load_balancer_id
# }
#
# output "alb_listener_https_arn" {
#   description = "The ARN of the HTTP ALB Listener we created."
#   value       = element(module.aws_alb.https_listener_arns, 0)
# }
#
# output "zone_id" {
#   description = "The zone_id of the ALB to assist with creating DNS records."
#   value       = module.aws_alb.load_balancer_zone_id
# }

output "target_group_arn" {
  description = "ARN of the target group. Useful for passing to your Auto Scaling group module."
  value       = element(module.aws_alb.target_group_arns, 0)
}
