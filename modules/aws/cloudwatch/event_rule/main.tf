resource "aws_cloudwatch_event_rule" "compliance_change" {
  name                = var.name
  schedule_expression = var.schedule_expression != "" ? var.schedule_expression : ""
#   event_pattern = <<PATTERN
# {
#   "source": [
#     "aws.config"
#   ],
#   "detail-type": [
#     "Config Rules Compliance Change"
#   ],
#   "detail": {
#     "configRuleARN": [
#       "${var.config_rule_arn}"
#     ],
#     "newEvaluationResult": {
#             "complianceType": [
#                 "NON_COMPLIANT"
#             ]
#         }
#   }
# }
# PATTERN

  tags          = var.tags
}