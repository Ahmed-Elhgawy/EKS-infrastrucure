# # *********************** CONFIGURE MODULES ***********************
module "network" {
  source = "./modules/Network"

  vpc_name             = "Kubernetes_VPC"
  vpc_cidr             = var.cidr
  availability_zones   = var.availability_zones
  public_subnets_cidr  = var.public_subnets_cidr
  private_subnets_cidr = var.private_subnets_cidr
  nat_gw               = var.nat_gw
}

module "security" {
  source = "./modules/Security"

  vpc_id         = module.network.vpc_id
  db_cidr        = var.cidr
  rds_creatation = var.rds_creatation

  depends_on = [module.network]
}

module "database" {
  count  = var.rds_creatation ? 1 : 0
  source = "./modules/Database"

  db_name       = var.db_name
  db_subnets_id = module.network.private_subnets_id
  db_sg         = [module.security.db_sg]
  master_user = {
    username = var.username
    password = var.password
  }

  depends_on = [
    module.network,
    module.security
  ]
}

module "eks" {
  source = "./modules/Cluster"

  cluster_name   = var.cluster_name
  subnets_id     = module.network.public_subnets_id
  instance_types = var.instance_types
  node_size = {
    desired_size = var.node_size.desired_size
    max_size     = var.node_size.max_size
    min_size     = var.node_size.min_size
  }
  remote_access = {
    ssh_key = var.ssh_key
  }

  depends_on = [
    module.network
  ]
}

# *********************** GET NODE WORKERS PUBLIC IPS ***********************
resource "null_resource" "edit_ansibel_inventory" {
  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = <<-EOT
      aws ec2 describe-instances --query 'Reservations[*].Instances[*].PublicIpAddress' --region ${var.region} --output text > public_ips.tmp
      sed -i '/node_workers_ip/r public_ips.tmp' ../ansible/inventory && sed -i '/node_workers_ip/d' ../ansible/inventory
      rm -r public_ips.tmp
    EOT
  }

  depends_on = [
    module.eks
  ]
}

# *********************** INSTALL DOCKER USING ANSIBLE ***********************
resource "null_resource" "run_ansible_playbook" {
  provisioner "local-exec" {
    working_dir = "../ansible"
    interpreter = ["bash", "-c"]
    command     = <<-EOT
      sleep 30
      ansible-playbook site.yml
    EOT
  }

  depends_on = [
    null_resource.edit_ansibel_inventory
  ]
}

# *********************** CONNECT TO EKS CLUSTER ***********************
resource "null_resource" "eks-connect" {
  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = <<-EOT
        aws eks --region ${var.region} update-kubeconfig --name ${var.cluster_name}
    EOT
  }

  depends_on = [module.eks]
}
