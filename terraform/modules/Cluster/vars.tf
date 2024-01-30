variable "cluster_name" {
  type = string
}

variable "subnets_id" {
  type = list(string)
}

variable "instance_types" {
  type = list(string)
}

variable "node_size" {
  type = object({
    desired_size = number
    max_size     = number
    min_size     = number
  })
}

variable "remote_access" {
  type = object({
    ssh_key            = string
  })
}