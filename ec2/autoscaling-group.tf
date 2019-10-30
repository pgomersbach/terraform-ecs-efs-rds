resource "aws_autoscaling_group" "ecs-autoscaling-group" {
  name                 = var.autoscaling-group-name
  max_size             = var.max-instance-size
  min_size             = var.min-instance-size
  desired_capacity     = var.desired-capacity
  vpc_zone_identifier  = var.subnet-ids
  launch_configuration = aws_launch_configuration.ecs-launch-configuration.name
  termination_policies = ["NewestInstance"]
  health_check_type    = "ELB"

  lifecycle {
    create_before_destroy = true
    ignore_changes        = ["desired_capacity"]
  }

  tags = [
    {
      key                 = "ElasticSearch"
      value               = "cd-es"
      propagate_at_launch = true
    }
  ]
}

resource "aws_autoscaling_policy" "ecs-autoscaling-policy-memory" {
  name = "memory-reservation"

  autoscaling_group_name    = var.autoscaling-group-name
  depends_on                = [aws_autoscaling_group.ecs-autoscaling-group]
  policy_type               = "TargetTrackingScaling"

  target_tracking_configuration {
    customized_metric_specification {
      metric_dimension {
        name  = "ClusterName"
        value = var.ecs-cluster-name
      }

      metric_name = "MemoryReservation"
      namespace   = "AWS/ECS"
      statistic   = "Maximum"
    }

    target_value = "60"
  }
}

resource "aws_autoscaling_policy" "ecs-autoscaling-policy-cpu" {
  name = "cpu-reservation"

  autoscaling_group_name    = var.autoscaling-group-name
  depends_on                = [aws_autoscaling_group.ecs-autoscaling-group]
  policy_type               = "TargetTrackingScaling"

  target_tracking_configuration {
    customized_metric_specification {
      metric_dimension {
        name  = "ClusterName"
        value = var.ecs-cluster-name
      }

      metric_name = "CPUReservation"
      namespace   = "AWS/ECS"
      statistic   = "Maximum"
    }

    target_value = "60"
  }
}

