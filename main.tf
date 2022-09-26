provider "aws" {
    region =  "us-east-1"
}


variable "vpc-cidr-block" {
    description = "my vpc cidr block"
}

variable "subnet_cidr_block" {
    description = "my definition of 1st subnet cidr block"
    type = list(string)
}

variable "environment" {
    description =  "production or dev"
}

resource "aws_vpc" "main"{
    cidr_block = "10.0.0.0/16"
    tags = {
        Name =  "main"
        Environment = var.environment
    }
}

resource "aws_subnet" "main-subnet-1" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.subnet_cidr_block[0]
    availability_zone = "us-east-1a"
    tags = {
        Name = "main_sub_1"
        Environment = var.environment
    }
}

data "aws_vpc" "existing_vpc"{
    cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "main-subnet-2" {
    vpc_id = data.aws_vpc.existing_vpc.id
    cidr_block = var.subnet_cidr_block[1]
    availability_zone = "us-east-1b"
    tags = {
        Name = "main_sub_2"
        Environment = "production"
    }
}

output "vpc_id" {
    value = aws_vpc.main.id
} 

output "vpc_subnet2_id" {
    value = aws_subnet.main-subnet-2.id
} 