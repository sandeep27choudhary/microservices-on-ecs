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
    "Name" = "inventory"
  }

  tags = merge(include.root.locals.root_tags, include.stage.locals.tags, local.local_tags)
}

dependency "vpc" {
  config_path                             = "${get_parent_terragrunt_dir("root")}/base-infrastructure/${include.stage.locals.stage}/vpc_subnet_module"
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
  mock_outputs = {
    vpc_id                  = "some_id"
    vpc_public_subnets_ids  = ["some-id"]
    vpc_private_subnets_ids = ["some-id"]
  }
}

dependency "backend_sg" {
  config_path                             = "${get_parent_terragrunt_dir("root")}/applications/${include.stage.locals.stage}/backend"
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
  mock_outputs = {
    backend_sg = "some_id"
  }
}

dependency "ecs_cluster" {
  config_path                             = "${get_parent_terragrunt_dir("root")}/base-infrastructure/${include.stage.locals.stage}/ecs_cluster"
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
  mock_outputs = {
    aws_ecs_cluster_id = "some_id"
  }
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
  ecs_task_execution_role = {
    policy_document = {
      actions     = ["sts:AssumeRole"]
      effect      = "Allow"
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
    iam_role_name = "inventory-task-execution-role"
    iam_policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  }

  ecs_autoscale_role = {
    policy_document = {
      actions     = ["sts:AssumeRole"]
      effect      = "Allow"
      type        = "Service"
      identifiers = ["application-autoscaling.amazonaws.com"]
    }
    iam_role_name = "inventory-ecs-scale-application"
    iam_policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceAutoscaleRole"
  }

  ecs_task = {
    family                   = "inventory"
    container_image_name     = "inventory"
    container_image          = "730335543129.dkr.ecr.ap-south-1.amazonaws.com/inventory:latest"
    container_image_port     = 5000
    cpu                      = 256
    memory                   = 512
    requires_compatibilities = ["FARGATE"]
    network_mode             = "awsvpc"
  }

  ecs_service = {
    name            = "inventory"
    cluster         = dependency.ecs_cluster.outputs.aws_ecs_cluster_id
    launch_type     = "FARGATE"
    desired_count   = 3
    private_subnets = dependency.vpc.outputs.vpc_private_subnets_ids
  }

  backend_sg = dependency.backend_sg.outputs.backend_security_group_id
  vpc_id  = dependency.vpc.outputs.vpc_id
}

terraform {
  source = "${get_parent_terragrunt_dir("root")}/..//terraform/inventory"
}