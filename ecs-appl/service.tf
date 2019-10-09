resource "aws_alb" "ecs-load-balancer" {
  name            = var.load-balancer-name
  security_groups = [ aws_security_group.lb-security-group.id ]
  subnets         = var.subnet-ids
}

resource "aws_security_group" "lb-security-group" {
  name        = "lb-security-group"
  description = "LB security group"
  vpc_id      = var.vpc-id

  // TCP
  ingress {
    from_port   = var.lb-port
    to_port     = var.lb-port
    protocol    = "tcp"
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
  name        = var.target-group-name
  port        = "80"
  protocol    = "HTTP"
  vpc_id      = var.vpc-id

  health_check {
    healthy_threshold   = "5"
    unhealthy_threshold = "2"
    interval            = "30"
    matcher             = "200"
    path                = "/"
    protocol            = "HTTP"
    timeout             = "5"
  }
}

resource "aws_alb_listener" "alb-listener" {
  load_balancer_arn = aws_alb.ecs-load-balancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.ecs-target-group.arn
    type             = "forward"
  }
}

resource "aws_ecs_service" "demo-ecs-service" {
  name                              = var.ecs-service-name
  cluster                           = var.aws_ecs_cluster_id
  task_definition                   = aws_ecs_task_definition.apache-task.arn
  desired_count                     = 1
  health_check_grace_period_seconds = 60
  depends_on                        = [aws_alb_listener.alb-listener]

  load_balancer {
    target_group_arn = var.ecs-target-group-arn
    container_port   = 80
    container_name   = "apache-app"
  }

  ordered_placement_strategy {
    type  = "spread"
    field = "attribute:ecs.availability-zone"
  }
}

