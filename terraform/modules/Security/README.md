# Security Module
Terraform module which creates AWS Security Groups that allow all outbound traffic and spacific inbound traffic. \
Module Arguments:
|Argument|Descripation|
|:---|:---|
|`vpc_id`|*(Required)* The ID of the VPC where the security groups will associate|
|`rds_creatation`|*(Optional)* Controls if a database security group should be created ***Default: true***|
|`db_cidr`|*(Required)* The IPv4 CIDR block that will be allowed to access database instance|

Module Attributes:
|Attribute|Description|
|:---|:---|
|`db_sg`|The database security group ID|
