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
cat <<SCRIPT > /var/www/cgi-bin/auth.sh
$(templatefile("${path.module}/auth.sh.tpl", { environment = environment }))
SCRIPT

chmod +x /var/www/cgi-bin/auth.sh
chown -R apache:apache /var/www

systemctl restart httpd