resource "aws_launch_template" "web" {
  name_prefix   = "web-${var.environment}-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  
  iam_instance_profile {
  name = var.instance_profile_name
}

 # 🔥 ADD THIS BLOCK
  metadata_options {
    http_tokens = "required"
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