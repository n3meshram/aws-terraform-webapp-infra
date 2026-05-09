data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_launch_template" "web" {
  name_prefix   = "web-${var.environment}-lt"
  image_id = var.ami_id != "" ? var.ami_id : data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  update_default_version = true

 user_data = base64encode(templatefile("${path.module}/user_data.sh.tpl", {
  environment = var.environment
}))

 
  
  iam_instance_profile {
  name = var.instance_profile_name
}

 #tfsec:ignore:aws-ec2-enforce-launch-config-http-token-imds
  metadata_options {
  http_tokens = "optional"
}

  

  vpc_security_group_ids = [
    var.security_group_id
  ]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name        = "web-${var.environment}"
      Environment = var.environment
    }
  }
}