# Define Lambda function
resource "aws_lambda_function" "notifications_lambda" {
  filename         = "../../lambdas/healthcheck.py"  # Path to your Lambda function code
  function_name    = "health-check-notifications"
  handler          = "healthcheck.handler"
  runtime          = "python3.7"
  role             = iam.aws_iam_role.notifications_lambda_role.arn  # Assuming you have an IAM role defined
  source_code_hash = filebase64sha256("../../lambdas/healthcheck.py")  # Calculating source code hash
  environment {
    variables = {
      NOTIFICATION_EMAIL = var.notification_email
      SLACK_WEBHOOK_URL = var.slack_webhook_url  # Pass Slack webhook URL as environment variable
      TEAMS_WEBHOOK_URL = var.teams_webhook_url  # Pass Teams webhook URL as environment variable
    }
  }
    lifecycle {
    ignore_changes = [source_code_hash, last_modified]
  }
}

resource "aws_lambda_permission" "lambda_permission" {
  count         = local.lambda_alerts_enabled ? 1 : 0
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.notifications_lambda[0].function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.alarm_sns_topic.arn
}
