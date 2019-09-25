variable "ecs-cluster-name" {
  description = "The name for the cluster."
  default     = "tf-ecs-cluster"
}

variable "ecs-key-pair-name" {
  description = "The name for the cluster."
  default     = "mn-paulg"
}

### vpc setting ###

variable "vpc_security-group-id" {
  default = "sg-0497e6bcacf47182b"
}

variable "vpc_id" {
  default = "vpc-03b68ef1c9da38682"
}

variable "vpc_subnet1-id" {
  default = "subnet-0d43a4b25d39ebca6"
}

variable "vpc_subnet2-id" {
  default = "subnet-04eb7646079f3751a"
}


/*====
environment specific variables
======*/

variable "production_database_name" {
  description = "The database name for Production"
}

variable "production_database_username" {
  description = "The username for the Production database"
}

variable "production_database_password" {
  description = "The user password for the Production database"
}

