#### RBAC Authentication
If you enabled RBAC with `var.airflow_webserver_rbac` - run the following command in
webserver container to configure the dummy user:
```bash
airflow create_user -r Admin -u admin -e admin@example.com -f admin -l user -p admin
```
After this is done you could create more users in webserver UI and remove the dummy
one.

#### RBAC with Fargate launch type
When Fargate mode is used it is no longer possible to ssh to EC2 instance and connect
to container. So you either need to run the cluster in EC2 mode first and create the
user with approach described above and the switch to Fargate. Or use custom docker
image and add following bash scrip to the `entrypoint.sh` file, right after `airflow
initdb`. 
```bash
#create default user if no users with admin role exists
if  airflow list_users 2>/dev/null | grep -q "Admin" ; then
   echo "User with admin role already exists."
else
     echo "Creating Airflow Admin User.."  && airflow create_user -r Admin -u "admin" -p "admin" -f "Default" -l "User" -e "defaultuser@airflow.com"
 fi
```