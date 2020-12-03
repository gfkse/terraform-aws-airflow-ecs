module "efs" {
  source  = "cloudposse/efs/aws"
  version = "0.22.0"

  region          = var.region
  vpc_id          = var.vpc_id
  subnets         = var.private_subnet_ids
  security_groups = [aws_security_group.sg_airflow_internal.id]
  access_points   = jsondecode(file("${path.module}/templates/efs_access_points.json"))
  encrypted       = true

  tags = var.tags
}

data "aws_iam_policy_document" "datasync-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["datasync.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "dags-datasync-task-role" {
  name               = "DagsDatasyncTaskRole"
  path               = "/airflow_module/"
  assume_role_policy = data.aws_iam_policy_document.datasync-role-policy.json
}

resource "aws_iam_policy" "dags-datasync-task-policy" {
  name        = "dags-datasync-task-policy"
  path        = "/airflow_module/"
  description = "Policy allowing Datasync to copy DAGs from s3 to EFS"

  policy = file("${path.module}/templates/datasync_policy.json")
}

resource "aws_iam_role_policy_attachment" "dags-datasync-task" {
  role       = aws_iam_role.dags-datasync-task-role.name
  policy_arn = aws_iam_policy.dags-datasync-task-policy.arn
}

data "aws_s3_bucket" "dags_bucket" {
  bucket = var.dag_s3_bucket
}

data "aws_subnet" "target_mount_subnet" {
  id = var.private_subnet_ids[0]
}

resource "aws_datasync_location_s3" "dag_source" {
  s3_bucket_arn = data.aws_s3_bucket.dags_bucket.arn
  subdirectory  = "/${var.dag_s3_key}"

  s3_config {
    bucket_access_role_arn = aws_iam_role.dags-datasync-task-role.arn
  }

  tags = var.tags
}

resource "aws_datasync_location_efs" "dag_destination" {
  efs_file_system_arn = module.efs.arn
  subdirectory        = "/usr/local/airflow/dags"

  ec2_config {
    security_group_arns = [aws_security_group.sg_airflow_internal.arn]
    subnet_arn          = data.aws_subnet.target_mount_subnet.arn
  }
}

resource "aws_datasync_task" "dag_sync" {
  destination_location_arn = aws_datasync_location_efs.dag_destination.arn
  name                     = "${var.name}-dags-delivery"
  source_location_arn      = aws_datasync_location_s3.dag_source.arn

  options {
    bytes_per_second = -1
  }
}

resource "aws_datasync_location_s3" "requirements_source" {
  s3_bucket_arn = data.aws_s3_bucket.dags_bucket.arn
  subdirectory  = "/${var.requirements_s3_key}"

  s3_config {
    bucket_access_role_arn = aws_iam_role.dags-datasync-task-role.arn
  }

  tags = var.tags
}

resource "aws_datasync_location_efs" "requirements_destination" {
  efs_file_system_arn = module.efs.arn
  subdirectory        = "/requirements"

  ec2_config {
    security_group_arns = [aws_security_group.sg_airflow_internal.arn]
    subnet_arn          = data.aws_subnet.target_mount_subnet.arn
  }
}

resource "aws_datasync_task" "requirements_sync" {
  destination_location_arn = aws_datasync_location_efs.requirements_destination.arn
  name                     = "${var.name}-requirements-delivery"
  source_location_arn      = aws_datasync_location_s3.requirements_source.arn

  options {
    bytes_per_second = -1
  }
}
