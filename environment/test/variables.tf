variable "environment" {}

variable "application" {}

### Accesss key rotation variables
variable "target_id" {
  default = "Lambda"
}

variable "handler" {
  default = "lambda_function.lambda_handler"
}

variable "runtime" {
  default = "python3.8"
}

variable "emails_list" {}

variable "schedule_expression" {}

variable "principal" {}
###