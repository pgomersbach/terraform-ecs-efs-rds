provider "aws" {
  region  = "eu-central-1"
  profile = "mn-d01-cd"
}

module "iam" {
  source = "./iam"
}


module "ec2" {
  source = "./ec2"
  vpc-id                    = var.vpc_id # module.vpc.id
  security-group-id         = aws_security_group.demo-vpc-security-group.id # var.vpc_security-group-id # module.vpc.security-group-id
#  rds-security-group        = module.rds.db_access_sg_id
  subnet-id-1               = var.vpc_subnet1-id # module.vpc.subnet1-id
  subnet-id-2               = var.vpc_subnet2-id # module.vpc.subnet2-id
  ecs-instance-role-name    = module.iam.ecs-instance-role-name
  ecs-instance-profile-name = module.iam.ecs-instance-profile-name
  ecs-cluster-name          = var.ecs-cluster-name
  ecs-key-pair-name         = var.ecs-key-pair-name
}

/*
module "rds" {
  source            = "./rds"
  environment       = "production"
  allocated_storage = "20"
  database_name     = var.production_database_name
  database_username = var.production_database_username
  database_password = var.production_database_password
  subnet_ids        = [var.vpc_subnet1-id, var.vpc_subnet2-id] # [module.vpc.subnet1-id, module.vpc.subnet2-id]
  vpc_id            = var.vpc_id # module.vpc.id
  instance_class    = "db.t2.micro"
}
*/

module "ecs" {
  source = "./ecs"

  vpc-id             = var.vpc_id # module.vpc.id
#  rds-url            = module.rds.rds_address
#  rds-username       = module.rds.rds_user
#  rds-password       = module.rds.rds_password
#  rds-dbname         = var.production_database_name
  security-group-id  = var.vpc_security-group-id # var.vpc.security-group-id # module.vpc.security-group-id
#  rds-security-group = module.rds.db_access_sg_id
  subnet-id-1        = var.vpc_subnet1-id # module.vpc.subnet1-id
  subnet-id-2        = var.vpc_subnet2-id # module.vpc.subnet2-id
  efs-subnet-ids     = "${var.vpc_subnet1-id},${var.vpc_subnet2-id}" # "${module.vpc.subnet1-id},${module.vpc.subnet2-id}"
  ecs-cluster-name   = var.ecs-cluster-name

  #ecs-load-balancer-name      = "${module.ec2.ecs-load-balancer-name}"
  ecs-target-group-arn = module.ecs.ecs-target-group-arn
  ecs-service-role-arn = module.iam.ecs-service-role-arn
}

