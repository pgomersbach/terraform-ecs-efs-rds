# variable "ecs-target-group-arn" {}

variable "aws_ecs_cluster_id" {}

variable "ecs-service-role-arn" {}

variable "ecs-service-name" {}

variable "target-lb-url" {
  default = "dummy-lb-url"
}

variable "kibana-lb-url" {
  default = "dummy-kibana-url"
}

variable "vpc-id" {}

variable "lb-port" {}

variable "hosted-zone" {}

variable "lb" {
  type = list(string)
  # default = ["alb"]
  default = []
}

variable "cpu" {}

variable "memory" {}

variable "container-path" {}

variable "storage-type" {}

variable "service-sched-strategy" {
  default = "REPLICA"
}

#variable "load-balancer-name" {
#  description = "The name for the autoscaling group for the cluster."
#}

#variable "target-group-name" {
#  description = "The name for the autoscaling group for the cluster."
#}

variable "subnet-ids" {}

