data "aws_region" "current" {}


resource "aws_cloudwatch_log_group" "ecs" {

  name = "/ecs/${var.environment}"

  retention_in_days = 7

}

resource "aws_ecs_cluster" "cluster" {

  name = "${var.environment}-ecs-cluster"

}



resource "aws_ecs_task_definition" "task" {

  family = "${var.environment}-task"

  network_mode = "awsvpc"

  requires_compatibilities = ["FARGATE"]

  cpu = var.cpu

  memory = var.memory

  execution_role_arn = var.execution_role_arn
  task_role_arn      = var.task_role_arn

  container_definitions = jsonencode([

    {

      name = "app"

      image = "${var.repository_url}:latest"

      essential = true

      portMappings = [

        {

          containerPort = var.container_port

          hostPort = var.container_port

          protocol = "tcp"

        }

      ]

      logConfiguration = {

        logDriver = "awslogs"

        options = {

          awslogs-group = aws_cloudwatch_log_group.ecs.name

          awslogs-region = data.aws_region.current.name

          awslogs-stream-prefix = "ecs"

        }

      }

    }

  ])

}



resource "aws_ecs_service" "service" {

  name = "${var.environment}-service"

  cluster = aws_ecs_cluster.cluster.id

  task_definition = aws_ecs_task_definition.task.arn

  desired_count = var.desired_count

  launch_type = "FARGATE"

  network_configuration {

    assign_public_ip = false

    subnets = var.private_subnet_ids

    security_groups = [

      var.ecs_security_group_id

    ]

  }

  load_balancer {

    target_group_arn = var.target_group_arn

    container_name = "app"

    container_port = var.container_port

  }

  depends_on = [

    aws_ecs_task_definition.task

  ]

}

resource "aws_appautoscaling_target" "ecs" {

  max_capacity = 6

  min_capacity = 2

  resource_id = "service/${aws_ecs_cluster.cluster.name}/${aws_ecs_service.service.name}"

  scalable_dimension = "ecs:service:DesiredCount"

  service_namespace = "ecs"

}



resource "aws_appautoscaling_policy" "cpu" {

  name = "${var.environment}-cpu-policy"

  policy_type = "TargetTrackingScaling"

  resource_id = aws_appautoscaling_target.ecs.resource_id

  scalable_dimension = aws_appautoscaling_target.ecs.scalable_dimension

  service_namespace = aws_appautoscaling_target.ecs.service_namespace

  target_tracking_scaling_policy_configuration {

    predefined_metric_specification {

      predefined_metric_type = "ECSServiceAverageCPUUtilization"

    }

    target_value = 70

  }

}


