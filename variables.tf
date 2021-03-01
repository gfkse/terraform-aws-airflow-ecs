### general
variable "name" {
  type        = string
  description = "Used for ecs cluster and service names as prefix; for lc and asg as suffix; for rds and elasticache `Name` tag. Should be in kebab-case."
  default     = "airflow" # kebab-case, with dashes
}

locals {
  rds_name = join("", split(" ", title(join(" ", split("-", var.name))))) # it converts kebab-case to PascalCase
}

variable "region" {
  type        = string
  description = "Region, where Airflow should be spinned up."
  default     = "eu-central-1"
}

variable "vpc_id" {
  type        = string
  description = "ID of VPC, where rds, elasticache, alb and ecs cluster will reside."
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "The VPC's private Subnet IDs, where rds, elasticache, alb and ecs cluster will reside."
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the resources in the module."
  default     = {}
}

variable "certificate_domain_name" {
  type        = string
  description = "'Domain_name' by which to search for certificate."
}

variable "dns_zone_id" {
  type        = string
  description = "Route53 hosted zone id. Belongs to a DNS zone where AirFlow should reside."
}

variable "airflow_home" {
  type        = string
  description = "A folder on container instance, where dags reside."
  default     = "/home/ec2-user/airflow"
}

# Env variables for airflow.cfg
variable "airflow_core_logging_level" {
  type        = string
  description = "Webserver logging level."
  default     = "INFO"
}

variable "airflow_webserver_rbac" {
  type        = string
  description = "Turns on/off RBAC authentication on webserver. Only enabled when set to 'True'."
  default     = "False" # Only enabled when set to "True"
}

variable "load_example_dags" {
  type        = string
  description = "Whether to load the DAG examples that ship with Airflow. It’s good to get started, but you probably want to set this to False in a production environment."
  default     = "n"
}

variable "airflow_core_dag_concurrency" {
  type        = string
  description = "The number of task instances allowed to run concurrently by the scheduler."
  default     = "32"
}

variable "airflow_core_worker_concurrency" {
  type        = string
  description = "The concurrency that will be used when starting workers with the airflow celery worker command. This defines the number of task instances that a worker will take, so size up your workers based on the resources on your worker box and the nature of your tasks."
  default     = "32"
}

variable "airflow_core_load_default_connections" {
  type        = string
  description = "Whether to load the default connections that ship with Airflow. It’s good to get started, but you probably want to set this to False in a production environment."
  default     = "False"
}

variable "airflow_webserver_dag_orientation" {
  type        = string
  description = "Default DAG orientation. Valid values are: LR (Left->Right), TB (Top->Bottom), RL (Right->Left), BT (Bottom->Top)."
  default     = "TB"
}

variable "airflow_scheduler_dag_dir_list_interval" {
  type        = string
  description = "How often (in seconds) to scan the DAGs directory for new files."
  default     = "180"
}

variable "airflow_smtp_host" {
  type        = string
  description = "If you want airflow to send emails on retries, failure, and you want to use the airflow.utils.email.send_email_smtp function, you have to configure an smtp server here."
  default     = "localhost"
}

variable "airflow_smtp_port" {
  type        = string
  description = "If you want airflow to send emails on retries, failure, and you want to use the airflow.utils.email.send_email_smtp function, you have to configure an smtp server here."
  default     = "25"
}

variable "airflow_smtp_user" {
  type        = string
  description = "If you want airflow to send emails on retries, failure, and you want to use the airflow.utils.email.send_email_smtp function, you have to configure an smtp server here."
  default     = "None"
}

variable "airflow_smtp_password" {
  type        = string
  description = "If you want airflow to send emails on retries, failure, and you want to use the airflow.utils.email.send_email_smtp function, you have to configure an smtp server here."
  default     = "None"
}

variable "airflow_smtp_mail_from" {
  type        = string
  description = "If you want airflow to send emails on retries, failure, and you want to use the airflow.utils.email.send_email_smtp function, you have to configure an smtp server here."
  default     = "airflow@example.com"
}

### secrets
variable "airflow_image" {
  type        = string
  description = "Docker image name to use in the task definition `templates/airflow.json`."
  default     = "puckel/docker-airflow:1.10.9"
}

variable "rclone_secret_key" {
  type        = string
  description = "A key used to copy DAGs from the bucket to container instance."
}

variable "airflow_fernet_key" {
  type        = string
  description = "A key used to encrypt connection's passwords in AF metadata database."
}

### user_data
variable "rclone_secret_key_id" {
  type        = string
  description = "A key_id used to copy DAGs from the bucket to container instance."
}

variable "dag_s3_bucket" {
  type        = string
  description = "A bucket where DAGs are stored."
}

variable "dag_s3_key" {
  type        = string
  description = "A path to folder in the bucket where DAGs are stored."
}

variable "requirements_s3_key" {
  type        = string
  description = "A path to folder in the bucket where requirements file is stored."
}

variable "custom_user_data" {
  type        = string
  description = "user_data extention for container instance. This is used only in case of EC2 ECS launch type."
  default     = ""
}

### RDS
variable "rds_storage" {
  type        = string
  description = "Storage for airflow docker rds instance in gb."
  default     = "100"
}

variable "rds_instance_class" {
  type        = string
  description = "Cpu / memory class of the rds instance for docker airflow."
  default     = "db.t2.micro"
}

variable "rds_username" {
  type        = string
  description = "Database username for postgres."
  default     = "airflowdocker"
}

variable "rds_password" {
  type        = string
  description = "Database password for postgres."
}

variable "skip_final_snapshot" {
  type        = bool
  description = "If true, the final snapshot creation will be skipped when db is destroyed."
  default     = false
}

variable "rds_engine_version" {
  type        = string
  description = "The db engine version to use. auto_minor_version_upgrade is disabled"
  default     = "10.15"
}

### elasticache

variable "elasticache_node_type" {
  type        = string
  description = "Type of nodes to be used for elasticache cluster."
  default     = "cache.t2.micro"
}

### alb
variable "lb_security_group_ids" {
  type        = list(any)
  description = "A list of security group IDs to associate with Load Balancer."
}

variable "lb_idle_timeout" {
  type        = string
  description = "The time in seconds that the connection is allowed to be idle."
  default     = 600
}

variable "lb_target_container_name" {
  type        = string
  description = "Container name to point loadbalancer to."
  default     = "webserver"
}

variable "lb_target_container_port" {
  type        = string
  description = "Port opened on webserver container. For loadbalancer to connect to."
  default     = "8080"
}

variable "alb_access_logs_bucket" {
  type        = string
  description = "An s3 bucket, where to store logs from alb."
}

### ecs_service
variable "ecs_launch_type" {
  type        = string
  description = "Launch type for ECS cluster instances (EC2 or FARGATE)."
  default     = "EC2"
}

variable "cloudwatch_retention" {
  type        = string
  description = "Retention for container logs delivered to cloudwatch."
  default     = "7"
}

### launch_configuration
variable "key_name" {
  type        = string
  description = "EC2 Instance key."
}

variable "ecs_ami_id" {
  type        = string
  description = "ECS container instance ami."
  default     = "ami-0e781777db20a4f7f"
}

variable "ecs_instance_type" {
  type        = string
  description = "ECS container instance type."
  default     = "t3.small"
}

variable "container_instance_sg_ids" {
  type        = list(string)
  description = "List of additional security groups for container instances (eg. enable ssh)."
  default     = []
}

### webserver task_definition
variable "webserver_task_definition_memory" {
  type        = string
  description = "Desired task definition memory."
  default     = 900
}

variable "webserver_task_definition_cpu" {
  type        = string
  description = "Desired task definition cpu."
  default     = 512
}

variable "webserver_task_definition_network_mode" {
  default = "awsvpc"
}

### scheduler task_definition
variable "scheduler_task_definition_memory" {
  type        = string
  description = "Desired task definition memory."
  default     = 1024
}

variable "scheduler_task_definition_cpu" {
  type        = string
  description = "Desired task definition cpu."
  default     = 512
}

variable "scheduler_task_definition_network_mode" {
  default = "awsvpc"
}

### worker task_definition
variable "worker_task_definition_memory" {
  type        = string
  description = "Desired task definition memory."
  default     = 1024
}

variable "worker_task_definition_cpu" {
  type        = string
  description = "Desired task definition cpu."
  default     = 512
}

variable "worker_task_definition_network_mode" {
  default = "awsvpc"
}