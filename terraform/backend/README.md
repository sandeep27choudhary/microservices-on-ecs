<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws_cloudwatch_log_group"></a> [aws\_cloudwatch\_log\_group](#module\_aws\_cloudwatch\_log\_group) | ../cloudwatch | n/a |
| <a name="module_ecs_autoscale_role"></a> [ecs\_autoscale\_role](#module\_ecs\_autoscale\_role) | ../service_role | n/a |
| <a name="module_ecs_task_execution_role"></a> [ecs\_task\_execution\_role](#module\_ecs\_task\_execution\_role) | ../service_role | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_appautoscaling_policy.appautoscaling_policy_cpu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_policy.appautoscaling_policy_memory](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_target.ecs_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target) | resource |
| [aws_ecs_service.ecs_service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.ecs_task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_security_group.backend_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ecs_autoscale_role"></a> [ecs\_autoscale\_role](#input\_ecs\_autoscale\_role) | n/a | <pre>object({<br>    policy_document = object({<br>      actions = list(string)<br>      effect = string<br>      type = string<br>      identifiers = list(string)<br>    })<br>    iam_role_name = string<br>    iam_policy_arn = string<br>  })</pre> | n/a | yes |
| <a name="input_ecs_service"></a> [ecs\_service](#input\_ecs\_service) | n/a | <pre>object({<br>    name            = string<br>    cluster         = string<br>    launch_type     = string<br>    desired_count   = number<br>    private_subnets = list(string)<br>  })</pre> | n/a | yes |
| <a name="input_ecs_task"></a> [ecs\_task](#input\_ecs\_task) | n/a | <pre>object({<br>    family                   = string<br>    container_image_name     = string<br>    container_image          = string<br>    cpu                      = number<br>    memory                   = number<br>    requires_compatibilities = list(string)<br>    network_mode             = string<br>    container_image_port     = number<br>  })</pre> | n/a | yes |
| <a name="input_ecs_task_execution_role"></a> [ecs\_task\_execution\_role](#input\_ecs\_task\_execution\_role) | n/a | <pre>object({<br>    policy_document = object({<br>      actions = list(string)<br>      effect = string<br>      type = string<br>      identifiers = list(string)<br>    })<br>    iam_role_name = string<br>    iam_policy_arn = string<br>  })</pre> | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_backend_security_group_id"></a> [backend\_security\_group\_id](#output\_backend\_security\_group\_id) | n/a |
<!-- END_TF_DOCS -->