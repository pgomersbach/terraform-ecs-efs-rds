variable "aws-profile-name" {
  description = "The profile for AWS auth."
  default     = "mn-d01-cd"
}

variable "ecs-cluster-name" {
  description = "The name for the cluster."
  default     = "tf-ecs-cluster"
}
variable "ecs-region-name" {
  description = "Aws region"
  default     = "eu-central-1"
}

variable "ecs-key-pair-name" {
  description = "The name for the cluster."
  default     = "mn-paulg"
}

### vpc setting ###

variable "vpc-security-group-id" {
  default = "sg-0497e6bcacf47182b"
}

variable "vpc-id" {
  default = "vpc-03b68ef1c9da38682"
}

variable "vpc-subnet1-id" {
  default = "subnet-0d43a4b25d39ebca6"
}

variable "vpc-subnet2-id" {
  default = "subnet-04eb7646079f3751a"
}

variable "vpc-subnet3-id" {
  default = "subnet-0b0f45669fa1a89ae"
}
