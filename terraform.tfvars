vpc_cidr_block = "10.0.0.0/16"
subnet_cidr_block = "10.0.10.0/24"
avail_zone = "us-east-1a"
env_prefix = "Prod"
instance_type = "t2.micro"
public_key_location="~/.ssh/id_rsa.pub"
entrypoint_file = "./entrypoint.sh"
/*
cidr_blocks = [ 
    {cidr_block = "10.0.10.0/24", name = "subnet-1-cidr"},
    {cidr_block = "10.0.20.0/24", name = "subnet-2-cidr"}
]
*/
