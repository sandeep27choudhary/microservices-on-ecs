variable "vpc_id" {
  description = "The VPC ID where the security groups will be created"
  type        = string
}

variable "my_ip" {
  description = "My IP address for whitelisting"
  type        = string
}
