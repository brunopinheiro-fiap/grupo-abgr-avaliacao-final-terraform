#!/bin/bash

echo "Update/Install required OS packages"
yum update -y
dnf install -y httpd wget php-fpm php-mysqli php php-devel php-xml php-mbstring php-json telnet tree git

echo "Deploy phpSysInfo app"
cd /tmp
git clone https://github.com/phpsysinfo/phpsysinfo.git
cp -r /tmp/phpsysinfo/* /var/www/html/
cp /var/www/html/phpsysinfo.ini.new /var/www/html/phpsysinfo.ini

echo "Config Apache WebServer"
usermod -a -G apache ec2-user
chown -R ec2-user:apache /var/www
chmod 2775 /var/www
find /var/www -type d -exec chmod 2775 {} \;
find /var/www -type f -exec chmod 0664 {} \;

echo "Start Services"
systemctl enable php-fpm
systemctl restart php-fpm
systemctl enable httpd
systemctl restart httpd