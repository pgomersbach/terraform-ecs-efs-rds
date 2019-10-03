resource "aws_alb" "ecs-load-balancer" {
  name            = var.load-balancer-name
  security_groups = [var.security-group-id]
  subnets         = [var.subnet-id-1, var.subnet-id-2, var.subnet-id-3]
}

resource "aws_alb_target_group" "ecs-target_group" {
  name     = var.target-group-name
  port     = "80"
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    healthy_threshold   = "5"
    unhealthy_threshold = "2"
    interval            = "30"
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = "5"
  }
}

resource "aws_alb_listener" "alb-listener" {
  load_balancer_arn = aws_alb.ecs-load-balancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.ecs-target_group.arn
    type             = "forward"
  }
}


resource "aws_ecs_service" "demo-ecs-service" {
  name            = var.ecs-service-name
  iam_role        = var.ecs-service-role-arn
  cluster         = var.aws_ecs_cluster_id
  task_definition = aws_ecs_task_definition.demo-sample-definition.arn
  desired_count   = 1
  depends_on      = [aws_alb_listener.alb-listener]

  load_balancer {
    #target_group_arn  = "${var.ecs-target-group-arn}"
    target_group_arn = var.ecs-target-group-arn
    container_port   = 80
    container_name   = "wordpress-app"
  }
}
