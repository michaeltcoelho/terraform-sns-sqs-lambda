
provider "aws" {
  profile = "personal"
  region = "sa-east-1"
}

module "sns" {
  source = "../modules/sns"
  sns_topic_name = "topic-name"
  sqs_queue_arn = "${module.sqs.sqs_queue_arn}"
}

module "sqs" {
  source = "../modules/sqs"
  sqs_queue_name = "queue-name"
  sns_topic_arn = "${module.sns.sns_topic_arn}"
}

module "lambda" {
  source = "../modules/lambda"

  function_name = "hello-function"
  function_description = "Testing the execution of a simple function"
  function_filename = "${path.module}/hello.zip"
  function_entrypoint = "hello"
  function_runtime = "go1.x"
  function_memory_size = 128

  sqs_event_source_enabled = true
  sqs_event_source_arn = "${module.sqs.sqs_queue_arn}"
  sqs_event_source_batch_size = 10

  tags = {
    "Name" = "My Lambda - Testing"
  }
}

resource "aws_api_gateway_rest_api" "hello_api" {
  name = "Hello API"
  description = "The Hello API description"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "hello_resource" {
  rest_api_id = "${aws_api_gateway_rest_api.hello_api.id}"
  parent_id = "${aws_api_gateway_rest_api.hello_api.root_resource_id}"
  path_part = "hello"
}

module "hello_get" {
  source = "../modules/apigateway"
  rest_api_id = "${aws_api_gateway_rest_api.hello_api.id}"
  resource_id = "${aws_api_gateway_resource.hello_resource.id}"
  http_method = "GET"
  inject_request_parameters = {
    "method.request.querystring.uhuuu" = true
  }

  lambda_integration_enabled = true
  lambda_integration_arn = "${module.lambda.lambda_arn}"

  rest_api_execution_arn = "${aws_api_gateway_rest_api.hello_api.execution_arn}"
  resource_path = "${aws_api_gateway_resource.hello_resource.path}"
}
