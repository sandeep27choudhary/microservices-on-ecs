variable "aws_region" {
  description = "The AWS region to create resources in."
  type        = string
  default     = "ap-south-1"
  }

variable "db_identifier" {
  description = "The RDS instance identifier."
  type        = string
  default     = "rds"
}

variable "db_engine" {
  description = "The database engine to use."
  type        = string
  default     = "mysql"
}

variable "db_engine_version" {
  description = "The engine version to use."
  type        = string
  default     = "5.7"
}

variable "db_instance_class" {
  description = "The instance class to use."
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "The allocated storage size in GB."
  type        = number
  default     = 5
}

variable "db_name" {
  description = "The name of the database to create."
  type        = string
  default     = "eklovedb"
}

variable "db_username" {
  description = "The database username."
  type        = string
  default     = "root"
}

variable "db_password" {
  description = "The database password."
  type        = string
}

variable "db_port" {
  description = "The database port."
  type        = string
  default     = "3306"
}

variable "iam_database_authentication_enabled" {
  description = "Enable IAM database authentication."
  type        = bool
  default     = true
}

variable "vpc_security_group_ids" {
  description = "The VPC security group IDs to associate with."
  type        = list(string)
}

variable "maintenance_window" {
  description = "The maintenance window."
  type        = string
  default     = "Mon:00:00-Mon:03:00"
}

variable "backup_window" {
  description = "The backup window."
  type        = string
  default     = "03:00-06:00"
}

variable "monitoring_interval" {
  description = "The monitoring interval in seconds."
  type        = string
  default     = "30"
}

variable "monitoring_role_name" {
  description = "The name of the monitoring role."
  type        = string
  default     = "MyRDSMonitoringRole"
}

variable "create_monitoring_role" {
  description = "Whether to create the monitoring role."
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to assign to the resource."
  type        = map(string)
  default = {
    Owner       = "user"
    Environment = "dev"
  }
}

variable "create_db_subnet_group" {
  description = "Whether to create a database subnet group."
  type        = bool
  default     = true
}

variable "subnet_ids" {
  description = "A list of subnet IDs to associate with the RDS instance."
  type        = list(string)
}

variable "db_family" {
  description = "The DB family."
  type        = string
  default     = "mysql5.7"
}

variable "db_major_engine_version" {
  description = "The major engine version."
  type        = string
  default     = "5.7"
}

variable "deletion_protection" {
  description = "Whether to enable deletion protection."
  type        = bool
  default     = false
}

variable "db_parameters" {
  description = "A list of DB parameter maps."
  type        = list(object({
    name  = string
    value = string
  }))
  default = [
    {
      name  = "character_set_client"
      value = "utf8mb4"
    },
    {
      name  = "character_set_server"
      value = "utf8mb4"
    }
  ]
}

variable "db_options" {
  description = "A list of DB option maps."
  type        = list(object({
    option_name     = string
    option_settings = list(object({
      name  = string
      value = string
    }))
  }))
  default = [
    {
      option_name = "MARIADB_AUDIT_PLUGIN"
      option_settings = [
        {
          name  = "SERVER_AUDIT_EVENTS"
          value = "CONNECT"
        },
        {
          name  = "SERVER_AUDIT_FILE_ROTATIONS"
          value = "37"
        },
      ]
    }
  ]
}
