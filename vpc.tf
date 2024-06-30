provider "aws" {
  region = "eu-west-3"
}

variable vpc_cidr_block {}
variable private_subnet_cidr_blocks {}
variable public_subnet_cidr_blocks {}
data "aws_availability_zones" "azs" {} // query the availability zones
module "myapp-vpc" {
    source  = "terraform-aws-modules/vpc/aws"
    version = "5.8.1"

    name            = "myapp-vpc"
    cidr            = var.vpc_cidr_block
    private_subnets = var.private_subnet_cidr_blocks 
    public_subnets  = var.public_subnet_cidr_blocks
    azs             = data.aws_availability_zones.azs.names

    enable_nat_gateway = true // create a NAT gateway for each private subnet
    single_nat_gateway = true // use a single NAT gateway for all private subnets
    enable_dns_hostnames = true // enable DNS hostnames in the VPC

    tags = {
        "kubernets.io/cluster/myapp-eks-cluster" = "shared"

    }

    public_subnet_tags = {
        "kubernets.io/cluster/myapp-eks-cluster" = "shared"
        "kubernets.io/role/elb" = "1" // tag the public subnets for ELB
    }
    private_subnet_tags = {
        "kubernets.io/cluster/myapp-eks-cluster" = "shared"
        "kubernets.io/role/internal" = "1" // tag the private subnets for internal services
    }

}