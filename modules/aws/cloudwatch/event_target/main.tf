resource "aws_cloudwatch_event_target" "target" {
  rule      = var.cloudwatch_event_rule_name
  target_id = var.target_id
  arn       = var.target_arn
}