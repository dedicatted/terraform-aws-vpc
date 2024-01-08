data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source         = "github.com/terraform-aws-modules/terraform-aws-vpc"
  name           = var.vpc_name
  cidr           = var.cidr_block
  azs            = slice(data.aws_availability_zones.available.names, 0, 3)
  public_subnets = [cidrsubnet(var.cidr_block, 8, 3), cidrsubnet(var.cidr_block, 8, 4), cidrsubnet(var.cidr_block, 8, 5)]
}
