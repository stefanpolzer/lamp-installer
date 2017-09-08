#!/bin/sh

# Color green
GREEN='\033[0;32m';
# Color red
RED='\033[0;31m';
# No Color
NC='\033[0m';

# set default Apache log dir; ToDo get it from apache if possible
APACHE_LOG_DIR="/var/log/apache2";

# get the user name and domain
if [ -z "$1" ] || [ -z "$2" ]
	then
		echo "Wrong syntax: add-libapache2-mod-php-vhost username [www.]domain.com";
		exit;
	else
		username=$1;
		domain=$2;
fi

# check the username syntax
(echo "$username" | grep -Eq "^[a-z][a-z0-9]{3,14}\$");
if [ $? -ne 0 ]
	then
		echo "User did not match credentials. Only a-z and numbers, start with a character and have a total length between 4 and 15.";
		exit;
fi

# check the domain syntax
(echo "$domain" | grep -Eq "^([a-z0-9][a-z0-9-]{1,61}[a-z0-9]\.)+[a-z]{2,}$");
if [ $? -ne 0 ]
	then
		echo "Domain did not match credentials: \"[subdomain.]domain.tld\"";
		exit;
fi

prefix="";
while true; do
	read -p "Do you wish to have a number prefix for your apache2 config file? (Enter 3 digits or n|N for No) : " prefix
	case $prefix in
		[0-9][0-9][0-9] ) prefix="$prefix-"; break;;
		[Nn] ) prefix=""; break;;
		* ) echo "${RED}Please enter 3 digits [0-9] or [n] for no.${NC}";;
	esac
done

conf_path="/etc/apache2/sites-available";
conf_file="$conf_path/$prefix$domain.conf";

if [ -f "$conf_file" ]
	then
		echo "${RED}File $conf_file aleady exist.${NC}";
		exit;
fi

if [ ! -f "$/var/www/$username/sites" ]
	then
		mkdir "/var/www/$username/sites" > /dev/null 2>&1;
fi

if [ -f "/var/www/$username/sites/$domain" ]
	then
		echo "${RED}Folder /var/www/$username/sites/$domain aleady exist.${NC}";
		exit;
fi

mkdir "/var/www/$username/sites/$domain" > /dev/null 2>&1;
mkdir "/var/www/$username/sites/$domain/public" > /dev/null 2>&1;
wget "https://raw.githubusercontent.com/stefanpolzer/lamp-installer/master/apache2/html/coming-soon.html" -O "/var/www/$username/sites/$domain/public/index.html";

chown $username:$username -R "/var/www/$username/sites/$domain" > /dev/null 2>&1;

mkdir "$APACHE_LOG_DIR/$domain" > /dev/null 2>&1;
chown root:adm "$APACHE_LOG_DIR/$domain" > /dev/null 2>&1;

touch "$conf_file";
conf_file_content="<VirtualHost *:80>
        ServerName $domain
#        ServerAlias $domain
#        ServerAdmin webmaster@$domain
        DocumentRoot /var/www/$username/sites/$domain/public

#        <IfModule mod_rewrite.c>
#            RewriteEngine On
#            RewriteCond %{HTTP_HOST} !^www\.$domain\.com
#            RewriteRule ^.*$ http://$domain%{REQUEST_URI} [R=301,L]
#        </IfModule>

        <Directory \"/var/www/$username/sites/$domain/public\">
                Options -Indexes +FollowSymLinks
                Require all granted
                AllowOverride All

                Order Allow,Deny
                Allow from all
        </Directory>

        ErrorLog ${APACHE_LOG_DIR}/$domain/error.log
        CustomLog ${APACHE_LOG_DIR}/$domain/access.log combined
</VirtualHost>";
echo "$conf_file_content" > "$conf_file";

a2ensite "$prefix$domain.conf" > /dev/null 2>&1;

if [ -f "/etc/apache2/sites-enabled/000-default.conf" ]
	then
		while true; do
			read -p "Do you wish to disable default vhost (000-default.conf)? (Press y|Y for Yes or n|N for No) : " yn
			case $yn in
				[Yy] ) a2dissite 000-default.conf > /dev/null 2>&1; break;;
				[Nn] ) break;;
				* ) echo "${RED}Please answer [y] for yes or [n] for no.${NC}";;
			esac
		done
fi

service apache2 reload;
