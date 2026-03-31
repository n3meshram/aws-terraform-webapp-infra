resource "aws_launch_template" "web" {
  name_prefix   = "web-${var.environment}-"
  image_id      = var.ami_id
  instance_type = var.instance_type

 user_data = base64encode(<<-EOF
#!/bin/bash

ENV="${var.environment}"

yum install -y httpd aws-cli
systemctl enable httpd
systemctl start httpd

#!/bin/bash

APP_PASSWORD=$(aws ssm get-parameter \
  --name "/${ENV}/app/password" \
  --with-decryption \
  --query "Parameter.Value" \
  --output text)

cat <<HTML > /var/www/html/index.html
<h1>${ENV} Environment</h1>
<p>Password from SSM: $APP_PASSWORD</p>
HTML
)
  
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