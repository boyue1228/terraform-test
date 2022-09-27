
vpc-cidr-block = "10.0.0.0/16"
subnet_cidr_block = [
    { subnet_cidr_block = "10.0.10.0/24", Name = "main-subnet-1", Environment = "production" },
    { subnet_cidr_block = "10.0.20.0/24", Name = "main-subnet-2", Environment = "production" }
    ]
environment = "production"
az = ["us-east-1a","us-east-1b"]