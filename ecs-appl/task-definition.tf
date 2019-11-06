resource "aws_ecs_task_definition" "my-task" {
  family                   = "${var.ecs-service-name}-task"
  cpu                      = var.cpu
  memory                   = var.memory
  requires_compatibilities = ["EC2"]
  network_mode             = "bridge"
  container_definitions    = data.template_file.task-template.rendered
  tags        = {
    AplicationName = var.application-name,
    UnitName       = var.unit-name
  }

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in [${var.av-names}]"
  }

  volume {
    name = "rexray-${var.storage-type}-vol"
    docker_volume_configuration {
      scope         = "shared"
      autoprovision = true
      driver        = "rexray/${var.storage-type}"
      driver_opts = {
        size       = 110
        volumetype = "gp2"
      }
    }
  }

  volume {
    name      = "volume-filebeat-sock"
    host_path = "/var/run/docker.sock"
  }

  volume {
    name      = "volume-filebeat-containers"
    host_path = "/var/lib/docker/containers"
  }

  volume {
    name      = "volume-filebeat-log"
    host_path = "/var/log"
  }

  volume {
    name      = "volume-heartbeat-sock"
    host_path = "/var/run/docker.sock"
  }

  volume {
    name      = "volume-metricbeat-sock"
    host_path = "/var/run/docker.sock"
  }

  volume {
    name      = "volume-metricbeat-cgroup"
    host_path = "/sys/fs/cgroup"
  }

  volume {
    name      = "volume-metricbeat-proc"
    host_path = "/proc"
  }

}
