output "sqs_queue_arn" {
  value = "${aws_sqs_queue.sqs_queue.arn}"
}

output "sqs_dead_letter_queue_arn" {
  value = "${aws_sqs_queue.sqs_dead_letter_queue.arn}"
}
