locals {
  lb = { for v in var.lb : v => v }
}

resource "aws_alb" "ecs-load-balancer" {
  for_each        = local.lb
  name            = "alb-${var.ecs-service-name}-${terraform.workspace}"
  internal        = true
  security_groups = [aws_security_group.lb-security-group[each.key].id]
  subnets         = var.subnet-ids
  tags        = {
    AplicationName = var.application-name,
    UnitName       = var.unit-name
    Workspace      = "${terraform.workspace}"
  }
}

data "aws_acm_certificate" "cert" {
  domain   = "*.${var.hosted-zone}"
  statuses = ["ISSUED"]
}

data "aws_route53_zone" "selected" {
  name         = "${var.hosted-zone}"
  private_zone = false
}

resource "aws_route53_record" "service" {
  for_each = local.lb
  zone_id  = data.aws_route53_zone.selected.zone_id
  name     = "${var.ecs-service-name}-${terraform.workspace}"
  type     = "A"

  alias {
    name                   = "${aws_alb.ecs-load-balancer[each.key].dns_name}"
    zone_id                = "${aws_alb.ecs-load-balancer[each.key].zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_security_group" "lb-security-group" {
  for_each               = local.lb
  description            = "LB security group"
  vpc_id                 = var.vpc-id
  revoke_rules_on_delete = true
  tags        = {
    AplicationName = var.application-name,
    UnitName       = var.unit-name
    Workspace      = "${terraform.workspace}"
  }

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
  for_each             = local.lb
  name                 = "tg-${var.ecs-service-name}-${terraform.workspace}"
  port                 = var.lb-port
  protocol             = "HTTP"
  vpc_id               = var.vpc-id
  deregistration_delay = 120
  tags        = {
    AplicationName = var.application-name,
    UnitName       = var.unit-name
    Workspace      = "${terraform.workspace}"
  }

  health_check {
    port                = var.lb-port
    healthy_threshold   = "2"
    unhealthy_threshold = "5"
    interval            = "30"
    matcher             = "200,302"
    path                = "/"
    protocol            = "HTTP"
    timeout             = "5"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_alb_listener" "alb-listener" {
  for_each          = local.lb
  load_balancer_arn = aws_alb.ecs-load-balancer[each.key].arn
  port              = 443 # var.lb-port
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "${data.aws_acm_certificate.cert.arn}"

  default_action {
    target_group_arn = aws_alb_target_group.ecs-target-group["alb"].arn
    type             = "forward"
  }
}

resource "aws_ecs_service" "ecs-service" {
  name                               = "${var.ecs-service-name}-${terraform.workspace}"
  cluster                            = var.aws_ecs_cluster_id
  task_definition                    = aws_ecs_task_definition.my-task.arn
  desired_count                      = var.desired-count
  scheduling_strategy                = var.service-sched-strategy
  depends_on                         = [aws_alb_listener.alb-listener]
  deployment_maximum_percent         = var.deployment-max
  deployment_minimum_healthy_percent = var.deployment-min

  dynamic "ordered_placement_strategy" {
    for_each = local.lb
    content {
      type  = "spread"
      field = "attribute:ecs.availability-zone"
    }
  }

  dynamic "load_balancer" {
    for_each = local.lb
    content {
      target_group_arn = aws_alb_target_group.ecs-target-group["alb"].arn
      container_port   = var.lb-port
      container_name   = var.ecs-service-name
    }
  }
}

