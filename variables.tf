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

variable "hosted-zone" {
  description = "predefined hosted zone"
  default     = "d01-cd.aws-internal-mn.nl"
}

variable "production_database_name" {
  description = "Database name"
  default     = "postgres"
}

variable "production_database_username" {
  description = "Database admin user"
  default     = "localadmin"
}

variable "production_database_password" {
  description = "Database admin password"
  default     = "changeme"
}

