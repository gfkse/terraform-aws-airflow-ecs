# TODO (ilya_isakov): make custom `requirements.txt` file optional (currently, when no file provided it creates a folder in container) move realted resources to separate .tf file
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
    transfer_mode    = "ALL"
    verify_mode      = "ONLY_FILES_TRANSFERRED"
  }
}