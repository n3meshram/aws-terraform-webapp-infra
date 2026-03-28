variable "vpc_cidr" {}
variable "environment" {}
variable "public_subnet_cidrs" {}
variable "private_subnet_cidrs" {}
variable "azs" {}
variable "ami_id" {
  description = "Golden AMI for web instances"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "project" {
  description = "Project name"
  type        = string
}




