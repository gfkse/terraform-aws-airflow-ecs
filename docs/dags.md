#### DAGs delivery
Module deploys [Datasync task](../data_sync_dags.tf), which copies DAGs from S3
bucket to EFS. It could be triggered manually or in the DAGs delivery pipeline.