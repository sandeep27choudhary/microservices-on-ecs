variable "endpoints" {
  description = "Map of endpoints for health checks"
  type        = map(object({
    fqdn          = string
    port          = number
    path          = string
    search_string = optional(string)
  }))
}

variable "teams_webhook_url" {
  description = "Teams webhook URL for notifications"
  type        = string
  default     = ""
}

variable "slack_webhook_url" {
  description = "Slack webhook URL for notifications"
  type        = string
  default     = ""
}

variable "notification_email" {
  description = "List of emails for notifications"
  type        = list(string)
}

