# Define Lambda function
resource "aws_lambda_function" "notifications_lambda" {
  filename         = "../../lambdas/healthcheck.py"  # Path to your Lambda function code
  function_name    = "health-check-notifications"
  handler          = "healthcheck.handler"
  runtime          = "python3.7"
  role             = aws_iam_role.notifications_lambda_role.arn  # Assuming you have an IAM role defined
  source_code_hash = filebase64sha256("../../lambdas/healthcheck.py")  # Calculating source code hash
  environment {
    variables = {
      NOTIFICATION_EMAIL = var.notification_email
      SLACK_WEBHOOK_URL = var.slack_webhook_url  # Pass Slack webhook URL as environment variable
      TEAMS_WEBHOOK_URL = var.teams_webhook_url  # Pass Teams webhook URL as environment variable
    }
  }
}
