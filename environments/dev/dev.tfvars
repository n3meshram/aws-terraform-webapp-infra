vpc_cidr    = "10.10.0.0/16"
environment = "dev"
public_subnet_cidrs = [
  "10.10.1.0/24",
  "10.10.2.0/24"
]

private_subnet_cidrs = [
  "10.10.11.0/24",
  "10.10.12.0/24"
]

azs = [
  "ap-south-1a",
  "ap-south-1b"
]

ami_id        = "ami-0300955c2d26b2fc2"
instance_type = "t2.micro"

project = "webapp"