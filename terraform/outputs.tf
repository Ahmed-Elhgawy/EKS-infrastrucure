output "db_info" {
  value = {
    db_name     = var.rds_creatation ? var.db_name : ""
    username    = var.rds_creatation ? var.username : ""
    password    = var.rds_creatation ? var.password : ""
    db_endpoint = [for i in module.database : i.db_endpoint]
  }
}
