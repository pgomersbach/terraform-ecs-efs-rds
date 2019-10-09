provider "aws" {
  region  = var.ecs-region-name
  profile = var.aws-profile-name
}

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
  vpc-id                    = data.aws_vpc.default-vpc.id
  subnet-ids                = data.aws_subnet_ids.all-sub.ids
  ecs-instance-role-name    = module.iam.ecs-instance-role-name
  ecs-instance-profile-name = module.iam.ecs-instance-profile-name
  ecs-cluster-name          = var.ecs-cluster-name
  ecs-region-name           = var.ecs-region-name
  ecs-key-pair-name         = var.ecs-key-pair-name
}

module "ecs" {
  source               = "./ecs"
  ecs-cluster-name     = var.ecs-cluster-name
  ecs-service-role-arn = module.iam.ecs-service-role-arn
}

module "ecs-appl" {
  source               = "./ecs-appl"
  lb-port              = 80
  ecs-service-name     = "apache"
  vpc-id               = data.aws_vpc.default-vpc.id
  subnet-ids           = data.aws_subnet_ids.all-sub.ids
  load-balancer-name   = "demo-ecs-load-balancer"
  target-group-name    = "demo-ecs-target-group"
  ecs-target-group-arn = module.ecs-appl.ecs-target-group-arn
  aws_ecs_cluster_id   = module.ecs.demo-ecs-cluster_id
  ecs-service-role-arn = module.iam.ecs-service-role-arn
}

