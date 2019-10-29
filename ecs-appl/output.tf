output "ecs-load-balancer-alias" {
  value = aws_route53_record.service["alb"].fqdn
}
