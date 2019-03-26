terraform {
  required_version = ">= 0.11"
}

resource "aws_lambda_function" "lambda_function" {
  vpc_config {
    subnet_ids = "${var.subnets_ids}"
    security_group_ids = "${var.security_groups_ids}"
  }

  filename = "${var.filename}"
  function_name = "${var.function_name}"
  handler = "${var.function_entrypoint}"
  source_code_hash = "${base64sha25((var.filename))}"
  runtime = "${var.function_runtime}"
  memory_size = "${var.function_memory_size}"
  tags = "${var.function_tags}"
  publish = true
}

resource "aws_iam_role" "lambda_function_sqs_role" {
  name = "${var.function_name}-sqs-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Id": "LambdaFunctionSQSRole",
  "Statement": [
    {
      "Sid": "LambdadFunctionSQSRoleSid",
      "Action": [
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes",
      ],
      "Resource": "${aws_lambda_function.lambda_function.arn}",
      "Effect": "Allow"
    }
  ]
}
EOF
}
