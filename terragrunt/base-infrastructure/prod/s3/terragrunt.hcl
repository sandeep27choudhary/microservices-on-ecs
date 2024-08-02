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
  aws_region                    = "ap-south-1"
  s3_bucket_name                = "auth-docs-allneeds24"
  s3_acl                        = "public-read-write"
  control_object_ownership      = true
  object_ownership              = "ObjectWriter"
  versioning_enabled            = true
}

terraform {
  source = "${get_parent_terragrunt_dir("root")}/../terraform/s3"
}
