
locals {
  endpoints_with_str_check   = { for name, parameters in var.endpoints : name => parameters if contains(keys(parameters), "search_string") }
  endpoints_with_https_check = { for name, parameters in var.endpoints : name => parameters if !contains(keys(parameters), "search_string") }
  route53_health_checks      = merge(aws_route53_health_check.https_check, aws_route53_health_check.https_str_check)
  lambda_alerts_enabled      = var.slack_webhook_url != "" || var.teams_webhook_url != ""
}

# Route 53 health-checks
resource "aws_route53_health_check" "https_check" {
  for_each = local.endpoints_with_https_check
  fqdn              = each.value.fqdn
  reference_name    = each.key
  port              = each.value.port
  type              = "HTTPS"
  resource_path     = each.value.path
  failure_threshold = "3"
  request_interval  = "30"

  tags = {
    Name = "${each.key}-hc"
  }
}

resource "aws_route53_health_check" "https_str_check" {
  for_each = local.endpoints_with_str_check
  fqdn              = each.value.fqdn
  reference_name    = each.key
  port              = each.value.port
  type              = "HTTPS_STR_MATCH"
  search_string     = each.value.search_string
  resource_path     = each.value.path
  failure_threshold = "3"
  request_interval  = "30"

  tags = {
    Name = "${each.key}-hc"
  }
}

# Cloudwatch alarm
resource "aws_cloudwatch_metric_alarm" "endpoint_hc_alarm" {
  provider = aws.use1
  for_each            = local.route53_health_checks
  alarm_name          = "${each.value.reference_name}-hc-alarm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "HealthCheckStatus"
  namespace           = "AWS/Route53"
  period              = "60"
  statistic           = "Minimum"
  threshold           = "1"
  alarm_actions       = [aws_sns_topic.alarm_sns_topic.arn]
  ok_actions          = [aws_sns_topic.alarm_sns_topic.arn]
  alarm_description   = each.value.fqdn # This is passed to lambda as endpoint value
  dimensions = {
    HealthCheckId = each.value.id
  }
}

data "archive_file" "notifications_lambda_zip" {
  type        = "zip"
  source_file = "../lambdas/healthcheck.py"
  output_path = "/tmp/healthcheck.zip"
}

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

resource "aws_lambda_function" "notifications_lambda" {
  count            = local.lambda_alerts_enabled ? 1 : 0
  filename         = data.archive_file.notifications_lambda_zip.output_path
  source_code_hash = data.archive_file.notifications_lambda_zip.output_base64sha256
  function_name    = "health-check-notifications"
  handler = "healthcheck.handler"
  runtime = "python3.12"
  role    = aws_iam_role.notifications_lambda_role[0].arn

  environment {
    variables = {
      TEAMS_WEBHOOK_URL = var.teams_webhook_url
      SLACK_WEBHOOK_URL = var.slack_webhook_url
    }
  }

  lifecycle {
    ignore_changes = [source_code_hash]
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

# SNS Topic for healthcheck alerts
resource "aws_sns_topic" "alarm_sns_topic" {
  name                             = "endpoint-health-check-alarm-topic"
  lambda_failure_feedback_role_arn = aws_iam_role.delivery_feedback_role.arn
  lambda_success_feedback_role_arn = aws_iam_role.delivery_feedback_role.arn
}

resource "aws_sns_topic_subscription" "lambda_topic_subscription" {
  count     = local.lambda_alerts_enabled ? 1 : 0
  topic_arn = aws_sns_topic.alarm_sns_topic.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.notifications_lambda[0].arn
}

resource "aws_sns_topic_subscription" "email_topic_subscription" {
  for_each  = toset(var.notification_email)
  topic_arn = aws_sns_topic.alarm_sns_topic.arn
  protocol  = "email"
  endpoint  = each.value
}

# resource "aws_sns_topic_subscription" "sms_topic_subscription" {
#   for_each  = toset(var.notification_mobile)
#   topic_arn = aws_sns_topic.alarm_sns_topic.arn
#   protocol  = "sms"
#   endpoint  = each.value
# }

# Feedback role
data "aws_iam_policy_document" "feedback_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "delivery_feedback_role" {
  name               = "SNSFeedbackRole"
  assume_role_policy = data.aws_iam_policy_document.feedback_assume_role_policy.json

  inline_policy {
    name = "SNSFeedbackPolicy"

    policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents",
            "logs:PutMetricFilter",
            "logs:PutRetentionPolicy"
          ],
          "Resource" : [
            "*"
          ]
        }
      ]
    })
  }
}
