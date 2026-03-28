
variable "private_subnets" {}
variable "target_group_arn" {}
variable "launch_template_id" {}
variable "project" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}
environment = [
  {
    name  = "APP_PASSWORD"
    value = data.aws_ssm_parameter.app_password.value
  }
]