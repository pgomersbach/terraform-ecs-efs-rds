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

data "aws_availability_zones" "available" {
  state = "available"
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
  max-instance-size         = 9
  min-instance-size         = 3
  desired-capacity          = 3
  instance-type             = "c5.xlarge"
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
  source           = "./ecs"
  ecs-cluster-name = "${var.aws-profile-name}-ecs-cluster"
}

module "elasticsearch" {
  source                 = "./ecs-appl"
  lb-port                = 9200
  ecs-service-name       = "elasticsearch"
  lb                     = ["alb"] # ["alb"] |  [] 
  memory                 = 4096
  cpu                    = 2048
  deployment-max         = 100
  deployment-min         = 0
  container-path         = "/esdata"
  storage-type           = "ebs"     # efs | ebs 
  service-sched-strategy = "REPLICA" # DAEMON | REPLICA
  hosted-zone            = var.hosted-zone
  vpc-id                 = data.aws_vpc.default-vpc.id
  subnet-ids             = data.aws_subnet_ids.all-sub.ids
  av-names               = element(data.aws_availability_zones.available.names,0)
  aws_ecs_cluster_id     = module.ecs.demo-ecs-cluster_id
  ecs-service-role-arn   = module.iam.ecs-service-role-arn
}

module "kibana" {
  source                 = "./ecs-appl"
  lb-port                = 5601
  ecs-service-name       = "kibana"
  lb                     = ["alb"] # ["alb"] |  []
  target-lb-url          = "http://${module.elasticsearch.ecs-load-balancer-alias}"
  memory                 = 2048
  cpu                    = 1024
  container-path         = "/esdata"
  storage-type           = "ebs"     # efs | ebs
  service-sched-strategy = "REPLICA" # DAEMON | REPLICA
  desired-count          = 2
  hosted-zone            = var.hosted-zone
  vpc-id                 = data.aws_vpc.default-vpc.id
  subnet-ids             = data.aws_subnet_ids.all-sub.ids
  av-names               = join(", ", data.aws_availability_zones.available.names)
  aws_ecs_cluster_id     = module.ecs.demo-ecs-cluster_id
  ecs-service-role-arn   = module.iam.ecs-service-role-arn
}

module "apm-server" {
  source                 = "./ecs-appl"
  lb-port                = 8200
  ecs-service-name       = "apm-server"
  lb                     = ["alb"] # ["alb"] |  []
  target-lb-url          = "http://${module.elasticsearch.ecs-load-balancer-alias}"
  kibana-lb-url          = "http://${module.kibana.ecs-load-balancer-alias}"
  memory                 = 1024
  cpu                    = 512
  container-path         = "/esdata"
  storage-type           = "ebs"     # efs | ebs
  service-sched-strategy = "REPLICA" # DAEMON | REPLICA
  desired-count          = 2
  hosted-zone            = var.hosted-zone
  vpc-id                 = data.aws_vpc.default-vpc.id
  subnet-ids             = data.aws_subnet_ids.all-sub.ids
  av-names               = join(", ", data.aws_availability_zones.available.names)
  aws_ecs_cluster_id     = module.ecs.demo-ecs-cluster_id
  ecs-service-role-arn   = module.iam.ecs-service-role-arn
}

module "beats" {
  source                 = "./ecs-appl"
  lb-port                = 5601
  ecs-service-name       = "beats"
  lb                     = [] # ["alb"] |  []
  target-lb-url          = "http://${module.elasticsearch.ecs-load-balancer-alias}"
  kibana-lb-url          = "http://${module.kibana.ecs-load-balancer-alias}"
  apm-server-lb-url      = "http://${module.apm-server.ecs-load-balancer-alias}"
  memory                 = 512
  cpu                    = 256
  container-path         = "/esdata"
  storage-type           = "ebs"     # efs | ebs
  service-sched-strategy = "DAEMON" # DAEMON | REPLICA
  hosted-zone            = var.hosted-zone
  vpc-id                 = data.aws_vpc.default-vpc.id
  subnet-ids             = data.aws_subnet_ids.all-sub.ids
  av-names               = join(", ", data.aws_availability_zones.available.names)
  aws_ecs_cluster_id     = module.ecs.demo-ecs-cluster_id
  ecs-service-role-arn   = module.iam.ecs-service-role-arn
}

