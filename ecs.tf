resource "aws_ecs_cluster" "this" {
  name = "${var.name}-cluster"
  tags = var.tags
}

resource "aws_ecs_service" "webserver" {
  name                = "${var.name}-webserver"
  cluster             = aws_ecs_cluster.this.id
  task_definition     = aws_ecs_task_definition.webserver.arn
  launch_type         = var.ecs_launch_type
  desired_count       = 1
  scheduling_strategy = "REPLICA"
  platform_version    = var.ecs_launch_type == "FARGATE" ? "1.4.0" : null

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
    security_groups = [aws_security_group.sg_airflow_internal.id]
  }
}

resource "aws_ecs_service" "scheduler" {
  name                = "${var.name}-scheduler"
  cluster             = aws_ecs_cluster.this.id
  task_definition     = aws_ecs_task_definition.scheduler.arn
  launch_type         = var.ecs_launch_type
  desired_count       = 1
  scheduling_strategy = "REPLICA"
  platform_version    = var.ecs_launch_type == "FARGATE" ? "1.4.0" : null

  # TODO(ilya_isakov): add placement constraint to a variable
  # placement_constraints {
  #   type       = "memberOf"
  #   expression = "attribute:ecs.availability-zone in [eu-central-1a, eu-central-1b]"
  # }

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [aws_security_group.sg_airflow_internal.id]
  }
}

resource "aws_ecs_service" "worker" {
  name                = "${var.name}-worker"
  cluster             = aws_ecs_cluster.this.id
  task_definition     = aws_ecs_task_definition.worker.arn
  launch_type         = var.ecs_launch_type
  desired_count       = 1
  scheduling_strategy = "REPLICA"
  platform_version    = var.ecs_launch_type == "FARGATE" ? "1.4.0" : null

  # TODO(ilya_isakov): add placement constraint to a variable
  # placement_constraints {
  #   type       = "memberOf"
  #   expression = "attribute:ecs.availability-zone in [eu-central-1a, eu-central-1b]"
  # }

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [aws_security_group.sg_airflow_internal.id]
  }
}

resource "aws_ecs_task_definition" "webserver" {
  family                   = "${var.name}-webserver"
  container_definitions    = data.template_file.webserver.rendered
  memory                   = var.webserver_task_definition_memory
  cpu                      = var.webserver_task_definition_cpu
  network_mode             = var.webserver_task_definition_network_mode
  execution_role_arn       = var.ecs_launch_type == "FARGATE" ? aws_iam_role.ecs_fargate_task_execution_role.arn : null
  requires_compatibilities = [var.ecs_launch_type]
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  volume {
    name      = "requirements_on_ec2"
    host_path = "/home/ec2-user/airflow/docker/requirements.txt"
  }

  volume {
    name = "requirements"
    efs_volume_configuration {
      file_system_id          = module.efs.id
      transit_encryption      = "ENABLED"
      transit_encryption_port = 2997
      authorization_config {
        access_point_id = module.efs.access_point_ids["requirements"]
        iam             = "ENABLED"
      }
    }
  }

  volume {
    name = "dags"
    efs_volume_configuration {
      file_system_id          = module.efs.id
      transit_encryption      = "ENABLED"
      transit_encryption_port = 2998
      authorization_config {
        access_point_id = module.efs.access_point_ids["usr/local/airflow/dags"]
        iam             = "ENABLED"
      }
    }
  }

  volume {
    name = "worker_logs"
    efs_volume_configuration {
      file_system_id          = module.efs.id
      transit_encryption      = "ENABLED"
      transit_encryption_port = 2999
      authorization_config {
        access_point_id = module.efs.access_point_ids["var/log/worker"]
        iam             = "ENABLED"
      }
    }
  }

  tags = var.tags
}

resource "aws_ecs_task_definition" "scheduler" {
  family                   = "${var.name}-scheduler"
  container_definitions    = data.template_file.scheduler.rendered
  memory                   = var.scheduler_task_definition_memory
  cpu                      = var.scheduler_task_definition_cpu
  network_mode             = var.scheduler_task_definition_network_mode
  execution_role_arn       = var.ecs_launch_type == "FARGATE" ? aws_iam_role.ecs_fargate_task_execution_role.arn : null
  requires_compatibilities = [var.ecs_launch_type]
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  volume {
    name      = "requirements_on_ec2"
    host_path = "/home/ec2-user/airflow/docker/requirements.txt"
  }

  volume {
    name = "requirements"
    efs_volume_configuration {
      file_system_id          = module.efs.id
      transit_encryption      = "ENABLED"
      transit_encryption_port = 2997
      authorization_config {
        access_point_id = module.efs.access_point_ids["requirements"]
        iam             = "ENABLED"
      }
    }
  }

  volume {
    name = "dags"
    efs_volume_configuration {
      file_system_id          = module.efs.id
      transit_encryption      = "ENABLED"
      transit_encryption_port = 2998
      authorization_config {
        access_point_id = module.efs.access_point_ids["usr/local/airflow/dags"]
        iam             = "ENABLED"
      }
    }
  }

  volume {
    name = "scheduler_logs"
    efs_volume_configuration {
      file_system_id          = module.efs.id
      transit_encryption      = "ENABLED"
      transit_encryption_port = 2999
      authorization_config {
        access_point_id = module.efs.access_point_ids["var/log/scheduler"]
        iam             = "ENABLED"
      }
    }
  }

  tags = var.tags
}

resource "aws_ecs_task_definition" "worker" {
  family                   = "${var.name}-worker" # var.task_definition_family
  container_definitions    = data.template_file.worker.rendered
  memory                   = var.worker_task_definition_memory
  cpu                      = var.worker_task_definition_cpu
  network_mode             = var.worker_task_definition_network_mode
  execution_role_arn       = var.ecs_launch_type == "FARGATE" ? aws_iam_role.ecs_fargate_task_execution_role.arn : null
  requires_compatibilities = [var.ecs_launch_type]
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  volume {
    name      = "requirements_on_ec2"
    host_path = "/home/ec2-user/airflow/docker/requirements.txt"
  }

  volume {
    name = "requirements"
    efs_volume_configuration {
      file_system_id          = module.efs.id
      transit_encryption      = "ENABLED"
      transit_encryption_port = 2997
      authorization_config {
        access_point_id = module.efs.access_point_ids["requirements"]
        iam             = "ENABLED"
      }
    }
  }

  volume {
    name = "dags"
    efs_volume_configuration {
      file_system_id          = module.efs.id
      transit_encryption      = "ENABLED"
      transit_encryption_port = 2998
      authorization_config {
        access_point_id = module.efs.access_point_ids["usr/local/airflow/dags"]
        iam             = "ENABLED"
      }
    }
  }

  volume {
    name = "worker_logs"
    efs_volume_configuration {
      file_system_id          = module.efs.id
      transit_encryption      = "ENABLED"
      transit_encryption_port = 2999
      authorization_config {
        access_point_id = module.efs.access_point_ids["var/log/worker"]
        iam             = "ENABLED"
      }
    }
  }

  tags = var.tags
}

data "template_file" "webserver" {
  template = file("${path.module}/templates/webserver.json")
  vars = {
    name                                  = var.name
    region                                = var.region
    fernet_key                            = var.airflow_fernet_key
    load_example_dags                     = var.load_example_dags
    airflow_docker_elasticache_cache_host = aws_elasticache_cluster.this.cache_nodes[0].address
    airflow_webserver_rbac                = var.airflow_webserver_rbac
    airflow_core_dag_concurrency          = var.airflow_core_dag_concurrency
    airflow_core_worker_concurrency       = var.airflow_core_worker_concurrency
    airflow_core_load_default_connections = var.airflow_core_load_default_connections
    rds_instance_endpoint                 = aws_db_instance.this.endpoint
    rds_instance_endpoint                 = aws_db_instance.this.endpoint
    rds_username                          = var.rds_username
    rds_username                          = var.rds_username
    rds_password                          = var.rds_password
    rds_password                          = var.rds_password
    rds_db_name                           = local.rds_name
    rds_db_name                           = local.rds_name
    airflow_core_logging_level            = var.airflow_core_logging_level
    airflow_webserver_dag_orientation     = var.airflow_webserver_dag_orientation
    airflow_docker_image                  = var.airflow_image
  }
}

data "template_file" "scheduler" {
  template = file("${path.module}/templates/scheduler.json")
  vars = {
    name                                    = var.name
    region                                  = var.region
    fernet_key                              = var.airflow_fernet_key
    load_example_dags                       = var.load_example_dags
    airflow_docker_elasticache_cache_host   = aws_elasticache_cluster.this.cache_nodes[0].address
    airflow_core_dag_concurrency            = var.airflow_core_dag_concurrency
    airflow_core_worker_concurrency         = var.airflow_core_worker_concurrency
    airflow_core_load_default_connections   = var.airflow_core_load_default_connections
    rds_instance_endpoint                   = aws_db_instance.this.endpoint
    rds_username                            = var.rds_username
    rds_password                            = var.rds_password
    rds_db_name                             = local.rds_name
    airflow_core_logging_level              = var.airflow_core_logging_level
    airflow_docker_image                    = var.airflow_image
    airflow_scheduler_dag_dir_list_interval = var.airflow_scheduler_dag_dir_list_interval
  }
}

data "template_file" "worker" {
  template = file("${path.module}/templates/worker.json")
  vars = {
    name                                  = var.name
    region                                = var.region
    fernet_key                            = var.airflow_fernet_key
    load_example_dags                     = var.load_example_dags
    airflow_docker_elasticache_cache_host = aws_elasticache_cluster.this.cache_nodes[0].address
    airflow_core_dag_concurrency          = var.airflow_core_dag_concurrency
    airflow_core_worker_concurrency       = var.airflow_core_worker_concurrency
    airflow_core_load_default_connections = var.airflow_core_load_default_connections
    rds_instance_endpoint                 = aws_db_instance.this.endpoint
    rds_username                          = var.rds_username
    rds_password                          = var.rds_password
    rds_db_name                           = local.rds_name
    airflow_core_logging_level            = var.airflow_core_logging_level
    airflow_smtp_host                     = var.airflow_smtp_host
    airflow_smtp_port                     = var.airflow_smtp_port
    airflow_smtp_ssl                      = var.airflow_smtp_smtp_ssl
    airflow_smtp_starttls                 = var.airflow_smtp_starttls
    airflow_smtp_user                     = var.airflow_smtp_user
    airflow_smtp_password                 = var.airflow_smtp_password
    airflow_smtp_mail_from                = var.airflow_smtp_mail_from
    airflow_docker_image                  = var.airflow_image
  }
}