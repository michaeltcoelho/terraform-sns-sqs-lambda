variable "function_filename" {
  type = "string"
  description = "The path to the function's deployment package locally"
}
variable "function_name" {
  type = "string"
  description = "A unique name for your Lambda Function"
}

variable "function_description" {
 type = "string"
 description = "A description for you lambda function" 
}

variable "function_entrypoint" {
  type = "string"
  description = "The function entrypoint in your code"
}

variable "function_runtime" {
  type = "string"
  description = "Your function runtime"
}

variable "function_memory_size" {
  type = "string"
  description = "The amount of memory in MB your function ca use at runtime"
}

variable "vpc_config_enabled" {
  description = "Would you like to run this function in a VPC?"
  default = false
}

variable "vpc_config" {
  type = "map"
  description = "VPC subnets_ids and security_groups_ids configurations"
  default = {}
}

variable "dead_letter_queue_config_enabled" {
  description = "Would you like to attach a Dead Letter Queue to the function?"
  default = false
}
variable "dead_letter_queue_config" {
  type = "map"
  description = "Dead Letter Queue target_arn configuration"
  default = {
    "target_arn" = ""
  }
}

variable "sqs_event_source_enabled" {
  description = "Would you like to enable an SQS event source to the function"
  default = false
}

variable "sqs_event_source_arn" {
  type = "string"
  description = "The function event source SQS ARN"
}

variable "sqs_event_source_batch_size" {
  description = "The largest number of records the function will retrieve from SQS event source at a time"
  default = 10
}

variable "tags" {
  type = "map"
  description = "A map of tags to be assigned to the function"  
  default = {}
}
