#!/bin/bash
yum update -y
yum install -y httpd aws-cli jq

systemctl start httpd
systemctl enable httpd

sed -i 's/Options Indexes FollowSymLinks/Options Indexes FollowSymLinks ExecCGI/' /etc/httpd/conf/httpd.conf
sed -i 's/#AddHandler cgi-script .cgi/AddHandler cgi-script .cgi .sh/' /etc/httpd/conf/httpd.conf

mkdir -p /var/www/cgi-bin

# Login page

cat <<HTML > /var/www/html/index.html
<h1>${environment} Environment Login</h1>

<form action="/cgi-bin/auth.sh" method="get">
  <input type="password" name="password"/>
  <input type="submit" value="Login"/>
</form>
HTML

# Auth script

cat <<'EOF' > /var/www/cgi-bin/auth.sh
#!/bin/bash

echo "Content-type: text/html"
echo ""

INPUT_PASSWORD=$(echo "$QUERY_STRING" | sed 's/^password=//')
INPUT_PASSWORD=$(echo "$INPUT_PASSWORD" | sed 's/%40/@/g')

APP_PASSWORD=$(aws secretsmanager get-secret-value \
  --secret-id "/${environment}/app/password" \
  --region ap-south-1 \
  --query SecretString \
  --output text | jq -r '.password')

INPUT_PASSWORD=$(echo "$INPUT_PASSWORD" | tr -d '\r\n')
APP_PASSWORD=$(echo "$APP_PASSWORD" | tr -d '\r\n')

if [ -n "$INPUT_PASSWORD" ] && [ "$INPUT_PASSWORD" = "$APP_PASSWORD" ]; then
  echo "<h1>Access Granted</h1>"
else
  echo "<h1>Access Denied</h1>"
fi
EOF

chmod +x /var/www/cgi-bin/auth.sh
chown -R apache:apache /var/www

systemctl restart httpd