output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "vpc_cidr_block" {
  value = aws_vpc.vpc.cidr_block
}

output "vpc_default_security_group_id" {
  value = aws_vpc.vpc.default_security_group_id
}

output "public_subnets" {
  value = aws_subnet.vpc_public_subnets
}

output "private_subnets" {
  value = aws_subnet.vpc_private_subnets
}

output "rds_security_group" {
  value = aws_security_group.rds_security_group.id
}

output "docdb_security_group" {
  value = aws_security_group.docdb_security_group.id
}

output "jumpbox_sg" {
  value = aws_security_group.jumpbox_sg.id
}

output "opensearch_security_group" {
  value = aws_security_group.opensearch_security_group.id
}