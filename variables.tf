### general
variable "name" {
  type        = string
  description = "Used for ecs cluster and service names as prefix; for lc and asg as suffix; for rds and elasticache `Name` tag. Should be in kebab-case."
  default     = "airflow" # kebab-case, with dashes
}

locals {
  rds_name = join("", split(" ", title(join(" ", split("-", var.name)))))  # it converts kebab-case to PascalCase
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

variable "airflow_core_logging_level" {
  type        = string
  description = "Webserver logging level."
  default     = "INFO"
}

### secrets
variable "airflow_image_version" {
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

variable "custom_user_data" {
  type        = string
  description = "user_data extention for container instance."
  default     = ""
}

### RDS
variable "rds_security_group_ids" {
  type        = list(string)
  description = "A list of security group IDs to associate with."
}

variable "rds_airflow_docker_storage" {
  type        = string
  description = "Storage for airflow docker rds instance in gb."
  default     = "100"
}

variable "rds_airflow_docker_instance_class" {
  type        = string
  description = "Cpu / memory class of the rds instance for docker airflow."
  default     = "db.t2.micro"
}

variable "rds_airflow_docker_username" {
  type        = string
  description = "Database username for postgres."
  default     = "airflowdocker"
}

variable "rds_airflow_docker_password" {
  type        = string
  description = "Database password for postgres."
}

### elasticache

variable "elasticache_airflow_docker_node_type" {
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
variable "ecs_airflow_docker_security_group_id" {
  type        = list(any)
  description = "SG for ecs task_defition (elastic network interface)."
}

variable "ecs_airflow_docker_desired_count" {
  type        = string
  description = "Desired number of tasks, either 0 or 1."
  default     = "1"
}

### launch_configuration
variable "key_name" {
  type        = string
  description = "EC2 Instance key."
}

variable "ebs_block_device_name" {
  type        = string
  description = "Block device for container instance name."
  default     = "/dev/xvdcz"
}

variable "ebs_block_device_volume_size" {
  type        = string
  description = "Block device for container instance volume size."
  default     = 25
}

variable "ebs_block_device_volume_type" {
  type        = string
  description = "Block device for container instance volume type."
  default     = "gp2"
}

variable "ebs_block_device_delete_on_termination" {
  type        = bool
  description = "Block device for container instance deletion policy."
  default     = true
}

variable "ecs_airflow_docker_ami_id" {
  type        = string
  description = "ECS container instance ami."
  default     = "ami-08c1d0b4f39f110d4"
}

variable "ecs_airflow_docker_instance_type" {
  type        = string
  description = "ECS container instance type."
  default     = "t2.medium"
}

### task_definition
variable "task_definition_family" {
  type        = string
  default     = "airflow"
}

variable "task_definition_memory" {
  type        = string
  description = "Desired task definition memory."
  default     = 2048
}

variable "task_definition_cpu" {
  type        = string
  description = "Desired task definition cpu."
  default     = 1024
}

variable "task_definition_network_mode" {
  default     = "awsvpc"
}
