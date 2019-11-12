output "elasticsearch-load-balancer-alias" {
  value = "https://${module.elasticsearch.ecs-load-balancer-alias}"
}

output "kibana-load-balancer-alias" {
  value = "https://${module.kibana.ecs-load-balancer-alias}"
}

output "apm-server-load-balancer-alias" {
  value = "https://${module.apm-server.ecs-load-balancer-alias}"
}

