resource "aws_s3_bucket_object" "object" {
  bucket                  = var.dag_s3_bucket
  key                     = "${var.dag_s3_key}/airflow-log-cleanup.py"
  source                  = "${path.module}/templates/airflow-log-cleanup.py"
  etag                    = filemd5("${path.module}/templates/airflow-log-cleanup.py")
  server_side_encryption  = "aws:kms"
}