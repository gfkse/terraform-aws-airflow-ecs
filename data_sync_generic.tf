
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
  name               = "${var.name}-dags-datasync-task-role"
  path               = "/airflow_module/"
  assume_role_policy = data.aws_iam_policy_document.datasync-role-policy.json
}

resource "aws_iam_policy" "dags-datasync-task-policy" {
  name        = "${var.name}-dags-datasync-task-policy"
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