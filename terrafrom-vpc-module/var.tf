variable "vpc_region" {
	default = "eu-west-2"
}
variable "vpc_cidr" {
	default = "10.20.0.0/16"
}
variable "public_subnets_cidr" {
	type = "list"
	default = ["10.20.1.0/24", "10.20.2.0/24", "10.20.3.0/24"]
}
variable "private_subnets_cidr" {
	type = "list"
	default = ["10.20.101.0/24", "10.20.102.0/24", "10.20.103.0/24"]
}
variable "azs" {
	type = "list"
	default = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
}
variable "vpc_name" {
    default = "staging"
}