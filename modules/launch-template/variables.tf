variable "environment" {}
variable "ami_id" {}
variable "instance_type" {}
variable "security_group_id" {}
variable "instance_profile_name" {}
variable "app_password" {
  description = "App password from SSM"
  type        = string
}