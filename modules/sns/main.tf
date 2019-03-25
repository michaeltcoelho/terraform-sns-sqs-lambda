
terraform {
  required_version = ">= 0.11"
}

resource "aws_sns_topic" "sns_topic" {
  name = "${var.sns_topic_name}"
}

resource "aws_sns_topic_subscription" "sns_topic_sqs_subscription" {
  topic_arn = "${aws_sns_topic.sns_topic.arn}"
  protocol = "sqs"
  endpoint = "${var.sqs_queue_arn.arn}"
}
