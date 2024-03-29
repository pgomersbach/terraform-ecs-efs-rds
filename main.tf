provider "aws" {
  region  = var.ecs-region-name
  profile = var.aws-profile-name
}

terraform {
  backend "s3" {
    bucket  = "mn-cd-terraform-state"
    key     = "mn-d01-cd"
    region  = "eu-central-1"
    profile = "mn-d01-cd"
    workspace_key_prefix = "workspace-"
  }
}

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
  source = "git::codecommit://mn-d01-cd@cd-tfmd-iam"
}

module "ec2" {
  source                    = "git::codecommit://mn-d01-cd@cd-tfmd-ec2"
  max-instance-size         = 9
  min-instance-size         = 3
  desired-capacity          = 3
  instance-type             = "c5.xlarge"
  application-name          = "${var.aws-profile-name}-ecs-cluster"
  unit-name                 = var.unit-name
  vpc-id                    = data.aws_vpc.default-vpc.id
  subnet-ids                = data.aws_subnet_ids.all-sub.ids
  ecs-instance-role-name    = module.iam.ecs-instance-role-name
  ecs-instance-profile-name = module.iam.ecs-instance-profile-name
  ecs-cluster-name          = "${var.aws-profile-name}-ecs-cluster-${terraform.workspace}" # "${var.aws-profile-name}-ecs-cluster"
  ecs-region-name           = var.ecs-region-name
  ecs-key-pair-name         = var.ecs-key-pair-name
}

module "rds" {
  source            = "git::codecommit://mn-d01-cd@cd-tfmd-rds"
  # source = "./rds"
  allocated_storage = "5"
  database_name     = "${var.production_database_name}"
  database_username = "${var.production_database_username}"
  database_password = "${var.production_database_password}"
  engine_version    = "11.5"
  multi_az          = true
  application-name  = "${var.aws-profile-name}-db-cluster"
  unit-name         = var.unit-name
  subnet_ids        = data.aws_subnet_ids.all-sub.ids 
  vpc_id            = data.aws_vpc.default-vpc.id
  instance_class    = "db.t2.micro"
}

module "ecs" {
  source           = "git::codecommit://mn-d01-cd@cd-tfmd-ecs"
  ecs-cluster-name = "${var.aws-profile-name}-ecs-cluster-${terraform.workspace}"
}

module "elasticsearch" {
  source                 = "git::codecommit://mn-d01-cd@cd-tfmd-ecs-appl"
  lb-port                = 9200
  ecs-service-name       = "elasticsearch"
  application-name       = "${var.aws-profile-name}"
  unit-name              = var.unit-name
  lb                     = ["alb"] # ["alb"] |  [] 
  memory                 = 4096
  cpu                    = 2048
  deployment-max         = 100
  deployment-min         = 0
  container-storage      = ["yes"] # ["yes"] | []
  storage-type           = "ebs" # efs | ebs | ""
  allocated-storage      = 80
  service-sched-strategy = "REPLICA" # DAEMON | REPLICA
  hosted-zone            = var.hosted-zone
  vpc-id                 = data.aws_vpc.default-vpc.id
  subnet-ids             = data.aws_subnet_ids.all-sub.ids
  av-names               = element(data.aws_availability_zones.available.names,0)
  aws_ecs_cluster_id     = module.ecs.ecs-cluster_id
  ecs-service-role-arn   = module.iam.ecs-service-role-arn
}

module "kibana" {
  source                 = "git::codecommit://mn-d01-cd@cd-tfmd-ecs-appl"
  lb-port                = 5601
  ecs-service-name       = "kibana"
  application-name       = "${var.aws-profile-name}"
  unit-name              = var.unit-name
  lb                     = ["alb"] # ["alb"] |  []
  target-lb-url          = "https://${module.elasticsearch.ecs-load-balancer-alias}"
  memory                 = 1024
  cpu                    = 512
  service-sched-strategy = "REPLICA" # DAEMON | REPLICA
  desired-count          = 2
  hosted-zone            = var.hosted-zone
  vpc-id                 = data.aws_vpc.default-vpc.id
  subnet-ids             = data.aws_subnet_ids.all-sub.ids
  av-names               = join(", ", data.aws_availability_zones.available.names)
  aws_ecs_cluster_id     = module.ecs.ecs-cluster_id
  ecs-service-role-arn   = module.iam.ecs-service-role-arn
}

module "apm-server" {
  source                 = "git::codecommit://mn-d01-cd@cd-tfmd-ecs-appl"
  lb-port                = 8200
  ecs-service-name       = "apm-server"
  application-name       = "${var.aws-profile-name}"
  unit-name              = var.unit-name
  lb                     = ["alb"] # ["alb"] |  []
  target-lb-url          = "https://${module.elasticsearch.ecs-load-balancer-alias}"
  kibana-lb-url          = "https://${module.kibana.ecs-load-balancer-alias}"
  memory                 = 512
  cpu                    = 256
  service-sched-strategy = "REPLICA" # DAEMON | REPLICA
  desired-count          = 2
  hosted-zone            = var.hosted-zone
  vpc-id                 = data.aws_vpc.default-vpc.id
  subnet-ids             = data.aws_subnet_ids.all-sub.ids
  av-names               = join(", ", data.aws_availability_zones.available.names)
  aws_ecs_cluster_id     = module.ecs.ecs-cluster_id
  ecs-service-role-arn   = module.iam.ecs-service-role-arn
}

module "beats" {
  source                 = "git::codecommit://mn-d01-cd@cd-tfmd-ecs-appl"
  lb-port                = 5601
  ecs-service-name       = "beats"
  application-name       = "${var.aws-profile-name}"
  unit-name              = var.unit-name
  lb                     = [] # ["alb"] |  []
  target-lb-url          = "https://${module.elasticsearch.ecs-load-balancer-alias}"
  kibana-lb-url          = "https://${module.kibana.ecs-load-balancer-alias}"
  apm-server-lb-url      = "https://${module.apm-server.ecs-load-balancer-alias}"
  memory                 = 256
  cpu                    = 128
  service-sched-strategy = "DAEMON" # DAEMON | REPLICA
  hosted-zone            = var.hosted-zone
  vpc-id                 = data.aws_vpc.default-vpc.id
  subnet-ids             = data.aws_subnet_ids.all-sub.ids
  av-names               = join(", ", data.aws_availability_zones.available.names)
  aws_ecs_cluster_id     = module.ecs.ecs-cluster_id
  ecs-service-role-arn   = module.iam.ecs-service-role-arn
}

