variable "subnet_ids" {
  description = "Subnet ids"
}

variable "vpc_id" {
  description = "The VPC id"
}

variable "allocated_storage" {
  default     = "20"
  description = "The storage size in GB"
}

variable "instance_class" {
  description = "The instance type"
}

variable "multi_az" {
  default     = false
  description = "Muti-az allowed?"
}

variable "database_name" {
  default     = "dummy_data"
  description = "The database name"
}

variable "database_username" {
  default     = "admin"
  description = "The username of the database"
}

variable "database_password" {
  default     = "testing123"
  description = "The password of the database"
}

variable "application-name"{}

variable "unit-name" {}

