#### Logging level
If you want to see more logs from AF webserver in CloudWatch, use following variable
`airflow_core_logging_level`.

#### Persisting logs
There are multiple log types produced by the module. First of all, containers are
writing logs to standard output and those logs are delivered to [CloudWatch log
group](../cloudwatch.tf). We decided not to send all the logs to standard output, in
order to avoid a mess there. So logs from `$AIRFLOW_HOME/logs` are mounted to EFS.
The idea behind it is that these volumes can be mounted to a container with any log
management system agent. This agent can then deliver them to centralized solution like ELK
or Datadog.

On the picture below you can see that logs from worker and webserver containers are
delivered to the same location on EFS. This is done to enable webserver to
retrieve worker (DAG) logs without using worker API. This approach was empirically
more reliable.

![Airflow components schema](./module_architecture.png)
