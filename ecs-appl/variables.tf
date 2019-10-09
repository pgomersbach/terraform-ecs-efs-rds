variable "ecs-target-group-arn" {}

variable "aws_ecs_cluster_id" {}

variable "ecs-service-role-arn" {}

variable "ecs-service-name" {}

variable "vpc-id" {}

variable "lb-port" {}

variable "load-balancer-name" {
  description = "The name for the autoscaling group for the cluster."
}

variable "target-group-name" {
  description = "The name for the autoscaling group for the cluster."
}

variable "subnet-ids" {}

