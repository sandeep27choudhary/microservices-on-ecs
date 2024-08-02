variable "aws_region" {
  description = "The AWS region to create resources in."
  type        = string
  default     = "us-west-2"
}

variable "s3_bucket_name" {
  description = "The name of the S3 bucket."
  type        = string
}

variable "s3_acl" {
  description = "The ACL policy for the bucket."
  type        = string
  default     = "private"
}

variable "control_object_ownership" {
  description = "Whether to enable control object ownership."
  type        = bool
  default     = true
}

variable "object_ownership" {
  description = "The object ownership setting for the bucket."
  type        = string
  default     = "ObjectWriter"
}

variable "versioning_enabled" {
  description = "Whether to enable versioning on the bucket."
  type        = bool
  default     = true
}
