#### DAGs delivery
This module deploys [Datasync task](../data_sync_dags.tf), which copies DAGs from an S3
bucket to EFS. It can be triggered manually or in the DAGs delivery pipeline.