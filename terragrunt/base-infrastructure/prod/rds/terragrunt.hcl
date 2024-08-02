include "root" {
  path   = find_in_parent_folders("root-config.hcl")
  expose = true
}

include "stage" {
  path   = find_in_parent_folders("stage.hcl")
  expose = true
}

locals {
  # merge tags
  local_tags = {
    "Name" = "SecurityGroups"
  }

  tags = merge(include.root.locals.root_tags, include.stage.locals.tags, local.local_tags)
}

generate "provider_global" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
terraform {
  backend "s3" {}
  required_version = "${include.root.locals.version_terraform}"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "${include.root.locals.version_provider_aws}"
    }
  }
}

provider "aws" {
  region = "${include.root.locals.region}"
}
EOF
}

inputs = {
  db_identifier                     = "rds"
  db_engine                         = "mysql"
  db_engine_version                 = "8.0.37"
  db_instance_class                 = "db.t3.micro"
  db_allocated_storage              = 5
  db_name                           = "eklovedb"
  db_username                       = "root"
  db_password                       = "Admin@1234"
  db_port                           = "3306"
  iam_database_authentication_enabled = false
  vpc_security_group_ids            = ["sg-0aae37267df196be7"]
  maintenance_window                = "Mon:00:00-Mon:03:00"
  backup_window                     = "03:00-06:00"
  monitoring_interval               = "30"
  monitoring_role_name              = "MyRDSMonitoringRole"
  create_monitoring_role            = true
  tags                              = {
    Owner       = "user"
    Environment = "prod"
  }
  create_db_subnet_group            = true
  subnet_ids                        = ["subnet-0a517dffabc008f15", "subnet-0a566baadd44a3b18"]
  db_family                         = "mysql8.0"
  db_major_engine_version           = "8.0"
  deletion_protection               = false
  db_parameters                     = [
    {
      name  = "character_set_client"
      value = "utf8mb4"
    },
    {
      name  = "character_set_server"
      value = "utf8mb4"
    }
  ]
  db_options                        = [
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

terraform {
  source = "${get_parent_terragrunt_dir("root")}/../terraform/rds"
}
