data "template_file" "task-template" {
  template = file("./ecs-appl/${var.ecs-service-name}.json")

  vars = {
    ecs-service-name = "${var.ecs-service-name}"
    port             = "${var.lb-port}"
    memory           = "${var.memory}"
    cpu              = "${var.cpu}"
    container-path   = "${var.container-path}"
    storage-type     = "${var.storage-type}"
  }
}

