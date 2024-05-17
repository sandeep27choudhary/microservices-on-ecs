# main.tf

resource "aws_cloudwatch_log_group" "backend_logs" {
  name = "/fargate/service/${var.log_group_name}"
}
