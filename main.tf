/* This example shows 
- create custom vpc
- create custom subnet
- create route table and igw
- provision ec2 instance with ami
- deploy nginx docker container 
- security group (firewall)

*/

provider "aws" {
    region =  "us-east-1"
}

module "vpc" {
    source = "terraform-aws-modules/vpc/aws"

    name = "my-vpc"
    cidr = var.vpc_cidr_block

    azs             = [var.avail_zone]
    public_subnets  = [var.subnet_cidr_block]
    public_subnet_tags = {
        Name = "${var.env_prefix}-subnet-1"
    }

    tags = {
        Name = "${var.env_prefix}-vpc" 
        Environment = "dev"
    }
}

module "myapp-server" {
    source = "./modules/webserver"
    vpc_id = module.vpc.vpc_id
    env_prefix = var.env_prefix
    public_key_location = var.public_key_location 
    instance_type = var.instance_type
    subnet_id = module.vpc.public_subnets[0]
    avail_zone = var.avail_zone    
}



output "myapp-vpc-id" {
    value = module.vpc.vpc_id
}
/*
output "myapp-subnet-id" {
    value = aws_subnet.myapp-subnet-1.id
}

output "myapp-ami-id"{
    value = data.aws_ami.lastest-amazon-image.id
}

output "ec2_public_ip" {
    value = aws_instance.myapp-server.public_ip
}

*/