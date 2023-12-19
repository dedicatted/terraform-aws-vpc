# Terraform Module: terraform-aws-vpc
# This module facilitates the creation of AWS VPC for different purposes, including vpc for ec2, database, and eks cluster.

## Overview
The `terraform-aws-vpc` module includes examples to easily deploy AWS VPC using official Terraform module as a source. 

## Usage

Example for deploying vpc and ec2 instance in the vpc.

```hcl
module "vpc" {
  source         = "github.com/terraform-aws-modules/terraform-aws-vpc"
  name           = var.vpc_name
  cidr           = var.cidr_block
  azs            = ["${var.region}a", "${var.region}b", "${var.region}c"]
  public_subnets = [cidrsubnet(var.cidr_block, 8, 3), cidrsubnet(var.cidr_block, 8, 4), cidrsubnet(var.cidr_block, 8, 5)]
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}
```

Example for deploying vpc and database in the vpc.

```hcl
module "vpc" {
  source                             = "github.com/terraform-aws-modules/terraform-aws-vpc"
  name                               = var.vpc_name
  cidr                               = var.cidr_block
  azs                                = ["${var.region}a", "${var.region}b", "${var.region}c"]
  database_subnets                   = [cidrsubnet(var.cidr_block, 8, 6), cidrsubnet(var.cidr_block, 8, 7), cidrsubnet(var.cidr_block, 8, 8)]
  create_database_subnet_group       = true
  create_database_subnet_route_table = true
}

module "rds" {
  source = "github.com/terraform-aws-modules/terraform-aws-rds"

  identifier = "dbdemo"

  engine            = "mysql"
  engine_version    = "5.7"
  instance_class    = "db.t3.micro"
  allocated_storage = 5

  db_name  = "dbdemo"
  username = "user"
  port     = "3306"

  iam_database_authentication_enabled = true

  vpc_security_group_ids = [module.vpc.default_security_group_id]

  maintenance_window     = "Mon:00:00-Mon:03:00"
  backup_window          = "03:00-06:00"

  subnet_ids             = module.vpc.database_subnets
  db_subnet_group_name   = module.vpc.database_subnet_group
  create_db_option_group = false

  family = "mysql5.7"

  major_engine_version   = "5.7"
}
```

Example for deploying vpc and eks cluster in the vpc.

```hcl
module "vpc" {
  source             = "github.com/terraform-aws-modules/terraform-aws-vpc"
  name               = var.vpc_name
  cidr               = var.cidr_block
  azs                = ["${var.region}a", "${var.region}b", "${var.region}c"]
  public_subnets     = [cidrsubnet(var.cidr_block, 8, 3), cidrsubnet(var.cidr_block, 8, 4), cidrsubnet(var.cidr_block, 8, 5)]
  private_subnets    = [cidrsubnet(var.cidr_block, 8, 0), cidrsubnet(var.cidr_block, 8, 1), cidrsubnet(var.cidr_block, 8, 2)]
  enable_nat_gateway = true
  single_nat_gateway = true
}

module "eks" {
  source                   = "github.com/terraform-aws-modules/terraform-aws-eks"
  cluster_name             = "demo-cluster"
  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.public_subnets
  create_kms_key           = true
  eks_managed_node_groups  = {
  one = {
    name = "node-group-1"

    instance_types = ["t3.micro"]

    min_size     = 1
    max_size     = 1
    desired_size = 1
  }
  }
}
```