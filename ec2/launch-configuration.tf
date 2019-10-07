data "aws_ami" "ecs_ami" {
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
  image_id                    = "${data.aws_ami.ecs_ami.image_id}"
  instance_type               = var.instance-type
  iam_instance_profile        = var.ecs-instance-profile-name
  security_groups             = [var.security-group-id]
  associate_public_ip_address = "false"
  key_name                    = var.ecs-key-pair-name
  user_data                   = "${data.template_file.ecs-launch-configuration-user-data.rendered}"

  root_block_device {
    volume_type = "standard"
    volume_size = 100
    delete_on_termination = true
  }

  lifecycle {
    create_before_destroy = true
  }
}
