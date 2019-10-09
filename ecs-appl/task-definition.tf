resource "aws_ecs_task_definition" "apache-task" {
  family = "demo-sample-definition"
  cpu    = 512
  memory = 1024
  requires_compatibilities = ["EC2"]
  network_mode = "bridge"
  container_definitions = data.template_file.task-template.rendered

  volume {
    name      = "rexray-efs-vol"
    docker_volume_configuration {
      scope         = "shared"
      autoprovision = true
      driver        = "rexray/efs"
    }
  }
}
