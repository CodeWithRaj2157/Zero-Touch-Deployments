resource "aws_sns_topic" "alerts" {

  name = "${var.environment}-alerts"

}

resource "aws_sns_topic_subscription" "email" {

  topic_arn = aws_sns_topic.alerts.arn

  protocol = "email"

  endpoint = var.alarm_email

}

resource "aws_cloudwatch_metric_alarm" "cpu_alarm" {

  alarm_name = "${var.environment}-cpu-high"

  comparison_operator = "GreaterThanThreshold"

  evaluation_periods = 2

  metric_name = "CPUUtilization"

  namespace = "AWS/ECS"

  period = 60

  statistic = "Average"

  threshold = 70

  alarm_description = "High CPU Utilization"

  dimensions = {

    ClusterName = var.cluster_name

    ServiceName = var.service_name

  }

  alarm_actions = [

    aws_sns_topic.alerts.arn

  ]

}

resource "aws_cloudwatch_metric_alarm" "memory_alarm" {

  alarm_name = "${var.environment}-memory-high"

  comparison_operator = "GreaterThanThreshold"

  evaluation_periods = 2

  metric_name = "MemoryUtilization"

  namespace = "AWS/ECS"

  period = 60

  statistic = "Average"

  threshold = 80

  alarm_description = "High Memory Utilization"

  dimensions = {

    ClusterName = var.cluster_name

    ServiceName = var.service_name

  }

  alarm_actions = [

    aws_sns_topic.alerts.arn

  ]

}




resource "aws_cloudwatch_dashboard" "ecs_dashboard" {

  dashboard_name = "${var.environment}-ecs-dashboard"

  dashboard_body = jsonencode({

    widgets = [

      {

        type = "metric"

        x = 0

        y = 0

        width = 12

        height = 6

        properties = {

          metrics = [

            [

              "AWS/ECS",

              "CPUUtilization",

              "ClusterName",

              var.cluster_name,

              "ServiceName",

              var.service_name

            ]

          ]

          period = 300

          stat = "Average"

          region = "ap-south-1"

          title = "CPU Utilization"

        }

      },

      {

        type = "metric"

        x = 12

        y = 0

        width = 12

        height = 6

        properties = {

          metrics = [

            [

              "AWS/ECS",

              "MemoryUtilization",

              "ClusterName",

              var.cluster_name,

              "ServiceName",

              var.service_name

            ]

          ]

          period = 300

          stat = "Average"

          region = "ap-south-1"

          title = "Memory Utilization"

        }

      }

    ]

  })

}



