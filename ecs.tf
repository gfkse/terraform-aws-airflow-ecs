### ============================================================= ###
### ECS related resources                                         ###
### ============================================================= ###

resource "aws_ecs_cluster" "this" {
  name = "${var.name}-cluster"
  tags = var.tags
}

# TODO(ilya_isakov): try ecs module instead of resource. To be checked: it could have roles for service, ecs, etc.
# module "airflow-docker-ecs" {
#   source  = "terraform-aws-modules/ecs/aws"
#   version = "2.0.0"
#
#   name       = "${var.name}-cluster"
#   tags       = var.tags
# }

resource "aws_ecs_service" "this" {
  name                = "${var.name}-service"
  cluster             = aws_ecs_cluster.this.id  # module.airflow-docker-ecs.this_ecs_cluster_id  #
  task_definition     = aws_ecs_task_definition.airflow.arn
  desired_count       = var.ecs_airflow_docker_desired_count
  scheduling_strategy = "REPLICA"

  load_balancer {
    target_group_arn = element(module.aws_alb.target_group_arns, 0)
    container_name   = var.lb_target_container_name
    container_port   = var.lb_target_container_port
  }

  # TODO(ilya_isakov): add placement constraint to a variable
  # placement_constraints {
  #   type       = "memberOf"
  #   expression = "attribute:ecs.availability-zone in [eu-central-1a, eu-central-1b]"
  # }

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = var.ecs_airflow_docker_security_group_id
  }
}

resource "aws_ecs_task_definition" "airflow" {
  family                    = var.task_definition_family
  container_definitions     = data.template_file.airflow.rendered
  memory                    = var.task_definition_memory
  cpu                       = var.task_definition_cpu
  network_mode              = var.task_definition_network_mode
  # execution_role_arn        = var.airflow_task_definition_execution_role_arn
  requires_compatibilities  = ["EC2"]

  volume {
    name      = "requirements"
    host_path = "/home/ec2-user/airflow/docker/requirements.txt"
  }

  volume {
    name      = "dags"
    host_path = "/home/ec2-user/airflow/dags"
  }

  tags        = var.tags
}

data "template_file" "airflow" {
  template = file("${path.module}/templates/airflow.json")
  vars = {
    airflow_docker_rds_instance_endpoint      = aws_db_instance.this.address
    rds_airflow_docker_username               = var.rds_airflow_docker_username
    rds_airflow_docker_password               = var.rds_airflow_docker_password
    rds_airflow_docker_db_name                = local.rds_name
    name                                      = var.name
    airflow_docker_elasticache_cache_host     = aws_elasticache_cluster.this.cache_nodes[0].address
    airflow_docker_image                      = var.airflow_image_version
    fernet_key                                = var.airflow_fernet_key
    region                                    = var.region
  }
}

data "template_file" "user_data" {
  template = file("${path.module}/templates/user_data.sh")

  vars = {
    cluster_name          = "${var.name}-cluster"
    dag_s3_bucket         = var.dag_s3_bucket
    dag_s3_key            = var.dag_s3_key
    rclone_secret_key_id  = var.rclone_secret_key_id
    rclone_secret_key     = var.rclone_secret_key
    region                = var.region
    custom_user_data      = var.custom_user_data
  }
}

resource "aws_launch_configuration" "ecs" {
  name_prefix           = "lc-${var.name}"
  image_id              = var.ecs_airflow_docker_ami_id
  instance_type         = var.ecs_airflow_docker_instance_type
  user_data             = data.template_file.user_data.rendered
  key_name              = var.key_name
  iam_instance_profile  = aws_iam_instance_profile.airflow-task-definition-execution-profile.name

  ebs_block_device {
    device_name           = var.ebs_block_device_name
    volume_size           = var.ebs_block_device_volume_size
    volume_type           = var.ebs_block_device_volume_type
    delete_on_termination = var.ebs_block_device_delete_on_termination
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "ecs" {
  name                 = "autoscaling-${var.name}"
  launch_configuration = aws_launch_configuration.ecs.name
  vpc_zone_identifier  = var.private_subnet_ids
  min_size             = 1
  max_size             = 2

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "${var.name}-ecs-asg"
    propagate_at_launch = true
  }

  tag {
    key                 = "AppService"
    value               = "Airflow"
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = var.tags
    iterator = tag
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

}

resource "aws_cloudwatch_log_group" "ecs_cloudwatch_logs" {
  name = "/ecs/${var.name}"
  tags = var.tags
}