variable "cloudwatch_event_rule_name" {}

variable "target_arn" {}

variable "target_id" {
    default = "SNS"
}