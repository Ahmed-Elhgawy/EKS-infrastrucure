# Network Module
A module that is used to create AWS standard network that contain VPC, Subnet (public and private), route tables, EIP, NAT gateway, and internet gateway.\
Module Arguments:
|Argument|Descripation|
|:---|:---|
|`vpc_name`|*(Required)* The name of the VPC.|
|`vpc_cidr`|*(Required)* The IPv4 CIDR block for the VPC.|
|`public_subnets_cidr`|*(Optional)* The IPv4 CIDR block for the subnet. Need to be subnet of `vpc_cidr`. If not given, there no public subnets will be created in vpc|
|`private_subnets_cidr`|*(Optional)* The IPv4 CIDR block for the subnet. Need to be subnet of `vpc_cidr`. If not given, there no private subnets will be created in vpc|
|`availability_zones`|*(Required)* AZ for the subnet. Need to be in same length or longer than `public_subnets_cidr` or `private_subnets_cidr`|
|`nat_gw`|*(Optional)* Controls if a nat gateway route should be created to give internet access to the private subnets. ***Default: false***|

Module Attribute:
|Attribute|Description|
|:---|:---|
|`vpc_id`|The ID of the VPC.|
|`vpc_arn`|Amazon Resource Name (ARN) of VPC.|
|`gw_id`|The ID of the Internet Gateway.|
|`nat_id`|The ID of the NAT Gateway.|
|`eip_id`|Contains the EIP allocation ID.|
|`public_subnets_id`|The ID of the subnet.|
|`private_subnets_id`|The ID of the subnet.|
|`public_subnets_arn`|The ARN of the subnet.|
|`private_subnets_arn`|The ARN of the subnet.|
|`public_rt_id`|The ID of the public routing table.|
|`private_rt_id`|The ID of the private routing table.|
