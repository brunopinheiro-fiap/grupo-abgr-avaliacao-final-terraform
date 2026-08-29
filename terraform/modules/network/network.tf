# RESOURCE: VPC
resource "aws_vpc" "vpc" {
    cidr_block           = var.vpc_cidr
    enable_dns_hostnames = true
    tags = {
        Name = "vpc-dev-grupo-abgr"
    }
}

# RESOURCE: INTERNET GATEWAY
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.vpc.id
}

# RESOURCE: SUBNETS
resource "aws_subnet" "sn_pub_az1a" {
    vpc_id                  = aws_vpc.vpc.id
    availability_zone       = "us-east-1a"
    cidr_block              = var.subnet_az1a_cidr
    map_public_ip_on_launch = true
}

resource "aws_subnet" "sn_pub_az1b" {
    vpc_id                  = aws_vpc.vpc.id
    availability_zone       = "us-east-1b"
    cidr_block              = var.subnet_az1b_cidr
    map_public_ip_on_launch = true
}

# RESOURCE: ROUTE TABLES FOR THE SUBNETS
resource "aws_route_table" "rt_pub" {
    vpc_id = aws_vpc.vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
}

# RESOURCE: ROUTE TABLES ASSOCIATION TO SUBNETS
resource "aws_route_table_association" "rt_pub_sn_pub_az1a" {
  subnet_id      = aws_subnet.sn_pub_az1a.id
  route_table_id = aws_route_table.rt_pub.id
}

resource "aws_route_table_association" "rt_pub_sn_pub_az1b" {
  subnet_id      = aws_subnet.sn_pub_az1b.id
  route_table_id = aws_route_table.rt_pub.id
}