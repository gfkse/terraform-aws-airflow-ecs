resource "aws_cloudwatch_log_group" "ecs_cloudwatch_logs" {
  name              = "/ecs/${var.name}"
  retention_in_days = var.cloudwatch_retention
  tags              = var.tags
}