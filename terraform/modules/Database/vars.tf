variable "db_subnets_id" {
  type = list(string)
}

variable "db_name" {
  type = string
}

variable "master_user" {
  type = object({
    username = string
    password = string
  })
}

variable "db_sg" {
  type = list(string)
}
