vpc_cidr    = "10.30.0.0/16"
environment = "prod"
public_subnet_cidrs = [
  "10.30.1.0/24",
  "10.30.2.0/24"
]

private_subnet_cidrs = [
  "10.30.11.0/24",
  "10.30.12.0/24"
]

azs = [
  "ap-south-1a",
  "ap-south-1b"
]

ami_id        = "ami-04efded783750b090"
instance_type = "t2.micro"

project = "webapp"