resource "aws_launch_template" "web" {
  name_prefix   = "web-${var.environment}-"
  image_id      = var.ami_id
  instance_type = var.instance_type

 user_data = <<-EOF
#!/bin/bash
yum update -y

yum install -y httpd aws-cli

systemctl start httpd
systemctl enable httpd

# Enable CGI

sed -i 's/Options Indexes FollowSymLinks/Options Indexes FollowSymLinks ExecCGI/' /etc/httpd/conf/httpd.conf
sed -i 's/#AddHandler cgi-script .cgi/AddHandler cgi-script .cgi .sh/' /etc/httpd/conf/httpd.conf

mkdir -p /var/www/cgi-bin

# Create login page

cat <<HTML > /var/www/html/index.html

<html>
<head><title>Login</title></head>
<body>
<h1>${var.environment} Environment Login</h1>
<form action="/cgi-bin/auth.sh" method="get">
  <input type="password" name="password" placeholder="Enter Password"/>
  <input type="submit" value="Login"/>
</form>
</body>
</html>
HTML

# Create backend script

cat <<SCRIPT > /var/www/cgi-bin/auth.sh
#!/bin/bash

echo "Content-type: text/html"
echo ""

APP_PASSWORD=$(aws ssm get-parameter 
--name "/${var.environment}/app/password" 
--with-decryption 
--query "Parameter.Value" 
--output text)

if [ "$QUERY_STRING" = "password=$APP_PASSWORD" ]; then
echo "<h1>Access Granted</h1>"
else
echo "<h1>Access Denied</h1>"
fi
SCRIPT

chmod +x /var/www/cgi-bin/auth.sh
chown -R apache:apache /var/www

systemctl restart httpd
EOF

 
  
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