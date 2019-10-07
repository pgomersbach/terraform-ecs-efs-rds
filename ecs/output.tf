output "demo-ecs-cluster_id" {
  value = "${aws_ecs_cluster.demo-ecs-cluster.id}"
}

output "ecs-load-balancer-name" {
  value = aws_alb.ecs-load-balancer.name
}

output "ecs-load-balancer-arn" {
  value = aws_alb.ecs-load-balancer.arn
}

