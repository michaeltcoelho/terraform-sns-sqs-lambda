terraform {
  required_version = ">= 0.11"
}

resource "aws_sqs_queue" "sqs_queue" {
  name = "${var.sqs_queue_name}"
  visibility_timeout_seconds = 50
  message_retention_seconds = 345600 # 4 days
  receive_wait_time_seconds = 5
  redrive_policy = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.sqs_dead_letter_queue.arn}\",\"maxReceiveCount\":4}"
}

resource "aws_sqs_queue" "sqs_dead_letter_queue" {
  name  = "dead-letter-${var.sqs_queue_name}"
  message_retention_seconds = 691200 # 8 days
}

resource "aws_sqs_queue_policy" "sqs_queue_policy_for_sns_subscription" {
  queue_url = "${aws_sqs_queue.sqs_queue.id}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "SNSSQSQueuePolicyID",
  "Statement": [
    {
      "Sid": "SNSSQSQueuePolicySID",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "sqs:SendMessage",
      "Resource": "${aws_sqs_queue.sqs_queue.arn}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${var.sns_topic_arn}"
        }
      }
    }
  ]
}
POLICY
}
