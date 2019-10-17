variable "aws-profile-name" {
  description = "The profile for AWS auth."
  default     = "mn-d01-cd"
}

variable "ecs-region-name" {
  description = "Aws region"
  default     = "eu-central-1"
}

variable "ecs-key-pair-name" {
  description = "The name of the keypair."
  default     = "mn-paulg"
}

