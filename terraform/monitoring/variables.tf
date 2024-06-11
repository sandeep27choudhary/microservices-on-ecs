variable "notification_email" {
  description = "Notification email for health check alerts"
}

variable "slack_webhook_url" {
  description = "Slack webhook URL for health check alerts"
  default     = ""
}

variable "teams_webhook_url" {
  description = "Microsoft Teams webhook URL for health check alerts"
  default     = ""
}