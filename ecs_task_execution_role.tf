# TODO(ilya_isakov): this whole thing could probably be replaced by public ECS module

data "aws_iam_policy_document" "instance-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "airflow-task-definition-execution-role" {
  name               = "airflowTaskDefinitionExecutionRole"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.instance-assume-role-policy.json
}

resource "aws_iam_role_policy_attachment" "airflow-task-definition-execution-role-policy-attachment" {
  role       = aws_iam_role.airflow-task-definition-execution-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"  # it is aws managed policy with ugly name
}

resource "aws_iam_instance_profile" "airflow-task-definition-execution-profile" {
  name = "airflow-task-definition-execution-profile"
  role = aws_iam_role.airflow-task-definition-execution-role.name
}
