output "cloudwatch_event_rule_name" {
  value = aws_cloudwatch_event_rule.compliance_change.name
}

output "arn" {
  value = aws_cloudwatch_event_rule.compliance_change.arn
}