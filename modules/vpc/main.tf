resource "aws_vpc" "vpc" {
  cidr_block = var.cidr_block

  enable_dns_support = true

  enable_dns_hostnames = true

  tags = merge(
    { Name = "${var.project_name}-vpc" }
  )
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = merge(
    { Name = "${var.project_name}-vpc-igw" }
  )
}

resource "aws_subnet" "vpc_public_subnets" {
  count                   = var.subnet_count
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = element(var.public_subnet_cidrs, count.index)
  availability_zone       = "${var.region}${element(var.azs, count.index)}"
  map_public_ip_on_launch = true

  tags = merge(
    { Name = "${var.project_name}-public-subnet-${count.index + 1}" },
    var.eks_subnet_tags,
    var.eks_alb_subnet_tags
  )
}

resource "aws_subnet" "vpc_private_subnets" {
  count             = var.subnet_count
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = element(var.private_subnet_cidrs, count.index)
  availability_zone = "${var.region}${element(var.azs, count.index)}"

  tags = merge(
    { Name = "${var.project_name}-private-subnet-${count.index + 1}" },
    var.eks_subnet_tags
  )
}

resource "aws_eip" "nat_eips" {
  count = var.subnet_count
  depends_on = [
    aws_internet_gateway.igw
  ]
  tags = merge(
    { Name = "${var.project_name} nat gateway ${count.index + 1}" }
  )
}

resource "aws_nat_gateway" "nat_gateways" {
  count         = var.subnet_count
  allocation_id = aws_eip.nat_eips[count.index].id
  subnet_id     = aws_subnet.vpc_public_subnets[count.index].id

  tags = merge(
    { Name = "${var.project_name} gateway - ${count.index + 1}" }
  )
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(
    { Name = "${var.project_name} public route table" }
  )
}

resource "aws_route_table" "private_route_tables" {
  count = var.subnet_count
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateways[count.index].id
  }

  tags = merge(
    {Name         = "${var.project_name} private route table ${count.index+1}"}
  )
}

resource "aws_route_table_association" "public_association" {
    count = var.subnet_count
  subnet_id = aws_subnet.vpc_public_subnets[count.index].id

  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "private_association" {
    count = var.subnet_count
  subnet_id = aws_subnet.vpc_private_subnets[count.index].id

  route_table_id = aws_route_table.private_route_tables[count.index].id
}

# security group

resource "aws_security_group" "rds_security_group" {
  name        = "obase-rds-sg"
  description = "RDS Security Group"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description     = ""
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.jumpbox_sg.id]
    cidr_blocks     = []
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "docdb_security_group" {
  name        = "obase-docdb-sg"
  description = "DocumentDB Security Group"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description     = ""
    from_port       = 27017
    to_port         = 27017
    protocol        = "tcp"
    security_groups = [aws_security_group.jumpbox_sg.id]
    cidr_blocks     = []
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "opensearch_security_group" {
  name        = "obase-opensearch-sg"
  description = "OpenSearch Security Group"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description     = ""
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.jumpbox_sg.id]
    cidr_blocks     = []
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "jumpbox_sg" {
  name        = "jumpbox_sg"
  description = "Jumpbox Security Group"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = ""
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}
