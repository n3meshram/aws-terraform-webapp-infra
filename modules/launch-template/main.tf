resource "aws_launch_template" "web" {
  name_prefix   = "web-${var.environment}-"
  image_id      = var.ami_id
  instance_type = var.instance_type

 user_data = base64encode(<<-EOF
#!/bin/bash
yum update -y
yum install -y jq

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

# Extract password from query string
INPUT_PASSWORD=$(echo "$QUERY_STRING" | sed -n 's/^password=//p')

# Fetch password from SSM
APP_PASSWORD=$(aws secretsmanager get-secret-value \
  --secret-id "/${var.environment}/app/password" \
  --query SecretString \
  --output text | jq -r fromjson.password)

# Trim spaces/newlines (IMPORTANT)
INPUT_PASSWORD=$(echo "$INPUT_PASSWORD" | tr -d '\r\n')
APP_PASSWORD=$(echo "$APP_PASSWORD" | tr -d '\r\n')

if [ -n "$INPUT_PASSWORD" ] && [ "$INPUT_PASSWORD" = "$APP_PASSWORD" ]; then
    echo "<h1>Access Granted</h1>"
else
    echo "<h1>Access Denied</h1>"
fi
SCRIPT

chmod +x /var/www/cgi-bin/auth.sh
chown -R apache:apache /var/www

systemctl restart httpd
EOF
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