output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "vpc_arn" {
  value = aws_vpc.vpc.arn
}

output "gw_id" {
  value = aws_internet_gateway.gw.id
}

output "public_subnets_id" {
  value = [for i in aws_subnet.public_subnets : i.id]
}

output "private_subnets_id" {
  value = [for i in aws_subnet.private_subnets : i.id]
}

output "public_subnets_arn" {
  value = [for i in aws_subnet.public_subnets : i.arn]
}

output "private_subnets_arn" {
  value = [for i in aws_subnet.private_subnets : i.arn]
}

output "public_rt_id" {
  value = aws_route_table.public_rt.id
}

output "private_rt_id" {
  value = aws_route_table.private_rt.id
}