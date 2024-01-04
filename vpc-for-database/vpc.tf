data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source                             = "github.com/terraform-aws-modules/terraform-aws-vpc"
  name                               = var.vpc_name
  cidr                               = var.cidr_block
  azs                                = data.aws_availability_zones.available.names
  database_subnets                   = [cidrsubnet(var.cidr_block, 8, 6), cidrsubnet(var.cidr_block, 8, 7), cidrsubnet(var.cidr_block, 8, 8)]
  create_database_subnet_group       = true
  create_database_subnet_route_table = true
}
