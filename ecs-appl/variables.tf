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

variable "apm-server-lb-url" {
  default = "dummy-apm-server-url"
}

variable "application-name" {}

variable "unit-name" {}

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

variable "desired-count" { 
  default = 1
}

variable "deployment-max" {
  default = 100
}

variable "deployment-min" {
  default = 50
}

variable "subnet-ids" {}

variable "av-names" {} 

