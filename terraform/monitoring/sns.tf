# Terraform file for SNS topic

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
  for_each  = toset(var.notification_emails)
  topic_arn = aws_sns_topic.alarm_sns_topic.arn
  protocol  = "email"
  endpoint  = each.value
}

resource "aws_sns_topic_subscription" "sms_topic_subscription" {
  for_each  = toset(var.notification_mobile)
  topic_arn = aws_sns_topic.alarm_sns_topic.arn
  protocol  = "sms"
  endpoint  = each.value
}
