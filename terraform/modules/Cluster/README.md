# Cluster Module
A module that creates an AWS EKS (Elastic Kubernetes Service), it creates EKS Cluster, Node Group, and Cluster Addons to install AWS-EBS-CSI-Driver on cluster. \
Module Arguments:
|Argument|Descripation|
|:---|:---|
|`Cluster_name`|*(Required)* Name of the EKS Cluster. Must be between 1-100 characters in length. Must begin with an alphanumeric character, and must only contain alphanumeric characters, dashes and underscores|
|`Subnet_id`|*(Required)* List of subnet IDs. Must be in at least two different availability zones. Amazon EKS creates cross-account elastic network interfaces in these subnets to allow communication between your worker nodes and the Kubernetes control plane|
|`instance_type`|*(Optional)* List of instance types associated with the EKS Node Group|
|`remote_access`|*(Optional)* Configuration block with remote access settings, that contains `ssh_key` which is EC2 Key Pair name that provides access for remote communication with the worker nodes in the EKS Node Group|
|`node_size`|*(Required)* Configuration block with scaling settings, that contains `desired_size` the desired number of worker nodes ,`max_size` the maximum number of worker nodes ,and `min_size` the minimum number of worker nodes|

Module Attributes:
|Attribute|Description|
|:---|:---|
|`cluster_endpoint`|Endpoint for Kubernetes API server|
|`cluster_certificate_authority_data`|Base64 encoded certificate data required to communicate with your cluster|
