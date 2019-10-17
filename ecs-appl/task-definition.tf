resource "aws_ecs_task_definition" "my-task" {
  family                   = "${var.ecs-service-name}-task"
  cpu                      = var.cpu
  memory                   = var.memory
  requires_compatibilities = ["EC2"]
  network_mode             = "bridge"
  container_definitions    = data.template_file.task-template.rendered

  volume {
    name = "rexray-${var.storage-type}-vol"
    docker_volume_configuration {
      scope         = "shared"
      autoprovision = true
      driver        = "rexray/${var.storage-type}"
      driver_opts = {
        size = 110
        volumetype = "gp2"
      }
    }
  }

  volume {
    name = "volume-heartbeat"
    host_path = "/var/run/docker.sock"
  }

  volume {
    name = "volume-metricbeat"
    host_path = "/var/run/docker.sock"
  }

}
