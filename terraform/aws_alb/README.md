<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_alb.application_load_balancer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/alb) | resource |
| [aws_security_group.egress_all](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alb"></a> [alb](#input\_alb) | n/a | <pre>object({<br>    name               = string<br>    internal           = bool<br>    load_balancer_type = string<br>    subnets            = list(string)<br>  })</pre> | n/a | yes |
| <a name="input_aws_security_group_egress_all"></a> [aws\_security\_group\_egress\_all](#input\_aws\_security\_group\_egress\_all) | n/a | <pre>object({<br>    name        = string<br>    description = string<br>    vpc_id      = string<br>  })</pre> | n/a | yes |
| <a name="input_aws_security_group_http"></a> [aws\_security\_group\_http](#input\_aws\_security\_group\_http) | n/a | <pre>object({<br>    name        = string<br>    description = string<br>    vpc_id      = string<br>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alb_url"></a> [alb\_url](#output\_alb\_url) | n/a |
| <a name="output_aws_alb_arn"></a> [aws\_alb\_arn](#output\_aws\_alb\_arn) | n/a |
| <a name="output_aws_sg_egress_all_id"></a> [aws\_sg\_egress\_all\_id](#output\_aws\_sg\_egress\_all\_id) | n/a |
<!-- END_TF_DOCS -->