
output "lambda_arn" {
  value = "${element(concat(aws_lambda_function.lambda_function.*.qualified_arn, aws_lambda_function.lambda_function_with_vpc.*.qualified_arn, aws_lambda_function.lambda_function_with_dead_letter_queue.*.qualified_arn, aws_lambda_function.lambda_function_with_dead_letter_queue_and_vpc.*.qualified_arn), 0)}"
}
