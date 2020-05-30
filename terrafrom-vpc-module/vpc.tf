# Oz Giat
# Requirments
###############################
#Inputs:
# vpc_region
# vpc_name
# vpc_cidr
# public_subnets_cidr
# private_subnets_cidr
# azs
###############################


# VPC
provider "aws" {
  region                  = var.vpc_region
  shared_credentials_file = CREDENTIALS
  profile                 = "default"
}
resource "aws_vpc" "tf_vpc" {
  cidr_block              = var.vpc_cidr
  tags {
    Name                  = var.vpc_name
  }
}
# Internet Gateway
resource "aws_internet_gateway" "tf_igw" {
  vpc_id                  = aws_vpc.tf_vpc.id
  tags {
    Name                  = "main"
  }
}
# Subnets : public
resource "aws_subnet" "tf_public" {
  count                   = length(var.public_subnets_cidr)
  vpc_id                  = aws_vpc.tf_vpc.id
  cidr_block              = element(var.public_subnets_cidr,count.index)
  availability_zone       = element(var.azs,count.index)
  map_public_ip_on_launch = true
  tags {
    Name                  = "public-subnet-${count.index+1}"
    Tier                  = "public"
  }
}
# Subnets : private
resource "aws_subnet" "tf_private" {
  count                   = length(var.private_subnets_cidr)
  vpc_id                  = aws_vpc.tf_vpc.id
  cidr_block              = element(var.private_subnets_cidr,count.index)
  availability_zone       = element(var.azs,count.index)
  tags {
    Name                  = "private-subnet-${count.index+1}"
    Tier                  = "private"

  }
}
resource "aws_eip" "tf_eip" {
  vpc                     = true
  depends_on              = ["aws_internet_gateway.tf_igw"]
}
resource "aws_nat_gateway" "tf_nat_gateway" {
    allocation_id         = aws_eip.tf_eip.id
    subnet_id             = element(aws_subnet.tf_public.*.id, count.index)
    depends_on            = ["aws_internet_gateway.tf_igw"]
    tags                   = {
        Name              = "NAT"
    }
}
# Route table: attach Internet Gateway 
resource "aws_route_table" "tf_public_rt" {
  vpc_id                  = aws_vpc.tf_vpc.id
  route {
    cidr_block            = "0.0.0.0/0"
    #peering connection
    gateway_id            = aws_internet_gateway.tf_igw.id
  }
  tags {
    Name                  = "publicRouteTable"
  }
}
resource "aws_route_table" "tf_private_rt" {
  vpc_id                  = aws_vpc.tf_vpc.id
  route {
    cidr_block            = "0.0.0.0/0"
    #peering connection
    #nat gateway
    gateway_id            = aws_internet_gateway.tf_igw.id
  }
  tags {
    Name                  = "publicRouteTable"
  }
}
# Route table association with public subnets
resource "aws_route_table_association" "tf_rt_association" {
  count                   = length(var.public_subnets_cidr)
  subnet_id               = element(aws_subnet.tf_public.*.id,count.index)
  route_table_id          = aws_route_table.tf_public_rt.id
}
