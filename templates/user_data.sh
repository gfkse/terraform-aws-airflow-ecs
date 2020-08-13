#!/bin/bash

echo "ECS_CLUSTER=${cluster_name}" >> /etc/ecs/ecs.config

sudo yum -y install unzip curl
curl https://rclone.org/install.sh | sudo bash

# checksum below should be ignored because rclone uses MD5 to calculate it,
# but when DAG bucket is encrypted aws uses some other algorithm and
# due to this integrity check fails without `--ignore-checksum`
echo '*/2 * * * * ec2-user /usr/bin/rclone --ignore-checksum sync s3:${dag_s3_bucket}/${dag_s3_key}/ /home/ec2-user/airflow/dags/' > /etc/cron.d/airflowdags
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