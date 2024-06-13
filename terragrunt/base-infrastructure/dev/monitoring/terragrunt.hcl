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
    "Name" = "healthcheck"
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
  
  notification_email = ["csandeep497@gmail.com"]
  slack_webhook_url   = ""
  teams_webhook_url = "https://outlook.office.com/webhook/dummy-url"
  endpoints = {
    endpoint-1 = {
      fqdn          = "www.google.com"
      port          = 443
      path          = ""
      search_string = "status:ok"
    },
    endpoint-2 = {
      fqdn          = "duhops.com"
      port          = 443
      path          = "healthcheck"
      search_string = "status:ok"
    }
  }
  

  tags = local.tags
}

terraform {
  source = "${get_parent_terragrunt_dir("root")}/..//terraform/monitoring"
}