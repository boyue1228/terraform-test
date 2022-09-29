
resource "aws_security_group" "myapp-sg" {
    description = "my security group"
    #vpc_id = aws_vpc.myapp-vpc.id
    vpc_id = var.vpc_id
    name = "myapp-sg"

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
    //subnet_id = module.myapp-subnet.subnet.id 
    subnet_id = var.subnet_id


    vpc_security_group_ids = [aws_security_group.myapp-sg.id]
    //vpc_security_group_ids = [var.default_sg_id]

    availability_zone = var.avail_zone
    associate_public_ip_address = true
    #instead of using key pair generate from aws, we would rather use our own public key to insert into EC2 instance.
    //key_name = "myapp-server-key-pair"
    key_name = aws_key_pair.ssh-key.key_name
    user_data = file("entrypoint.sh")
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