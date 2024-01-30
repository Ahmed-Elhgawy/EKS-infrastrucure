variable "vpc_name" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "public_subnets_cidr" {
  type    = list(string)
  default = []
}

variable "private_subnets_cidr" {
  type    = list(string)
  default = []
}

variable "availability_zones" {
  type = list(string)
}

variable "nat_gw" {
  type    = bool
  default = false
}
