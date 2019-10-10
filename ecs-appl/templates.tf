data "template_file" "task-template" {
  template = file("./ecs-appl/default.json")

  vars = {
    ecs-service-name = "${var.ecs-service-name}"
    image            = "${var.image}"
    port             = "${var.lb-port}"
    memory           = "${var.memory}"
    cpu              = "${var.cpu}"
    container-path   = "${var.container-path}"
    storage-type     = "${var.storage-type}"
  }
}

