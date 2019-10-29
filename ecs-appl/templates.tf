data "template_file" "task-template" {
  template = file("./ecs-appl/tasks/${var.ecs-service-name}.json")

  vars = {
    ecs-service-name  = "${var.ecs-service-name}"
    hosted-zone       = "${var.hosted-zone}"
    target-lb-url     = "${var.target-lb-url}"
    kibana-lb-url     = "${var.kibana-lb-url}"
    apm-server-lb-url = "${var.apm-server-lb-url}"
    port              = "${var.lb-port}"
    memory            = "${var.memory}"
    cpu               = "${var.cpu}"
    container-path    = "${var.container-path}"
    storage-type      = "${var.storage-type}"
  }
}

