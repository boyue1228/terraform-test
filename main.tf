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

module "myapp-subnet"{
    source =  "./modules/subnet"
    subnet_cidr_block = var.subnet_cidr_block
    avail_zone = var.avail_zone
    env_prefix = var.env_prefix
    vpc_id = aws_vpc.myapp-vpc.id 
    default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id
}

module "myapp-server" {
    source = "./modules/webserver"
    vpc_id = aws_vpc.myapp-vpc.id 
    env_prefix = var.env_prefix
    public_key_location = var.public_key_location 
    instance_type = var.instance_type
    subnet_id = module.myapp-subnet.subnet.id
    avail_zone = var.avail_zone    
}

resource "aws_vpc" "myapp-vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
        Name = "${var.env_prefix}-vpc"
    }
}



output "myapp-vpc-id" {
    value = aws_vpc.myapp-vpc.id
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