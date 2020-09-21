#!/bin/bash

echo "ECS_CLUSTER=${cluster_name}" >> /etc/ecs/ecs.config

mkdir -p '/home/ec2-user/airflow/dags'
mkdir -p '/home/ec2-user/airflow/logs'
# TODO(jakub.berezowski): 777 is not a best solution, but how detect the uid and username at runtime?
chmod 777 '/home/ec2-user/airflow/logs'
chown -R ec2-user:ec2-user '/home/ec2-user/airflow'

sudo yum -y install unzip curl
curl https://rclone.org/install.sh | sudo bash

# checksum below should be ignored because rclone uses MD5 to calculate it,
# but when DAG bucket is encrypted aws uses some other algorithm and
# due to this integrity check fails without `--ignore-checksum`
echo '*/2 * * * * ec2-user /usr/bin/rclone --ignore-checksum sync s3:${dag_s3_bucket}/${dag_s3_key}/ /home/ec2-user/airflow/dags/' > /etc/cron.d/airflowdags

# every day at 3:00 compress the logs which are older than one day
echo "0 3 * * * ec2-user sudo find /home/ec2-user/airflow/logs/scheduler/ -type f -iname '*.log' -mtime +1 -ls -and -exec gzip -9 -f '{}' \;" > /etc/cron.d/compress_scheduler_logs
# every day at 4:00 delete compressed logs older than 90 days
echo "0 4 * * * ec2-user sudo find /home/ec2-user/airflow/logs/scheduler/ -type f -iname '*.log.gz' -mtime +90 -ls -and -delete" > /etc/cron.d/delete_scheduler_logs

mkdir -p /home/ec2-user/.config/rclone/

cat << EOT >> '/home/ec2-user/.config/rclone/rclone.conf'
[s3]
type = s3
provider = AWS
env_auth = false
access_key_id = ${rclone_secret_key_id}
secret_access_key = ${rclone_secret_key}
region = ${region}
location_constraint = EU
EOT

${custom_user_data}