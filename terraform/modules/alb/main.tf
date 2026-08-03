resource "aws_lb" "alb" {

  name = "${var.environment}-alb"

  internal = false

  load_balancer_type = "application"

  security_groups = [
    var.alb_security_group_id
  ]

  subnets = var.public_subnet_ids

  enable_deletion_protection = false

  tags = {
    Name = "${var.environment}-alb"
  }

}



resource "aws_lb_target_group" "tg" {

  name = "${var.environment}-tg"

  port = 5000

  protocol = "HTTP"

  target_type = "ip"

  vpc_id = var.vpc_id

  health_check {

    enabled = true

    path = "/"

    interval = 30

    timeout = 5

    healthy_threshold = 2

    unhealthy_threshold = 2

    matcher = "200"

  }

  tags = {

    Name = "${var.environment}-tg"

  }

}



resource "aws_lb_listener" "http" {

  load_balancer_arn = aws_lb.alb.arn

  port = 80

  protocol = "HTTP"

  default_action {

    type = "forward"

    target_group_arn = aws_lb_target_group.tg.arn

  }

}


