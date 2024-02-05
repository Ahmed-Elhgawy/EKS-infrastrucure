resource "aws_db_subnet_group" "db-sbg" {
  name       = "db-sbg"
  subnet_ids = var.db_subnets_id

  tags = {
    Name = "DB_subnet_group"
  }
}

resource "aws_db_instance" "db" {
  allocated_storage      = 10
  db_name                = var.db_name
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  username               = var.master_user.username
  password               = var.master_user.password
  parameter_group_name   = "default.mysql8.0"
  db_subnet_group_name   = aws_db_subnet_group.db-sbg.name
  vpc_security_group_ids = var.db_sg
  publicly_accessible    = false
  skip_final_snapshot    = true

  tags = {
    Name = "DB"
  }
}
