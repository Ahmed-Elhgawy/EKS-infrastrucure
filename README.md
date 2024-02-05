# EKS Infrastructure
In this repository; using terraform as IaC (Infrastructure as a code) tool, An EKS (Elastic Kubernetes Service) Cluster will be provisioned on AWS. \
And using ansible as management toot to install docker on cluster worker nodes to be able to perform docker command ad build docker images through them.

## Git Started
To quick start you can see [Get Started👇](#start-deploying).

## Terraform 
#### Terraform Modules:
1. [**Network Module**](./terraform/modules/Network/)
2. [**Security Module**](./terraform/modules/Security/)
3. [**Database Module**](./terraform/modules/Database/)
4. [**Cluster Module**](./terraform/modules/Cluster/)

#### Terraform files:
|**`providers.tf`**|**The file where is all providers used**|
|:---|:---|
|**`main.tf`**|**The file where all modules attachs together and run the ansible playbook on cluster worker nodes**|
|**`ingress_controller.tf`**|**The file that contains terraform code to deploy ingress-nginx-controller in EKS Cluster**|
|**`jenkins.tf`**|**The file that contains terraform code to deploy jenkins in EKS Cluster**|
|**`vars.tf`**|**The file that contains all variables used in terraform code**|
|**`outputs.tf`**|**The file that conatins outputs**|

#### Terraform Variables:
|Variable|Description|Type|Default|
|:---|:---|:---|:---|
|`region`|*(Optional)* AWS Region where the provider will operate|*string*|"us-east-a"|
|`cidr`|*(Optional)* The IPv4 CIDR block for the VPC|*string*|"10.0.0.0/16"|
|`public_subnets_cidr`|*(Optional)* The IPv4 CIDR block for the subnet. Need to be subnet of `vpc_cidr`. If not given, there no public subnets will be created in vpc|*list(string)*|["10.0.1.0/24", "10.0.2.0/24"]|
|`private_subnets_cidr`|*(Optional)* The IPv4 CIDR block for the subnet. Need to be subnet of `vpc_cidr`. If not given, there no private subnets will be created in vpc|*list(string)*|[ ]|
|`availability_zones`|*(Optional)* AZ for the subnet. Need to be in same length or longer than `public_subnets_cidr` or `private_subnets_cidr`|*list(string)*|["us-east-1a", "us-east-1b", "us-east-1c"]|
|`nat_gw`|*(Optional)* Controls if a nat gateway route should be created to give internet access to the private subnets|*boolen*|false|
|`cluster_name`|*(Optional)* Name of the EKS cluster|*string*|"kubernetesCluster"|
|`instance_type`|*(Optional)* List of instance types associated with the EKS Node Group|*list(string)*|["t2.medium"]|
|`node_size`|*(Optional)* Configuration block with scaling settings contains `desired_size` which is Desired number of worker nodes, `max_size` which is maximum number of worker nodes, and `min_size` which is minium number of worker nodes|*object*|desired_size=1, max_size=2, min_size=1
|`ssh_key`|*(Required)* which is EC2 Key Pair name that provides access for remote communication with the worker nodes in the EKS Node Group|*string*|
|`rds_creatation`|*(Optional)* Controls if a database module should be created|*bool*|false|
|`db_name`|*(Optional)* The name of database to be create when the database instance is created|*string*|kubernetes_DB|
|`username`|*(Optional)* The username for the master DB user|*string*|root|
|`password`|*(Optional)* The password for the master DB user|*string*|rootdb123|

#### Enter Terraform Variables
There are three ways to enter variables
1. remain in default variables and run the code, and enter `ssh_key` in real time
```
terraform apply -auto-approve
```
2. create a **terraform.tfvars** file and add all variables you need, see [`Terraform Variables`](#terraform-variables) to know more
3. add the variable you need in the command
```
terraform apply -auto-approve -var ssh_key="key_pair.pem"
```
## Ansible
The ansible playbook runs when terraform is applyied. this ansible playbooh is used to install docker on cluster worker nodes 

#### Note
Before you run terraform code you need to make sure that the path to key pair used is the same in **inventory** file 
```
[node_workers]
node_workers_ip

[node_workers:vars]
ansible_ssh_private_key_file = </path/to/key/pair>
```

## Helm
The helm repositories used:
1. [jenkins](https://charts.jenkins.io)
2. [ingress-nginx-controller](https://kubernetes.github.io/ingress-nginx)

## Start Deploying
#### Prerequisite:
1. AWS CLI
2. Terraform
3. kubectl
4. helm3
5. ansible

To start deploying EKS cluster on AWS account,you should add your key pair as variable and check its path first
[`ssh_key variable`](#enter-terraform-variables), [`ssh_key path`](#note). \
#### Steps to start:
1. Add AWS account credential
```
aws cofigure
```
2. Move to terraform directory
```
cd terraform/
```
3. Initialize terraform
```
terraform init && terraform plan
```
4. Apply terraform code
```
terraform apply -auto-approve
```

## Jenkins
#### Connet to jenkins
To get the admin password 
```
kubectl exec -n jenkins -it svc/jenkins -c jenkins -- /bin/cat /run/secrets/additional/chart-admin-password && echo
```
and then to connect to jenkins interface through your localhost [`http://localhost:8080`](http://localhost:8080) run th command
```
kubectl port-forward -n jenkins svc/jenkins 8080
```

#### Note-1
To give jenkins agants administrator permession use **jenkins-admin** ServiceAccount

#### Note-2
In case your run jenkins pipeline contains docker command you need to change the image for kubernetes jenkins agant. \
through jenkins interface in **manage jenkins > clouds > kubernetes > pod template > default**

## Applications to test
to test jenkins pipeline with simple applications you can use
1. [NodeJsApp](https://github.com/Ahmed-Elhgawy/NodeJsApp.git) for application without using database
2. [pythonApp](https://github.com/Ahmed-Elhgawy/pythonApp.git) for application using database

make sure you edit [this part](#note-2) before using application