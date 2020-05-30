# Oz Giat
# Requirments
###############################
#Inputs:
# vpc_id
# env-name
# vpc_region
#
# Tagged resources:
# VPC tags = [ framework: tf ]
# Subnets tags = [ Terraform: true ]
###############################

provider "aws" {
  shared_credentials_file = CREDENTIALS
  profile                 = "default"
  region                  = var.vpc_region
}


resource "aws_elasticache_replication_group" "elasticache_replication_group" {
  automatic_failover_enabled      = true
  replication_group_id            = var.env-name
  replication_group_description   = "description"
  node_type                       = "cache.m5.large"
  engine                          = "redis"
  number_cache_clusters           = 4
  engine_version                  = "2.8"
  subnet_group_name               = aws_elasticache_subnet_group.elasticache-redis-subnet-group.id
  port                            = 6379

  lifecycle {
    ignore_changes = ["number_cache_clusters"]
  }
}

resource "aws_elasticache_cluster" "elasticache_cluster" {
  cluster_id                      = var.env-name
  replication_group_id            = aws_elasticache_replication_group.elasticache_replication_group.id
}


resource "aws_elasticache_subnet_group" "elasticache-redis-subnet-group"{
  name                            = "${var.env-name}-subnet-group"
  subnet_ids                      = flatten([data.aws_subnet.subnet.*.id])
}



data "aws_subnet_ids" "subnet_ids" {
  vpc_id                            = data.aws_vpc.vpc.id
  tags = {
    Tier                            = "private"
  }
}
data "aws_subnet" "subnet" {
  count = length(data.aws_subnet_ids.subnet_ids.ids)
  id    = tolist(data.aws_subnet_ids.subnet_ids.ids)[count.index]
}
data "aws_vpc" "vpc"{
  id = var.vpc_id
}
data "aws_security_group" "vpc_sg" {
  tags = {
    Terraform                       = "true"
  }
}
data "aws_availability_zones" "available" {
  state = "available"
}

############### Test your outputs ################
output "available" {
  value = data.aws_availability_zones.available.names
}
output "subnets" {
  value = data.aws_subnet_ids.subnet_ids.ids
}
output "vpc" {
  value = data.aws_vpc.vpc.id
}
##################################################