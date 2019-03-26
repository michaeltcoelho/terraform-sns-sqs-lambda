terraform {
  required_version = ">= 0.11"
}

data "aws_region" "current" {}

resource "aws_lambda_function" "lambda_function" {
  count = "${!var.vpc_config_enabled && ! var.dead_letter_queue_config_enabled ? 1 : 0}"

  filename = "${var.function_filename}"
  function_name = "${var.function_name}"
  description = "${var.function_description}"
  handler = "${var.function_entrypoint}"
  source_code_hash = "${base64sha256(file(var.function_filename))}"
  runtime = "${var.function_runtime}"
  memory_size = "${var.function_memory_size}"
  tags = "${var.tags}"
  publish = true
  role = "${aws_iam_role.lambda_function_role.arn}"
}

resource "aws_lambda_function" "lambda_function_with_dead_letter_queue" {
  count = "${var.dead_letter_queue_config_enabled && ! var.vpc_config_enabled ? 1 : 0}"

  dead_letter_config {
    target_arn = "${var.dead_letter_queue_config["target_arn"]}"
  }

  filename = "${var.function_filename}"
  function_name = "${var.function_name}"
  handler = "${var.function_entrypoint}"
  source_code_hash = "${base64sha256(file(var.function_filename))}"
  runtime = "${var.function_runtime}"
  memory_size = "${var.function_memory_size}"
  tags = "${var.tags}"
  publish = true
  role = "${aws_iam_role.lambda_function_role.arn}"
}

resource "aws_lambda_function" "lambda_function_with_vpc" {
  count = "${var.vpc_config_enabled && ! var.dead_letter_queue_config_enabled ? 1 : 0}"

  vpc_config {
    subnet_ids = ["${var.vpc_config["subnet_ids"]}"]
    security_group_ids = ["${var.vpc_config["security_group_ids"]}"]
  }

  filename = "${var.function_filename}"
  function_name = "${var.function_name}"
  handler = "${var.function_entrypoint}"
  source_code_hash = "${base64sha256(file(var.function_filename))}"
  runtime = "${var.function_runtime}"
  memory_size = "${var.function_memory_size}"
  tags = "${var.tags}"
  publish = true
  role = "${aws_iam_role.lambda_function_role.arn}"
}

resource "aws_lambda_function" "lambda_function_with_dead_letter_queue_and_vpc" {
  count = "${var.vpc_config_enabled && var.dead_letter_queue_config_enabled ? 1 : 0}"

  vpc_config {
    subnet_ids = ["${var.vpc_config["subnet_ids"]}"]
    security_group_ids = ["${var.vpc_config["security_group_ids"]}"]
  }

  dead_letter_config {
    target_arn = "${var.dead_letter_queue_config["target_arn"]}"
  }

  filename = "${var.function_filename}"
  function_name = "${var.function_name}"
  handler = "${var.function_entrypoint}"
  source_code_hash = "${base64sha25((var.function_filename))}"
  runtime = "${var.function_runtime}"
  memory_size = "${var.function_memory_size}"
  tags = "${var.tags}"
  publish = true
  role = "${aws_iam_role.lambda_function_role.arn}"
}

resource "aws_lambda_event_source_mapping" "map_lambda_function_to_sqs_queue" {
  count = "${var.sqs_event_source_enabled && !var.vpc_config_enabled && ! var.dead_letter_queue_config_enabled ? 1 : 0}"

  batch_size = "${var.sqs_event_source_batch_size}"
  event_source_arn = "${var.sqs_event_source_arn}"
  enabled = "${var.sqs_event_source_enabled}"
  function_name = "${aws_lambda_function.lambda_function.arn}"
}

resource "aws_lambda_event_source_mapping" "map_lambda_function_with_dl_to_sqs_queue" {
  count = "${var.sqs_event_source_enabled && var.dead_letter_queue_config_enabled && ! var.vpc_config_enabled ? 1 : 0}"

  batch_size = "${var.sqs_event_source_batch_size}"
  event_source_arn = "${var.sqs_event_source_arn}"
  enabled = "${var.sqs_event_source_enabled}"
  function_name = "${aws_lambda_function.lambda_function_with_dead_letter_queue.arn}"
}

resource "aws_lambda_event_source_mapping" "map_lambda_function_with_vpc_to_sqs_queue" {
  count = "${var.sqs_event_source_enabled && var.vpc_config_enabled && ! var.dead_letter_queue_config_enabled ? 1 : 0}"

  batch_size = "${var.sqs_event_source_batch_size}"
  event_source_arn = "${var.sqs_event_source_arn}"
  enabled = "${var.sqs_event_source_enabled}"
  function_name = "${aws_lambda_function.lambda_function_with_vpc.arn}"
}

resource "aws_lambda_event_source_mapping" "map_lambda_function_with_dl_and_vpc_to_sqs_queue" {
  count = "${var.sqs_event_source_enabled && var.vpc_config_enabled && var.dead_letter_queue_config_enabled ? 1 : 0}"

  batch_size = "${var.sqs_event_source_batch_size}"
  event_source_arn = "${var.sqs_event_source_arn}"
  enabled = "${var.sqs_event_source_enabled}"
  function_name = "${aws_lambda_function.lambda_function_with_dead_letter_queue_and_vpc.arn}"
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_function_role" {
  name = "${var.function_name}"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role_policy.json}"
}

data "aws_iam_policy_document" "lambda_function_policy" {
  statement {
    sid       = "AllowSQSPermissions"
    effect    = "Allow"
    resources = ["${compact(list(var.sqs_event_source_arn, var.dead_letter_queue_config["target_arn"]))}"]
    actions = [
      "sqs:ChangeMessageVisibility",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:ReceiveMessage",
      "sqs:SendMessage",
    ]
  }

  statement {
    sid       = "AllowInvokingLambdas"
    effect    = "Allow"
    resources = ["arn:aws:lambda:${data.aws_region.current.name}:*:function:*"]
    actions   = ["lambda:InvokeFunction"]
  }

  statement {
    sid       = "AllowCreatingLogGroups"
    effect    = "Allow"
    resources = ["arn:aws:logs:${data.aws_region.current.name}:*:*"]
    actions   = ["logs:CreateLogGroup"]
  }

  statement {
    sid       = "AllowWritingLogs"
    effect    = "Allow"
    resources = ["arn:aws:logs:${data.aws_region.current.name}:*:log-group:/aws/lambda/*:*"]
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
  }

  statement {
    sid       = "AllowAccessResourceInVPC"
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
    ]
  }
}

resource "aws_iam_policy" "lambda_function_policy_streams" {
  name = "${var.function_name}-policy"
  policy = "${data.aws_iam_policy_document.lambda_function_policy.json}"
}

resource "aws_iam_role_policy_attachment" "lambda_function_policy_streams" {
  policy_arn = "${aws_iam_policy.lambda_function_policy_streams.arn}"
  role = "${aws_iam_role.lambda_function_role.name}"
}