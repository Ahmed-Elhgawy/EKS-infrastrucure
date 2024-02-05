# Database Module
Terraform modules whish creates AWS RDS (Relational Database Service) resources. \
Module Arguments:
|Argument|Descripation|
|:---|:---|
|`db_subnets_id`|*(Required)* A list of VPC subnet IDs|
|`db_name`|*(Required)* The name of database to be create when the database instance is created|
|`master_user`|Configuration block that contains `username` the username for the master DB user , and `password` the password for the master DB user|
|`db_sg`|*(Required)* list of VPC security groups to be associate|

Module Attributes:
|Attribute|Description|
|:---|:---|
|`db_endpoint`|The database connection endpoint|
