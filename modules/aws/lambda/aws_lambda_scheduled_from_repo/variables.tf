variable "lambda_name" {
}

variable "runtime" {
}

variable "lambda_zipfile" {
}

variable "handler" {
}

variable "schedule_expression" {
  default = ""
}

variable "iam_policy_document" {
}

variable "enabled" {
  default = true
}

variable "timeout" {
  default = 3
}

#variable "repository_url" {}

variable "input" {
  default = "{}"
}

variable "schedule" {
  default = "1"
}

variable "create_event_source_mapping" {
  default = "0"
}

variable "event_source_mapping_batch_size" {
  default = 1
}

variable "event_source_mapping_event_arn" {
  default = ""
}

variable "event_source_mapping_starting_position" {
  default = ""
}

variable "create_in_vpc" {
  default = "0"
}

variable "security_group_ids" {
  type    = list(any)
  default = []
}

variable "subnet_ids" {
  type    = list(any)
  default = []
}

variable "environment_variables" {
  type = map(string)

  default = {
    "Default" = "GeneratedFromTerraform"
  }
}

variable "assume_role_services_list" {
  type    = list(any)
  default = []
}

variable "assume_role_services_count" {
  default = "0"
}

variable "reserved_concurrent_executions" {
  default = 0
}

variable "create_event_source_mapping_sqs" {
  default = "0"
}

