variable "environment" {}

variable "instance_type" {}
variable "security_group_id" {}
variable "instance_profile_name" {}

variable "ami_id" {
  description = "Golden AMI for web instances"
  type        = string
  default     = ""
}
