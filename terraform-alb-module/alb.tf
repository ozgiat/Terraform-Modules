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
########################################


provider "aws" {
  shared_credentials_file = CREDENTIALS
  profile                 = "default"
  region                  = var.vpc_region
}
resource "aws_lb" "alb" {
  for_each            = toset(var.alb)
  name                = "${var.env-name}-${each.key}"
  internal            = false #/true
  load_balancer_type  = "application"
  subnets             = flatten([data.aws_subnet.subnet.*.id])
  enable_deletion_protection = false
  tags = {
    Service           = each.key
    framework         = "tf"
  }
}
resource "aws_lb_target_group" "instance-tg" {
  for_each            = toset(var.alb)
  name                = "${var.env-name}-${each.key}"
  port                = "8080"
  protocol            = "HTTP"
  vpc_id              = data.aws_vpc.vpc.id

  tags = {
    Service           = each.key
    framework         = "tf"
  }
}
resource "aws_lb_listener" "listeners"{
 for_each            = toset(var.alb)
 load_balancer_arn   = aws_lb.alb[each.key].arn
 port                = "443"
 protocol            = "HTTPS"
 certificate_arn     = data.aws_acm_certificate.example

 default_action {
   type              = "forward"
   target_group_arn  = aws_lb_target_group.instance-tg[each.key].arn
 }
}
data aws_acm_certificate "certs"{
  domain   = "*.example.com"
  tags = {
    framework         = "tf"
  }
}

data "aws_subnet_ids" "subnets" {
  vpc_id              = data.aws_vpc.vpc.id
  tags = {
    Tier              = "public"
   }
}
data "aws_subnet" "subnet" {
  count = length(data.aws_subnet_ids.subnets.ids)
  id    = tolist(data.aws_subnet_ids.subnets.ids)[count.index]
}
data "aws_vpc" "vpc" {
  id = var.vpc_id
}
data "aws_acm_certificate" "example" {
  domain = "*.example.com"
}


############### Test your outputs ################
output "vpc" {
  value = data.aws_vpc.vpc.id
}

output "test_output" {
  value = data.aws_acm_certificate.certs.arn
}
##################################################
