variable "bucket_id" {
}

variable "lambda_function_arn" {
}

variable "s3_event" {
  type    = list(any)
  default = ["s3:ObjectCreated:*"]
}

variable "filter_prefix" {
  default = ""
}

variable "filter_suffix" {
  default = ""
}

