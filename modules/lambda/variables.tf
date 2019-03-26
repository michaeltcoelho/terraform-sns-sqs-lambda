variable "filename" {
  description = "The path to the function's deployment package locally"
}

variable "function_name" {
  description = "A unique name for your Lambda Function"
}

variable "function_entrypoint" {
  description = "The function entrypoint in your code"
}

variable "function_runtime" {
  description = "Your function runtime"
}

variable "function_memory_size" {
  description = "The amount of memory in MB your function ca use at runtime"
}

variable "subnets_ids" {
  description = "A list of subnet IDS to be associated to the function"  
}

variable "security_groups_ids" {
  description = "A list of security groups IDS to be associted to the function"
}

variable "tags" {
  description = "A map of tags to be assigned to the function"  
}
