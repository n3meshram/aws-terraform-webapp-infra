resource "aws_launch_template" "web" {
  name_prefix   = "web-${var.environment}-"
  image_id      = var.ami_id
  instance_type = var.instance_type

  user_data = base64encode(<<-EOF
#!/bin/bash
echo "APP_PASSWORD=${var.app_password}" >> /etc/environment
EOF
)
  
  iam_instance_profile {
  name = var.instance_profile_name
}

 
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