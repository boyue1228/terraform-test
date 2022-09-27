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


variable "vpc_cidr_block" {}
variable "subnet_cidr_block" {}
variable "avail_zone" {}
variable "env_prefix" {}
variable "instance_type" {}
variable "public_key_location" {}
variable "entrypoint_file" {}

resource "aws_vpc" "myapp-vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
        Name = "${var.env_prefix}-vpc"
        
    }
}

resource "aws_subnet" "myapp-subnet-1" {
    vpc_id = aws_vpc.myapp-vpc.id
    cidr_block = var.subnet_cidr_block
    availability_zone = var.avail_zone
    tags = {
        Name = "${var.env_prefix}-subnet-1"
    }
}

/* instead of creating new route table, we're going to use default one */
/*
resource "aws_route_table" "myapp-route-table" {
    vpc_id = aws_vpc.myapp-vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.myapp-igw.id
    }
    tags = {
        Name = "${var.env_prefix}-igw"
    }
}
*/

resource "aws_default_route_table" "main-rtb" {
    default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.myapp-igw.id
    }
    tags = {
        Name = "${var.env_prefix}-igw"
    }    
}

resource "aws_internet_gateway" "myapp-igw" {
    vpc_id = aws_vpc.myapp-vpc.id
}

/* by using default route table, we don't need association anymore */
/*
resource "aws_route_table_association" "a-rtb-subnet" {
    subnet_id = aws_subnet.myapp-subnet-1.id
    route_table_id = aws_route_table.myapp-route-table.id
}
*/

resource "aws_security_group" "myapp-sg" {
    description = "my security group"
    vpc_id = aws_vpc.myapp-vpc.id
    ingress {
        description      = "TLS from myapp-VPC"
        from_port        = 22
        to_port          = 22
        protocol         = "tcp"
        cidr_blocks      = ["0.0.0.0/0"]
    }
    ingress {
        description      = "TLS from myapp-VPC"
        from_port        = 8080
        to_port          = 8080
        protocol         = "tcp"
        cidr_blocks      = ["0.0.0.0/0"]
    }
    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
  }
  tags = {
    Name = "myapp-sg"
  }
}

data "aws_ami" "lastest-amazon-image"{ 
    most_recent = true
    owners = ["amazon"]
    filter {
        name = "name"
        values = ["amzn2-ami-kernel-5.10-hvm-*-x86_64-gp2"]
    }
    filter {
        name = "virtualization-type"
        values =["hvm"]
    }
    filter {
        name   = "root-device-type"
        values = ["ebs"]
    }
}

resource "aws_key_pair" "ssh-key" {
    key_name = "server-key"
    public_key = file(var.public_key_location)
}

resource "aws_instance" "myapp-server" {
    ami = data.aws_ami.lastest-amazon-image.id
    instance_type = var.instance_type
    subnet_id = aws_subnet.myapp-subnet-1.id
    vpc_security_group_ids = [aws_security_group.myapp-sg.id]
    availability_zone = var.avail_zone
    associate_public_ip_address = true
    #instead of using key pair generate from aws, we would rather use our own public key to insert into EC2 instance.
    //key_name = "myapp-server-key-pair"
    key_name = aws_key_pair.ssh-key.key_name
    user_data = file(var.entrypoint_file)
    /*
    user_data = <<EOF
                #!/bin/bash
                    sudo yum update -y 
                    sudo yum install docker -y 
                    sudo systemctl start docker
                    sudo usermod -aG docker ec2-user
                    docker run -p 8080:80 nginx
                EOF 
    */

    tags = {
        Name = "${var.env_prefix}-app-server"
    }
}

output "myapp-vpc-id" {
    value = aws_vpc.myapp-vpc.id
}

output "myapp-subnet-id" {
    value = aws_subnet.myapp-subnet-1.id
}

output "myapp-ami-id"{
    value = data.aws_ami.lastest-amazon-image.id
}

output "ec2_public_ip" {
    /* here in order to get all attribute of resource, use terraform state show aws_instance.myapp-server */
    value = aws_instance.myapp-server.public_ip
}