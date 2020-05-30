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
resource "aws_lb" "nlb" {
  for_each            = toset(var.nlb)
  name                = "${var.env-name}-${each.key}"
  internal            = false
  load_balancer_type  = "network"
  subnets             = flatten([data.aws_subnet.subnet.*.id])


  enable_deletion_protection = true
  tags = {
    Service           = each.key
    framework         = "tf"
  }
}
resource "aws_lb_target_group" "instance-tg" {
  for_each            = toset(var.nlb)
  name                = "${var.env-name}-${each.key}"
  port                = "8080"
  protocol            = "TCP"
  vpc_id              = data.aws_vpc.selected.id
  tags = {
    Service           = each.key
    framework         = "tf"
  }
}

resource "aws_lb_listener" "listeners"{
  for_each            = toset(var.nlb)
  load_balancer_arn   = aws_lb.nlb[each.key].arn
  port                = "8080"
  protocol            = "TCP"
  default_action {
    type              = "forward"
    target_group_arn  = aws_lb_target_group.instance-tg[each.key].arn
  }
}
data "aws_subnet_ids" "subnets" {
  vpc_id              = data.aws_vpc.selected.id
  tags = {
    Tier              = "public"
  }
}


data "aws_subnet" "subnet" {
  count = length(data.aws_subnet_ids.subnets.ids)
  id    = tolist(data.aws_subnet_ids.subnets.ids)[count.index]
}
data "aws_vpc" "selected" {
  id = var.vpc_id
}

############### Test your outputs ################
output "test" {
  value = data.aws_subnet_ids.subnets.ids
}
##################################################