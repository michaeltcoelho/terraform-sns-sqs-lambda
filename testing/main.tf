
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
