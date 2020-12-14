## Terraform airflow module
Fully equipped AirFlow service on aws, as simple to run as possible. Airflow cluster
created by this module is NOT intended to be used for heavy lifting, main purpose
was to trigger services managed by AWS. Default configurations are for educational
purposes and are the most simple to start with. More information about this module
could be found in [docs.](./docs/index.md)

#### Architecture overview
![Airflow components schema](docs/module_architecture.png)

This root module deploy everything, what is inside the green rectangle.

#### What is NOT deployed by current module (prerequisites):
1. S3 bucket for Terraform config backend (tfstate)
2. Dynamo table with LockID primary key (Used for tfstate locking) 
3. DAGs storage (S3 bucket)
4. S3 bucket (Amazon S3-Managed Encryption Keys (SSE-S3) is used) for load balancer
    access logs (Remember to enable  access logs on the load balancer) see
    [AccessControl](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-access-logs.html)
    Use the following string LB Access Logs S3 Location
    lb-logs-bucket-name-comes-here/logs-lb-airflow
5. VPC, in which AirFlow resides
7. Make sure the IAM user terraform is using has all the required (ec2,s3,
    elasticcache,log etc) permissions
8. DNS zone (Route53) and SSL certificate (acm)
9. Key pair for SSH access to ECS EC2 instances

#### TODOs
1. Add tests:
    a. that Dag are picked up from s3
    c. that dags could run
    d. logs for DAGs appear
    e. webserver responds
2. Check if adjusting of name variable is enough to run multiple AF clusters in one
    account
3. Further improvements: configure autoscaling for worker task