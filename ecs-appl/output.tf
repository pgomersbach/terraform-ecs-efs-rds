output "ecs-target-group-arn" {
  value = aws_alb_target_group.ecs-target-group.arn
}

output "ecs-load-balancer-arn" {
  value = aws_alb.ecs-load-balancer.arn
}

