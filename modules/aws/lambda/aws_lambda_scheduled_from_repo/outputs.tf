output "lambda_arn" {
  value = aws_lambda_function.lambda[0].arn
}

output "log_group_name" {
  value = "/aws/lambda/${aws_lambda_function.lambda[0].function_name}"
}

output "role_arn" {
  value = element(
    concat(aws_iam_role.lambda.*.arn, aws_iam_role.lambda_extra.*.arn),
    0,
  )
}

output "role_name" {
  value = element(
    concat(aws_iam_role.lambda.*.name, aws_iam_role.lambda_extra.*.name),
    0,
  )
}

output "invoke_arn" {
  value = aws_lambda_function.lambda[0].invoke_arn
}

