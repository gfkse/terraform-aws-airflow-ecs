#### Education environment (easiest to start)
Default variable values are configured to get the cluster up and
running as easy as possible. 

#### Development environment
No special recommendations

#### Production environment
When using the module in production environment we recommend to take closer look at
values of following variables:
1. rds_instance_class
2. webserver_task_definition_memory
3. webserver_task_definition_cpu
4. scheduler_task_definition_memory
5. scheduler_task_definition_cpu
6. worker_task_definition_memory
7. worker_task_definition_cpu
