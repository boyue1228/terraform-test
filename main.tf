# create custom vpc , subnet
# create route table & IGW
# provisioning EC2 instance
# deploy nginx docker container to EC2
# create security group

provider "aws" {
    region =  "us-east-1"
}


variable "vpc-cidr-block" {
    description = "my vpc cidr block"
}

variable "subnet_cidr_block" {
    description = "my definition of 1st subnet cidr block"
    type = list(object({
        subnet_cidr_block = string
        Name = string
        Environment = string
    }))
}

variable "environment" {
    description =  "production or dev"
}

variable "az" {
    description = "Availability Zone"
}

resource "aws_vpc" "main"{
    cidr_block = var.vpc-cidr-block
    tags = {
        Name =  "main"
        Environment = var.environment
    }
}

resource "aws_subnet" "main-subnet-1" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.subnet_cidr_block[0].subnet_cidr_block
    availability_zone = var.az[0]
    tags = {
        Name = var.subnet_cidr_block[0].Name
        Environment = var.subnet_cidr_block[0].Environment
    }
}

/*
data "aws_vpc" "existing_vpc"{
    cidr_block = var.vpc-cidr-block
}
*/

resource "aws_subnet" "main-subnet-2" {
    // vpc_id = data.aws_vpc.existing_vpc.id
    vpc_id = aws_vpc.main.id
    cidr_block = var.subnet_cidr_block[1].subnet_cidr_block
    availability_zone = var.az[1]
    tags = {
        Name = var.subnet_cidr_block[1].Name
        Environment = var.subnet_cidr_block[1].Environment
    }
}

output "vpc_id" {
    value = aws_vpc.main.id
} 

output "vpc_subnet2_id" {
    value = aws_subnet.main-subnet-2.id
}
 

