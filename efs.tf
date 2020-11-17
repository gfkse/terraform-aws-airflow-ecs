module "efs" {
  source  = "cloudposse/efs/aws"
  version = "0.22.0"

  region             = var.region
  vpc_id             = var.vpc_id
  subnets            = var.private_subnet_ids
  security_groups    = [
    module.sg_in_private_internal_all.this_security_group_id, # TODO(ilya_isakov): add DataSync task security group here once DS task would be added to this module to copy DAGs from s3
    module.sg_out_private_all.this_security_group_id
  ]
  access_points      = jsondecode(file("${path.module}/templates/efs_access_points.json"))
  encrypted          = true

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
  path               = "/airflow_module/datasync/"
  assume_role_policy = data.aws_iam_policy_document.datasync-role-policy.json
}

resource "aws_iam_policy" "dags-datasync-task-policy" {
  name        = "dags-datasync-task-policy"
  path        = "/airflow_module/datasync/"
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

resource "aws_datasync_location_s3" "dag_source" {
  s3_bucket_arn = data.aws_s3_bucket.dags_bucket.arn
  subdirectory  = "/${var.dag_s3_key}"

  s3_config {
    bucket_access_role_arn = aws_iam_role.dags-datasync-task-role.arn  # TODO: replace
  }

  tags = var.tags
}

data "aws_security_group" "sg_in_private_internal_all" {
  id = module.sg_in_private_internal_all.this_security_group_id
}

data "aws_security_group" "sg_out_private_all" {
  id = module.sg_out_private_all.this_security_group_id
}

data "aws_subnet" "target_mount_subnet" {
  id = var.private_subnet_ids[0]
}

resource "aws_datasync_location_efs" "dag_destination" {
  efs_file_system_arn = module.efs.arn  # aws_efs_mount_target.example.file_system_arn
  subdirectory        = "/usr/local/airflow/dags"

  ec2_config {
    security_group_arns = [
      data.aws_security_group.sg_out_private_all.arn,
      data.aws_security_group.sg_in_private_internal_all.arn
    ]
    subnet_arn          = data.aws_subnet.target_mount_subnet.arn
  }
}

resource "aws_datasync_task" "example" {
  destination_location_arn = aws_datasync_location_efs.dag_destination.arn # aws_datasync_location_s3.destination.arn
  name                     = "${var.name}-dags-delivery"
  source_location_arn      = aws_datasync_location_s3.dag_source.arn

  options {
    bytes_per_second = -1
  }
}