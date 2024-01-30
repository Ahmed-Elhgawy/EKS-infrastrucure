variable "region" {
  type    = string
  default = "us-east-1"
}

variable "availability_zones" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnets_cidr" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets_cidr" {
  type    = list(string)
  default = []
}

variable "nat_gw" {
  type    = bool
  default = false
}

variable "cluster_name" {
  type    = string
  default = "kubernetesCluster"
}

variable "instance_types" {
  type    = list(string)
  default = ["t3.medium"]
}

variable "node_size" {
  type = object({
    desired_size = number
    max_size     = number
    min_size     = number
  })
  default = {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }
}

variable "ssh_key" {
  type    = string
}
