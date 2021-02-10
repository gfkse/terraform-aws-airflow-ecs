data "aws_iam_policy_document" "fargate-execution-role-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_fargate_task_execution_role" {
  name               = "${var.name}-ecs-fargate-task-execution-role"
  path               = "/airflow_module/"
  assume_role_policy = data.aws_iam_policy_document.fargate-execution-role-assume-role-policy.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy_attachment" {
  role       = aws_iam_role.ecs_fargate_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


data "aws_iam_policy_document" "instance-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "airflow-task-definition-execution-role" {
  name               = "airflowTaskDefinitionExecutionRole"
  path               = "/airflow_module/"
  assume_role_policy = data.aws_iam_policy_document.instance-assume-role-policy.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "airflow-task-definition-execution-role-policy-attachment" {
  role       = aws_iam_role.airflow-task-definition-execution-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role" # it is aws managed policy with ugly name
}

# Enable access to System Manager
resource "aws_iam_role_policy_attachment" "system-manager-policy-attachment" {
  role       = aws_iam_role.airflow-task-definition-execution-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "airflow-task-definition-execution-profile" {
  name = "airflow-task-definition-execution-profile"
  role = aws_iam_role.airflow-task-definition-execution-role.name
}

resource "aws_iam_role" "ecs_task_role" {
  name               = "${var.name}-ecs-task-role"
  path               = "/airflow_module/"
  assume_role_policy = data.aws_iam_policy_document.fargate-execution-role-assume-role-policy.json

  tags = var.tags
}

resource "aws_iam_policy" "ecs_task_policy_efs_usage" {
  name = "${var.name}-ecs-task-policy-efs-usage"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "elasticfilesystem:ClientMount",
                "elasticfilesystem:ClientWrite"
            ],
            "Resource": "${module.efs.arn}",
            "Condition": {
                "StringEquals": {
                    "elasticfilesystem:AccessPointArn": [
                        "${module.efs.access_point_arns["var/log/scheduler"]}",
                        "${module.efs.access_point_arns["var/log/worker"]}",
                        "${module.efs.access_point_arns["usr/local/airflow/dags"]}"
                    ]
                }
            }
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs_task_policy_efs_usage" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_task_policy_efs_usage.arn
}

