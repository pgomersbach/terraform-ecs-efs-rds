provider "aws" {
  region  = var.ecs-region-name
  profile = var.aws-profile-name
}

/*
terraform {
  backend "s3" {
    bucket  = "mn-cd-terraform-state"
    key     = "mn-d01-cd"
    region  = "eu-central-1"
    profile = "mn-d01-cd"
  }
}
*/
data "aws_vpc" "default-vpc" {
  filter {
    name   = "tag:Name"
    values = ["mn-vpc"]
  }
}

data "aws_subnet_ids" "all-sub" {
   vpc_id = data.aws_vpc.default-vpc.id

  filter {
    name   = "tag:Name"
    values = ["mn-private-*"]
  }
}

module "iam" {
  source = "./iam"
}

module "ec2" {
  source                    = "./ec2"
  max-instance-size         = 4
  min-instance-size         = 2
  desired-capacity          = 3
  instance-type             = "t3.xlarge"
  vpc-id                    = data.aws_vpc.default-vpc.id
  subnet-ids                = data.aws_subnet_ids.all-sub.ids
  ecs-instance-role-name    = module.iam.ecs-instance-role-name
  ecs-instance-profile-name = module.iam.ecs-instance-profile-name
  ecs-cluster-name          = "${var.aws-profile-name}-ecs-cluster"
  ecs-region-name           = var.ecs-region-name
  ecs-key-pair-name         = var.ecs-key-pair-name
}

/*
module "rds" {
  source            = "./rds"
  environment       = "production"
  allocated_storage = "5"
  database_name     = "${var.production_database_name}"
  database_username = "${var.production_database_username}"
  database_password = "${var.production_database_password}"
  multi_az          = true
  subnet_ids        = data.aws_subnet_ids.all-sub.ids 
  vpc_id            = data.aws_vpc.default-vpc.id
  instance_class    = "db.t2.micro"
}
*/

module "ecs" {
  source               = "./ecs"
  ecs-cluster-name     = "${var.aws-profile-name}-ecs-cluster"
}

module "ecs-appl" {
  source               = "./ecs-appl"
  lb-port              = 5601
  ecs-service-name     = "kibana"
  memory               = 8192
  cpu                  = 2048
  container-path       = "/esdata"
  storage-type         = "ebs"  # efs | ebs 
  service-sched-strategy = "REPLICA" # DAEMON | REPLICA
  vpc-id               = data.aws_vpc.default-vpc.id
  subnet-ids           = data.aws_subnet_ids.all-sub.ids
  ecs-target-group-arn = module.ecs-appl.ecs-target-group-arn
  aws_ecs_cluster_id   = module.ecs.demo-ecs-cluster_id
  ecs-service-role-arn = module.iam.ecs-service-role-arn
}

