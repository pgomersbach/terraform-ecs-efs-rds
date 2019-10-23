# output "ecs-load-balancer-arn" {
#  value = aws_alb.ecs-load-balancer.arn
# }

output "ecs-load-balancer-alias" {
  value = aws_route53_record.service["alb"].fqdn
}
