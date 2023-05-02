# configure aws provider to establish a secure connection between terraform and aws
provider "aws" {
  region = var.region

  default_tags {
    tags = {
      "Automation"  = "terraform"
      "project"     = var.project_name
      "environment" = var.environment
    }
  }
}
# terraform provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  required_version = ">= 1.1.5"
}



# create vpc
resource "aws_vpc" "elearning-vpc" {
  cidr_block           = var.elearning-vpc
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "elearning-vpc"
  }
}

# create internet gateway and attach it to vpc
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.elearning-vpc.id

  tags = {
    Name = "elearning-igw"
  }
}

# use data source to get all avalablility zones in  AWS region
data "aws_availability_zones" "available_zones" {}

# create public subnet az1
resource "aws_subnet" "public_subnet_az1" {
  vpc_id                  = aws_vpc.elearning-vpc.id
  cidr_block              = var.public_subnet_az1_cidr
  availability_zone       = data.aws_availability_zones.available_zones.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "elearning-public-az1"
  }
}

# create public subnet az2
resource "aws_subnet" "public_subnet_az2" {
  vpc_id                  = aws_vpc.elearning-vpc.id
  cidr_block              = var.public_subnet_az2_cidr
  availability_zone       = data.aws_availability_zones.available_zones.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "elearning-public-az2"
  }
}

# create route table and add public route
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.elearning-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {

    Name = "elearning-public-rt"
  }
}