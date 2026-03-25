vpc_cidr    = "10.20.0.0/16"
environment = "stage"
public_subnet_cidrs = [
  "10.20.1.0/24",
  "10.20.2.0/24"
]

private_subnet_cidrs = [
  "10.20.11.0/24",
  "10.20.12.0/24"
]

azs = [
  "ap-south-1a",
  "ap-south-1b"
]

ami_id        = "ami-05ab90bdd75337482"
instance_type = "t2.micro"

project = "webapp"