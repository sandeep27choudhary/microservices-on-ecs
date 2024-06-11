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

variable "notification_emails" {
  description = "List of emails for notifications"
  type        = list(string)
}

variable "notification_mobile" {
  description = "List of mobile numbers for SMS notifications"
  type        = list(string)
}

variable "vpc_subnet_module" {
  description = "VPC subnet module input"
  type        = string
}
