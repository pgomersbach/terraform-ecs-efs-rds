provider "aws" {
  region  = var.ecs-region-name
  profile = var.aws-profile-name
}

module "iam" {
  source = "./iam"
}

module "ec2" {
  source                    = "./ec2"
  max-instance-size         = 4
  min-instance-size         = 2
  desired-capacity          = 3
  vpc-id                    = var.vpc_id
  security-group-id         = aws_security_group.demo-vpc-security-group.id
  subnet-id-1               = var.vpc_subnet1-id
  subnet-id-2               = var.vpc_subnet2-id
  subnet-id-3               = var.vpc_subnet3-id
  ecs-instance-role-name    = module.iam.ecs-instance-role-name
  ecs-instance-profile-name = module.iam.ecs-instance-profile-name
  ecs-cluster-name          = var.ecs-cluster-name
  ecs-region-name           = var.ecs-region-name
  ecs-key-pair-name         = var.ecs-key-pair-name
}

module "ecs" {
  source               = "./ecs"
  vpc-id               = var.vpc_id
  security-group-id    = var.vpc_security-group-id
  subnet-id-1          = var.vpc_subnet1-id
  subnet-id-2          = var.vpc_subnet2-id
  subnet-id-3          = var.vpc_subnet3-id
  ecs-cluster-name     = var.ecs-cluster-name
  ecs-service-role-arn = module.iam.ecs-service-role-arn
}


module "ecs-appl" {
  source               = "./ecs-appl"
  ecs-target-group-arn = module.ecs-appl.ecs-target-group-arn
  ecs-service-name     = "myservice"
  aws_ecs_cluster_id   = module.ecs.demo-ecs-cluster_id
  ecs-service-role-arn = module.iam.ecs-service-role-arn
  aws_alb_arn          = module.ecs.ecs-load-balancer-arn
}

