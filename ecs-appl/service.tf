resource "aws_alb" "ecs-load-balancer" {
  name            = "alb-${var.ecs-service-name}"
  internal        = true
  security_groups = [ aws_security_group.lb-security-group.id ]
  subnets         = var.subnet-ids
}

resource "aws_security_group" "lb-security-group" {
  name        = "lb-security-group"
  description = "LB security group"
  vpc_id      = var.vpc-id

  // TCP
  ingress {
    from_port   = 0 # var.lb-port
    to_port     = 0 # var.lb-port
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_alb_target_group" "ecs-target-group" {
  name        = "tg-${var.ecs-service-name}"
  port        = var.lb-port
  protocol    = "HTTP"
  vpc_id      = var.vpc-id

  health_check {
    port                = var.lb-port
    healthy_threshold   = "2"
    unhealthy_threshold = "5"
    interval            = "30"
    matcher             = "302"
    path                = "/"
    protocol            = "HTTP"
    timeout             = "5"
  }
}

resource "aws_alb_listener" "alb-listener" {
  load_balancer_arn = aws_alb.ecs-load-balancer.arn
  port              = 80 # var.lb-port
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.ecs-target-group.arn
    type             = "forward"
  }
}

resource "aws_ecs_service" "demo-ecs-service" {
  name                              = var.ecs-service-name
  cluster                           = var.aws_ecs_cluster_id
  task_definition                   = aws_ecs_task_definition.my-task.arn
  desired_count                     = 1
  scheduling_strategy               = var.service-sched-strategy
  health_check_grace_period_seconds = 10
  depends_on                        = [ aws_alb_listener.alb-listener ]

  load_balancer {
    target_group_arn = var.ecs-target-group-arn
    container_port   = var.lb-port
    container_name   = var.ecs-service-name
  }

}

