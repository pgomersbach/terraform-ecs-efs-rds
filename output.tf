output "elasticsearch-load-balancer-alias" {
  value = module.elasticsearch.ecs-load-balancer-alias
}

output "kibana-load-balancer-alias" {
  value = module.kibana.ecs-load-balancer-alias
}

output "apm-server-load-balancer-alias" {
  value = module.apm-server.ecs-load-balancer-alias
}

