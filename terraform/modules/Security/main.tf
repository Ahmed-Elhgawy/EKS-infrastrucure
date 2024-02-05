resource "aws_security_group" "db_sg" {
  count       = var.rds_creatation ? 1 : 0
  name        = "db_sg"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = var.vpc_id

  tags = {
    Name = "db_sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_rds_access" {
  count       = var.rds_creatation ? 1 : 0
  security_group_id = aws_security_group.db_sg[0].id
  cidr_ipv4         = var.db_cidr
  from_port         = 3306
  ip_protocol       = "tcp"
  to_port           = 3306
}

resource "aws_vpc_security_group_egress_rule" "rds_egress_rule" {
  count       = var.rds_creatation ? 1 : 0
  security_group_id = aws_security_group.db_sg[0].id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
