module "ecs_task_execution_role" {
  source = "../service_role"
  policy_document = {
    actions = var.ecs_task_execution_role.policy_document.actions
    effect = var.ecs_task_execution_role.policy_document.effect
    type = var.ecs_task_execution_role.policy_document.type
    identifiers = var.ecs_task_execution_role.policy_document.identifiers
  }
  iam_role_name = var.ecs_task_execution_role.iam_role_name
  iam_policy_arn = var.ecs_task_execution_role.iam_policy_arn
}


resource "aws_ecs_task_definition" "ecs_task" {
  family                = var.ecs_task.family
  container_definitions = jsonencode([{
    name                = var.ecs_task.container_image_name
    image               = var.ecs_task.container_image
    cpu                 = var.ecs_task.cpu
    memory              = var.ecs_task.memory
    essential           = true
    portMappings = [{
      containerPort     = var.ecs_task.container_image_port
    }]

    logConfiguration = [{
      logDriver = awslogs,
      options = {
        awslogs-group = "/fargate/service/${var.ecs_task.family}"
        awslogs-region = ap-south-1
        awslogs-stream-prefix = var.ecs_task.family
      }
    }]

  }])
  cpu                 = var.ecs_task.cpu
  memory              = var.ecs_task.memory
  requires_compatibilities = var.ecs_task.requires_compatibilities
  network_mode             = var.ecs_task.network_mode
  execution_role_arn       = module.ecs_task_execution_role.iam_role_arn
}

resource "aws_ecs_service" "ecs_service" {
  name            = var.ecs_service.name
  cluster         = var.ecs_service.cluster
  task_definition = aws_ecs_task_definition.ecs_task.arn
  launch_type     = var.ecs_service.launch_type
  desired_count   = var.ecs_service.desired_count

  network_configuration {
    assign_public_ip = false

    subnets = var.ecs_service.private_subnets
  }
}


module "ecs_autoscale_role" {
  source = "../service_role"
  policy_document = {
    actions = var.ecs_autoscale_role.policy_document.actions
    effect = var.ecs_autoscale_role.policy_document.effect
    type = var.ecs_autoscale_role.policy_document.type
    identifiers = var.ecs_autoscale_role.policy_document.identifiers
  }
  iam_role_name = var.ecs_autoscale_role.iam_role_name
  iam_policy_arn = var.ecs_autoscale_role.iam_policy_arn
}

## --------------------------------------------------------------------------- ##

resource "aws_appautoscaling_target" "ecs_target" {
  min_capacity       = 1
  max_capacity       = 4
  resource_id        = "service/${var.ecs_service.cluster}/${aws_ecs_service.ecs_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
  role_arn           = module.ecs_autoscale_role.iam_role_arn
}

resource "aws_appautoscaling_policy" "appautoscaling_policy_cpu" {
  name               = "application-scale-policy-cpu"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = 80
  }
}

resource "aws_appautoscaling_policy" "appautoscaling_policy_memory" {
  name               = "application-scale-policy-memory"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    target_value = 80
  }
}