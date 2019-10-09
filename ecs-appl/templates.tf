data "template_file" "task-template" {
  template = file("./ecs-appl/${var.ecs-service-name}.json")

/*  vars = {
    db_host     = var.rds-url
    db_name     = var.rds-dbname
    db_user     = var.rds-username
    db_password = var.rds-password
  }
*/
}

