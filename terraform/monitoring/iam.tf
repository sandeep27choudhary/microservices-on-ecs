# Terraform file for IAM roles and policies

data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "notifications_lambda_role" {
  count              = local.lambda_alerts_enabled ? 1 : 0
  name               = "health-check-notifications-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}

resource "aws_lambda_permission" "lambda_permission" {
  count         = local.lambda_alerts_enabled ? 1 : 0
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.notifications_lambda[0].function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.alarm_sns_topic.arn
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
