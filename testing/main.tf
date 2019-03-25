
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
