data "aws_cloudwatch_log_group" "this" {
  name = var.log_group_name
}

data "aws_region" "current" {
}

resource "aws_lambda_permission" "this" {
  statement_id  = "AllowCloudWatchToExecute-${var.subscription_name}"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_arn
  principal     = "logs.${data.aws_region.current.name}.amazonaws.com"
  source_arn    = data.aws_cloudwatch_log_group.this.arn
}

resource "aws_cloudwatch_log_subscription_filter" "this" {
  name            = var.subscription_name
  log_group_name  = var.log_group_name
  filter_pattern  = var.filter_pattern
  destination_arn = var.lambda_function_arn

  depends_on = [aws_lambda_permission.this]
}

