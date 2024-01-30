# EKS Module
Terraform module which creates AWS EKS (Kubernetes) resources. \
Module Arguments:
|Argument|Descripation|
|:---|:---|
|`cluster_name`|*(Required)* Name of the EKS cluster.|
|`subnets_id`|*(Required)* A list of subnet IDs where the nodes/node groups will be provisioned.|
|`instance_type`|*(Required)* List of instance types associated with the EKS Node Group|
|`node_size`|*(Required)* Configuration block with scaling settings contains `desired_size` which is Desired number of worker nodes, `max_size` which is maximum number of worker nodes, and `min_size` which is minium number of worker nodes|
|`remote_access`|*(Required)* Configuration block with remote access settings, contains `ssh_key` which is EC2 Key Pair name that provides access for remote communication with the worker nodes in the EKS Node Group|

Module Attribute:
|Attribute|Description|
|:---|:---|
|`cluster_endpoint`|Endpoint for your Kubernetes API server.|
|`cluster_certificate_authority_data`|Base64 encoded certificate data required to communicate with the cluster.|
