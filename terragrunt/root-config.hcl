locals {
  region = "ap-south-1"

  version_terraform    = ">=1.5.0"
  version_terragrunt   = "=0.37.1"
  version_provider_aws = ">=5.45.0"

  root_tags = {
    project = "ecs-terraform-terragrunt"
  }
}


remote_state {
  backend = "s3"
  config = {
    bucket         = "tfstates-2024"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    encrypt        = true
    region         = local.region
    dynamodb_table = "terraform-locks-table"
  }
}