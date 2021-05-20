resource "aws_iam_role" "lambda" {
  count = var.assume_role_services_count <= 0 ? 1 : 0
  name  = var.lambda_name

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

resource "aws_iam_role" "lambda_extra" {
  count = var.assume_role_services_count > 0 ? 1 : 0
  name  = var.lambda_name

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["${join("\",\"", var.assume_role_services_list)}"]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

resource "aws_iam_role_policy" "lambda" {
  name = var.lambda_name
  role = element(
    concat(aws_iam_role.lambda.*.name, aws_iam_role.lambda_extra.*.name),
    0,
  )
  policy = var.iam_policy_document
}

resource "aws_lambda_function" "lambda" {
  runtime       = var.runtime
  filename      = var.lambda_zipfile
  function_name = var.lambda_name
  role = element(
    concat(aws_iam_role.lambda.*.arn, aws_iam_role.lambda_extra.*.arn),
    0,
  )
  handler                        = var.handler
  source_code_hash               = filebase64sha256(var.lambda_zipfile)
  count                          = var.enabled == true ? 1 : 0
  timeout                        = var.timeout
  reserved_concurrent_executions = var.reserved_concurrent_executions

  # vpc_config {
  #   subnet_ids = split(
  #     ",",
  #     var.create_in_vpc == "1" ? join(",", var.subnet_ids) : join(",", [""]),
  #   )
  #   security_group_ids = split(
  #     ",",
  #     var.create_in_vpc == "1" ? join(",", var.security_group_ids) : join(",", [""]),
  #   )
  # }

  environment {
    variables = var.environment_variables
  }
}

resource "aws_lambda_permission" "cloudwatch" {
  count         = var.schedule
  statement_id  = "AllowExecutionFromCloudWatch-${var.lambda_name}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda[0].arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.lambda[0].arn
}

resource "aws_cloudwatch_event_rule" "lambda" {
  count               = var.schedule
  name                = var.lambda_name
  schedule_expression = var.schedule_expression
}

resource "aws_cloudwatch_event_target" "lambda" {
  count     = var.schedule
  target_id = "${var.lambda_name}-target"
  rule      = aws_cloudwatch_event_rule.lambda[0].name
  arn       = aws_lambda_function.lambda[0].arn
  input     = var.input
}

resource "aws_lambda_event_source_mapping" "source_mapping" {
  count             = var.create_event_source_mapping
  batch_size        = var.event_source_mapping_batch_size
  enabled           = true
  event_source_arn  = var.event_source_mapping_event_arn
  function_name     = aws_lambda_function.lambda[0].arn
  starting_position = var.event_source_mapping_starting_position
}

resource "aws_lambda_event_source_mapping" "source_mapping_sqs" {
  count            = var.create_event_source_mapping_sqs
  batch_size       = var.event_source_mapping_batch_size
  enabled          = true
  event_source_arn = var.event_source_mapping_event_arn
  function_name    = aws_lambda_function.lambda[0].arn
}

