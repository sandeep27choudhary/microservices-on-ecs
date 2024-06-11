data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}


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


resource "aws_iam_role" "notifications_lambda_role" {
  count              = local.lambda_alerts_enabled ? 1 : 0
  name               = "health-check-notifications-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}

data "aws_iam_policy_document" "lambda_policy" {
  count = local.lambda_alerts_enabled ? 1 : 0
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    effect    = "Allow"
    resources = ["*"]
  }
}

resource "aws_iam_policy" "lambda_policy" {
  count  = local.lambda_alerts_enabled ? 1 : 0
  name   = "health-check-notifications-lambda"
  policy = data.aws_iam_policy_document.lambda_policy[0].json
}

resource "aws_iam_role_policy_attachment" "lambda_role_attached_policy" {
  count      = local.lambda_alerts_enabled ? 1 : 0
  role       = aws_iam_role.notifications_lambda_role[0].name
  policy_arn = aws_iam_policy.lambda_policy[0].arn
}
