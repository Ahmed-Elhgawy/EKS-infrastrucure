variable "vpc_id" {
  type = string
}

variable "rds_creatation" {
  type    = bool
  default = true
}

variable "db_cidr" {
  type = string
}
