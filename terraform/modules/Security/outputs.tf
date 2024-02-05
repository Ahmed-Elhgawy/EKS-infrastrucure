output "db_sg" {
  value = var.rds_creatation ? aws_security_group.db_sg[0].id:""
}
