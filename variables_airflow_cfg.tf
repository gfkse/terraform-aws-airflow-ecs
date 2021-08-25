# Env variables for airflow.cfg
variable "airflow_core_logging_level" {
  type        = string
  description = "Webserver logging level."
  default     = "INFO"
}

variable "airflow_core_load_example_dags" {
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

variable "airflow_scheduler_dag_dir_list_interval" {
  type        = string
  description = "How often (in seconds) to scan the DAGs directory for new files."
  default     = "180"
}

variable "airflow_smtp_smtp_host" {
  type        = string
  description = "If you want airflow to send emails on retries, failure, and you want to use the airflow.utils.email.send_email_smtp function, you have to configure an smtp server here."
  default     = "localhost"
}

variable "airflow_smtp_smtp_starttls" {
  type = string
  description = "SMTP configuration: Inform the email server to use secure connection"
  default = "True"
}

variable "airflow_smtp_smtp_smtp_ssl" {
  type = string
  description = "SMTP configuration: Use SSL"
  default = "False"
}

variable "airflow_smtp_smtp_port" {
  type        = string
  description = "If you want airflow to send emails on retries, failure, and you want to use the airflow.utils.email.send_email_smtp function, you have to configure an smtp server here."
  default     = "25"
}

variable "airflow_smtp_smtp_user" {
  type        = string
  description = "If you want airflow to send emails on retries, failure, and you want to use the airflow.utils.email.send_email_smtp function, you have to configure an smtp server here."
  default     = "None"
}

variable "airflow_smtp_smtp_password" {
  type        = string
  description = "If you want airflow to send emails on retries, failure, and you want to use the airflow.utils.email.send_email_smtp function, you have to configure an smtp server here."
  default     = "None"
}

variable "airflow_smtp_smtp_mail_from" {
  type        = string
  description = "If you want airflow to send emails on retries, failure, and you want to use the airflow.utils.email.send_email_smtp function, you have to configure an smtp server here."
  default     = "airflow@example.com"
}

variable "airflow_webserver_dag_orientation" {
  type        = string
  description = "Default DAG orientation. Valid values are: LR (Left->Right), TB (Top->Bottom), RL (Right->Left), BT (Bottom->Top)."
  default     = "TB"
}

variable "airflow_webserver_rbac" {
  type        = string
  description = "Turns on/off RBAC authentication on webserver. Only enabled when set to 'True'."
  default     = "False"
}