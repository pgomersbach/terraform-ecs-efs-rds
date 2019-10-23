output "elasticsearch-load-balancer-alias" {
  value = module.elasticsearch.ecs-load-balancer-alias
}

output "kibana-load-balancer-alias" {
  value = module.kibana.ecs-load-balancer-alias
}

