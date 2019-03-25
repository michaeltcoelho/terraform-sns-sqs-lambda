
provider "aws" {
  profile = "personal"
  region = "sa-east-1"
}

module "sns" {
  source = "../modules/sns"
  sns_topic_name = "topic-name"
  sqs_queue_arn = ""
}
