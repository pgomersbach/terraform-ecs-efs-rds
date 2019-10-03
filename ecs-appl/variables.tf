variable "ecs-target-group-arn" {}

variable "aws_ecs_cluster_id" {}

variable "ecs-service-role-arn" {}

variable "ecs-service-name" {}

variable "vpc_id" {
  default = "vpc-03b68ef1c9da38682"
}

variable "load-balancer-name" {
  description = "The name for the autoscaling group for the cluster."
  default     = "demo-ecs-load-balancer"
}

variable "target-group-name" {
  description = "The name for the autoscaling group for the cluster."
  default     = "demo-ecs-target-group"
}

variable "security-group-id" {
  default = "sg-0497e6bcacf47182b"
}

variable "subnet-id-1" {
  default = "subnet-0d43a4b25d39ebca6"
}

variable "subnet-id-2" {
  default = "subnet-04eb7646079f3751a"
}

variable "subnet-id-3" {
  default = "subnet-0b0f45669fa1a89ae"
}

