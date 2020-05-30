provider "aws" {
  shared_credentials_file = CREDENTIALS
  profile                 = "default"
  region                  = var.vpc_region
}

### Launch Instances
resource "aws_instance" "app" {
  subnet_id               = element(data.aws_subnet_ids.subnets.ids, count.index)
  count                   = var.count
  key_name                = "KEY_NAME"
  ami                     = data.aws_ami.ubuntu_ami.id
  instance_type           = var.instanceType
  associate_public_ip_address = var.publicip
  security_groups         = [
    data.aws_security_group.sg.id]

  root_block_device {
    volume_size = 80
  }
  tags                    = {
    Name                  = var.instanceName
    service               = var.serviceName
    environment           = var.envName
    serviceVersion        = var.serviceVersion
    releaseVersion        = var.releaseVersion

  }
}

data "aws_vpc"  "vpc" {
  tags                    = {
    Name                  = var.aws_vpc
  }
}

data "aws_ami" "ubuntu_ami" {
  most_recent             = true

  filter {
    name                  = "name"
    values                = ["AMI*"] # Change to your desired AMI
  }
  filter {
    name                  = "virtualization-type"
    values                = ["hvm"]
  }
  owners                  = ["999999999999"]
}
 data "aws_subnet_ids" "subnets" {
   vpc_id                  = data.aws_vpc.vpc.id
   tags {
     Tier                  = var.subnet_scope
   }
 }

 data "aws_security_group" "sg"{
   id                      = var.securitygroup
 }


