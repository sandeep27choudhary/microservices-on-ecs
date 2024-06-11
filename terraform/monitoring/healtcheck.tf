locals {
  endpoints_with_str_check   = { for name, parameters in var.endpoints : name => parameters if contains(keys(parameters), "search_string") }
  endpoints_with_https_check = { for name, parameters in var.endpoints : name => parameters if !contains(keys(parameters), "search_string") }
  route53_health_checks      = merge(aws_route53_health_check.https_check, aws_route53_health_check.https_str_check)
  lambda_alerts_enabled      = var.slack_webhook_url != "" || var.teams_webhook_url != ""
}

resource "aws_route53_health_check" "https_check" {
  for_each          = local.endpoints_with_https_check
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
  for_each          = local.endpoints_with_str_check
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

resource "aws_cloudwatch_metric_alarm" "endpoint_hc_alarm" {
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
  alarm_description   = each.value.fqdn
  dimensions = {
    HealthCheckId = each.value.id
  }
}
