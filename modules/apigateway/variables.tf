
variable "rest_api_id" {
  description = "The ID of the associted REST API"
}

variable "resource_id" {
  description = "The API resource ID"
}

variable "http_method" {
  description = "The HTTP method (GET, POST, PUT, DELETE, HEAD, OPTIONS, ANY)"
}

variable "resource_path" {
  description = "The resource's url path"
  default = ""
}

variable "inject_request_parameters" {
  description = "A map of request query string parameters and headers that should be passed to the integration"
  default = {}
}

variable "lambda_integration_enabled" {
  description = "Enable lambda integration to the method"
  default = false
}

variable "lambda_integration_arn" {
  description = "The Lambda ARN to be integrated"
  default = ""
}

variable "rest_api_execution_arn" {
  description = "The REST API's execution ARN"
  default = ""
}
