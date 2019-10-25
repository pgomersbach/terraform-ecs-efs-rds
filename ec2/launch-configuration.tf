data "aws_ami" "ecs-ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-2.0.*-x86_64-ebs"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "template_file" "ecs-launch-configuration-user-data" {
  template = file("${path.module}/user-data.tpl")
  vars = {
    ecs-cluster-name = var.ecs-cluster-name
    ecs-region-name  = var.ecs-region-name
  }
}

resource "aws_launch_configuration" "ecs-launch-configuration" {
  image_id                    = "${data.aws_ami.ecs-ami.image_id}"
  instance_type               = var.instance-type
  iam_instance_profile        = var.ecs-instance-profile-name
  security_groups             = [aws_security_group.instance-security-group.id]
  associate_public_ip_address = "false"
  key_name                    = var.ecs-key-pair-name
  user_data                   = "${data.template_file.ecs-launch-configuration-user-data.rendered}"

  root_block_device {
    volume_type           = "standard"
    volume_size           = 100
    delete_on_termination = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "instance-security-group" {
  name        = "instance-security-group"
  description = "ephemeral, EFS and SSH"
  vpc_id      = var.vpc-id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // TCP
  ingress {
    from_port   = 32768
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // UDP
  ingress {
    from_port   = 32768
    to_port     = 65535
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  // EFS
  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // elastic
  ingress {
    from_port   = 9200
    to_port     = 9200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // elastic
  ingress {
    from_port   = 9300
    to_port     = 9300
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // apm-server
  ingress {
    from_port   = 8200
    to_port     = 8200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

