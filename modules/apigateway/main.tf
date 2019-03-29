terraform {
  required_version = ">= 0.11"
}

data "aws_region" "current" {}

resource "aws_api_gateway_method" "request_method" {
  rest_api_id = "${var.rest_api_id}"
  resource_id = "${var.resource_id}"
  http_method = "${var.http_method}"
  authorization = "NONE"
  request_parameters = "${var.inject_request_parameters}"
}

resource "aws_api_gateway_integration" "integration" {
  count = "${var.lambda_integration_enabled ? 1 : 0}"

  rest_api_id = "${var.rest_api_id}"
  resource_id = "${var.resource_id}"
  http_method = "${aws_api_gateway_method.request_method.http_method}"

  # AWS lambda can only be invoked with POST http method
  integration_http_method = "POST"

  type  = "AWS_PROXY"
  uri = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${var.lambda_integration_arn}/invocations"
}

resource "aws_lambda_permission" "integration_permission" {
  count = "${var.lambda_integration_enabled ? 1 : 0}"

  function_name = "${var.lambda_integration_arn}"
  statement_id = "AllowExecutionFromAPIGateway"
  action = "lambda:InvokeFunction"
  principal = "apigateway.amazonaws.com"
  source_arn = "${var.rest_api_execution_arn}/*/${var.http_method}${var.resource_path}"
}