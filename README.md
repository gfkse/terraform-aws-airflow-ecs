# Terraform airflow module
Fully equipped AirFlow service on AWS, as simple to run as possible. Airflow cluster
created by this module is NOT intended to be used for heavy lifting, main purpose
is to trigger services managed by AWS. Default configurations are for educational
purposes and are the most simple to start with. More information about this module
can be found in [docs.](./docs/index.md)

## Architecture overview
![Airflow components schema](docs/module_architecture.png)

This root module deploys everything that is inside the green rectangle.

## What is NOT deployed by the current module (prerequisites):
1. S3 bucket for Terraform config backend (tfstate)
2. Dynamo table with LockID primary key (Used for tfstate locking) 
3. DAGs storage (S3 bucket)
4. S3 bucket (Amazon S3-Managed Encryption Keys (SSE-S3) is used) for load balancer
    access logs (Remember to enable  access logs on the load balancer) see
    [AccessControl](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-access-logs.html)
    Use the following string LB Access Logs S3 Location
    lb-logs-bucket-name-comes-here/logs-lb-airflow
5. VPC AirFlow resides in
7. Make sure the IAM user your terraform is using has all the required permissions (EC2,S3, ElasticCache, etc.)
8. DNS zone (Route53) and SSL certificate (ACM)
9. Key pair for SSH access to ECS EC2 instances

## Troubleshooting

### First deployment

### Deployment: No valid mount targets for EFS filesystem
```
module.airflow.module.efs.aws_efs_mount_target.default[1]: Creation complete after 1m24s [id=fsmt-XXX]
module.airflow.module.efs.aws_efs_mount_target.default[0]: Creation complete after 1m24s [id=fsmt-XXX]

Error: error creating DataSync Location EFS: InvalidRequestException: No valid mount targets for EFS filesystem subnet-XXX found in subnet arn:aws:elasticfilesystem:eu-central-1:XXX:file-system/fs-XXX. Please provide a subnet that contains a mount target.
{
RespMetadata: {
StatusCode: 400,
RequestID: "..."
},
ErrorCode: "EfsFilesystemNoMountTargetsInSubnet",
Message_: "No valid mount targets for EFS filesystem subnet-XXX found in subnet arn:aws:elasticfilesystem:eu-central-1:XXX:file-system/fs-XXX. Please provide a subnet that contains a mount target."
}

```

### Connect to the container instance
```
ssh -i <your-key> -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ec2-user@<instance-ip>
```
In case of:
```
ssh: connect to host <instance-ip> port 22: Operation timed out
```
adapt the security-group and edit inbound rules.

### `airflowTaskDefinitionExecutionRole` already exists
```
Error: Error creating IAM Role airflowTaskDefinitionExecutionRole: EntityAlreadyExists: Role with name airflowTaskDefinitionExecutionRole already exists.
        status code: 409, request id: ...
```
This may happen during the redeployment.
Delete the role manually and run terraform again.

### AWS ECS tasks cannot start: No Container Instances were found in your cluster
In general an ECS container instance should have a role with `AmazonEC2ContainerServiceforEC2Role` policy attached to it.
This is one of the most occurring issues as Terraform does not see the updates to the profile.
For other issues, please see the following [post][no-containter-instance].

Check the IAM Role in:
```
AWS Console => EC2 => Select the contianter instance: Name: <...>-ecs-asg  => Details => IAM Role
```  
If you see a message like:
```
No roles attached to instance profile: airflow-task-definition-execution-profile
```
then:
```
$ terraform state list | grep profile
module.airflow.aws_iam_instance_profile.airflow-task-definition-execution-profile
$ terraform state show module.airflow.aws_iam_instance_profile.airflow-task-definition-execution-profile
# module.airflow.aws_iam_instance_profile.airflow-task-definition-execution-profile:
resource "aws_iam_instance_profile" "airflow-task-definition-execution-profile" {
    arn         = "arn:aws:iam::XXX:instance-profile/airflow-task-definition-execution-profile"
    create_date = "XXX"
    id          = "airflow-task-definition-execution-profile"
    name        = "airflow-task-definition-execution-profile"
    path        = "/"
    role        = "airflowTaskDefinitionExecutionRole"
    unique_id   = "XXX"
}
$ terraform destroy -target=module.airflow.aws_iam_instance_profile.airflow-task-definition-execution-profile
```
Run terraform again:
```
terraform plan
terraform apply
```

#### TODOs
1. Add tests:
    * that DAGs are picked up from AWS S3
    * that DAGs can run
    * that logs for DAGs appear
    * that webserver responds
2. Check if adjusting of name variable is enough to run multiple AF clusters in one
    account
3. Further improvements: configure autoscaling for worker task

[no-containter-instance]: https://stackoverflow.com/questions/36523282/aws-ecs-error-when-running-task-no-container-instances-were-found-in-your-clust