//----------------------------------------------------------------------
// Shared Variables
//----------------------------------------------------------------------

variable "vpc-id" {
}

variable "subnet-ids" {
}

variable "ecs-cluster-name" {
}

variable "ecs-region-name" {
}

variable "ecs-instance-role-name" {
}

variable "ecs-instance-profile-name" {
}

variable "ecs-key-pair-name" {
}

variable "application-name"{}

variable "unit-name" {}

//----------------------------------------------------------------------
// Autoscaling Group Variables
//----------------------------------------------------------------------

variable "autoscaling-group-name" {
  description = "The name for the autoscaling group for the cluster."
  default     = "demo-ecs-asg"
}

variable "max-instance-size" {
  description = "The max number of instances in autoscaling group."
  default     = 4
}

variable "min-instance-size" {
  description = "The min number of instances in autoscaling group."
  default     = 1
}

variable "desired-capacity" {
  description = "The desired number of instances in autoscaling group."
  default     = 1
}

variable "health-check-grace-period" {
  description = "The health-check-grace-period for the autoscaling group."
  default     = 300
}

//----------------------------------------------------------------------
// Launch Configuration Variables
//----------------------------------------------------------------------

variable "launch-configuration-name" {
  description = "The name for the autoscaling group for the cluster."
  default     = "demo-ecs-launch-configuration"
}

variable "instance-type" {
  description = "The instance type for the autoscaling group."
  default     = "i3.large"
}

