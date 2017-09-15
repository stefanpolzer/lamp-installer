#!/bin/sh

# Color green
GREEN='\033[0;32m';
# Color red
RED='\033[0;31m';
# No Color
NC='\033[0m';

# configuration:
APACHE_LOG_DIR="/var/log/apache2";
apache_sites_available_path="/etc/apache2/sites-available";

# check if root
if [ "$(id -u)" -ne 0 ]
	then
		echo "${RED}Please run this command as root${NC}";
		exit 1;
fi

# check if apache is installed
(apachectl -v > /dev/null 2>&1);
if [ $? -ne 0 ]
	then
		echo "${RED}Apache is not installed or not configured correctly${NC}";
		exit 1;
fi

# Get PHP Version
php_major_version="$(php -r '$v = phpversion(); echo substr($v, 0,1);')";
(echo "$php_major_version" | grep -Eq "^[57]$");
if [ $? -ne 0 ]
	then
		php_version=false;
fi

php_version=$php_major_version;
if [ $php_major_version = "7" ]
	then
		php_version="$(php -r '$v = phpversion(); echo substr($v, 0,3);')";
fi

# Get username
username="";
while true; do
	read -p "Please enter the username : " username
	# check the username syntax
	(echo "$username" | grep -Eq "^[a-z][a-z0-9]{3,14}$");
	if [ $? -ne 0 ]
		then
			echo "${RED}Username did not match credentials. Only a-z and numbers, start with a character and have a total length between 4 and 15.${NC}";
		else
			break;
	fi
done

# Get domain
domain="";
while true; do
	read -p "Please enter the domain : " domain
	# check the domain syntax
	(echo "$domain" | grep -Eq "^([a-z0-9][a-z0-9-]{1,61}[a-z0-9]\.)+[a-z]{2,}$");
	if [ $? -ne 0 ]
		then
			echo "${RED}Domain did not match credentials: \"[subdomain.]domain.tld\"${NC}";
		else
			break;
	fi
done

# check if domain stats with www
is_www_domin=false;
(echo "$domain" | grep -Eq "^www\.");
if [ $? -eq 0 ]
	then
		is_www_domin=true
fi

## TODO ask for www, non-www opposit
## TODO ask for additionals domains

# Check if we want to use php-fpm
use_php_fpm=false;
while true; do
	read -p "Do you wish to use php-fpm ? (Press y|Y for Yes or n|N for No) :" yn
	case $yn in
		[Yy] ) use_php_fpm=true; break;;
		[Nn] ) break;;
		* ) echo "${RED}Please answer [y] for yes or [n] for no.${NC}";;
	esac
done

if [ $use_php_fpm = true ]
	then
		# check if mysql is installed
		(php -v > /dev/null 2>&1);
		if [ $? -ne 0 ]
			then
				echo "${RED}PHP is not installed or not configured correctly${NC}";
				exit 1;
		fi
		
		add-php-fpm-user $username;
		if [ $? -ne 0 ]
			then
				echo "${RED}Erro while creating php-fpm-user. We did not create a apache vhost${NC}";
				exit 1;
		fi
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

conf_file="$apache_sites_available_path/$prefix$domain.conf";

if [ -f "$conf_file" ]
	then
		echo "${RED}File $conf_file aleady exist.${NC}";
		exit 1;
fi

if [ ! -f "$/var/www/$username/sites" ]
	then
		mkdir "/var/www/$username/sites" > /dev/null 2>&1;
fi

if [ -f "/var/www/$username/sites/$domain" ]
	then
		echo "${RED}Folder /var/www/$username/sites/$domain aleady exist.${NC}";
		exit 1;
fi

force_www=false;
force_non_www=false;
if [ $is_www_domin = true ]
	then
		while true; do
			read -p "Do you wish to force the non www version of your domain ? (Press y|Y for Yes or n|N for No) : " yn
			case $yn in
				[Yy] ) a2enmod rewrite; force_non_www=true; break;;
				[Nn] ) break;;
				* ) echo "${RED}Please answer [y] for yes or [n] for no.${NC}";;
			esac
		done
	else
		while true; do
			read -p "Do you wish to force the www version of your domain ? (Press y|Y for Yes or n|N for No) : " yn
			case $yn in
				[Yy] ) a2enmod rewrite; force_www=true; break;;
				[Nn] ) break;;
				* ) echo "${RED}Please answer [y] for yes or [n] for no.${NC}";;
			esac
		done
fi

use_ssl=false;
## TODO check if Certbot is isnalled
while true; do
	read -p "Do you wish to use https with Let's Encrypt ? (Press y|Y for Yes or n|N for No) : " yn
	case $yn in
		[Yy] ) a2enmod ssl; use_ssl=true; break;;
		[Nn] ) break;;
		* ) echo "${RED}Please answer [y] for yes or [n] for no.${NC}";;
	esac
done

http="%{REQUEST_SCHEME}";
if [ $use_ssl = true ]
	then
		while true; do
			read -p "Do you wish to force https ? : " yn
			case $yn in
				[Yy] ) a2enmod rewrite; http="https"; break;;
				[Nn] ) break;;
				* ) echo "${RED}Please answer [y] for yes or [n] for no.${NC}";;
			esac
		done
fi

site=$domain;

mkdir "/var/www/$username/sites/$site" > /dev/null 2>&1;
mkdir "/var/www/$username/sites/$site/public" > /dev/null 2>&1;
mkdir "/var/www/$username/sites/$site/.ErrorDocuments" > /dev/null 2>&1;

wget "https://raw.githubusercontent.com/stefanpolzer/lamp-installer/master/apache2/html/coming-soon.html" -O "/var/www/$username/sites/$site/public/index.html";
wget "https://raw.githubusercontent.com/stefanpolzer/lamp-installer/master/apache2/html/error400.html" -O "/var/www/$username/sites/$site/.ErrorDocuments/400.html";
wget "https://raw.githubusercontent.com/stefanpolzer/lamp-installer/master/apache2/html/error401.html" -O "/var/www/$username/sites/$site/.ErrorDocuments/401.html";
wget "https://raw.githubusercontent.com/stefanpolzer/lamp-installer/master/apache2/html/error403.html" -O "/var/www/$username/sites/$site/.ErrorDocuments/404.html";
wget "https://raw.githubusercontent.com/stefanpolzer/lamp-installer/master/apache2/html/error404.html" -O "/var/www/$username/sites/$site/.ErrorDocuments/403.html";
wget "https://raw.githubusercontent.com/stefanpolzer/lamp-installer/master/apache2/html/error500.html" -O "/var/www/$username/sites/$site/.ErrorDocuments/500.html";

chown $username:$username "/var/www/$username/sites" > /dev/null 2>&1;
chown $username:$username -R "/var/www/$username/sites/$site" > /dev/null 2>&1;

webmaster=webmaster@$domain;
## TODO ask for webmaster domain

mkdir "$APACHE_LOG_DIR/$domain" > /dev/null 2>&1;
chown root:adm "$APACHE_LOG_DIR/$domain" > /dev/null 2>&1;

touch "$conf_file";

conf_file_content="<VirtualHost *:80 *:443>
        ServerName $domain
        ServerAdmin $webmaster
        ServerSignature Off

        DocumentRoot /var/www/$username/sites/$site/public

        Alias \"/.ErrorDocuments\" \"/var/www/$username/sites/$site/.ErrorDocuments\"
        ErrorDocument 400 /.ErrorDocuments/400.html
        ErrorDocument 401 /.ErrorDocuments/401.html
        ErrorDocument 403 /.ErrorDocuments/403.html
        ErrorDocument 404 /.ErrorDocuments/404.html
        ErrorDocument 500 /.ErrorDocuments/500.html
";

if [ $http = "https" ] || [ $force_www = true ] || [ $force_non_www = true ]
	then
		conf_file_content="$conf_file_content
        <IfModule mod_rewrite.c>
            RewriteEngine On
";
fi

inst="";
if [ $http = "https" ]
	then
		inst="##INST##";
		conf_file_content="$conf_file_content
$inst            RewriteCond %{HTTPS} !=on
$inst            RewriteRule ^(.*)$ https://%{HTTP_HOST}/$1 [R=301,L]
";
fi

if [ $force_www = true ]
	then
		conf_file_content="$conf_file_content
$inst            RewriteCond %{HTTP_HOST} !^www\. [NC]
$inst            RewriteRule ^(.*)$ $http://www.%{HTTP_HOST}/$1 [R=301,L]
";
fi

if [ $force_non_www = true ]
	then
		conf_file_content="$conf_file_content
$inst            RewriteCond %{HTTP_HOST} !^www\. [NC]
$inst            RewriteRule ^(.*)$ $http://www.%{HTTP_HOST}/$1 [R=301,L]
";
fi

if [ $http = "https" ] || [ $force_www = true ] || [ $force_non_www = true ]
	then
		conf_file_content="$conf_file_content
        </IfModule>
";
fi

if [ $use_ssl = true ]
	then
		conf_file_content="$conf_file_content
        <IfModule mod_ssl.c>
$inst                SSLEngine ON
$inst                SSLCertificateFile    /etc/letsencrypt/live/$domain/fullchain.pem
$inst                SSLCertificateKeyFile /etc/letsencrypt/live/$domain/privkey.pem

$inst            <FilesMatch \"\.(cgi|shtml|phtml|ph(p[57]?|t|tml))$\">
$inst                SSLOptions +StdEnvVars
$inst            </FilesMatch>
        </IfModule>
";
fi

if [ $use_php_fpm = true ]
	then
		conf_file_content="$conf_file_content
        <IfModule mod_fastcgi.c>
            <FilesMatch \".+\.ph(p[57]?|t|tml)$\">
                SetHandler php$php_major_version-fcgi-$username
            </FilesMatch>

            AddHandler php$php_major_version-fcgi-$username .php
            Action php$php_major_version-fcgi-$username /php$php_major_version-fcgi-$username
            Alias /php$php_major_version-fcgi-$username /usr/lib/cgi-bin/php$php_major_version-fcgi-$username
            FastCgiExternalServer /usr/lib/cgi-bin/php$php_major_version-fcgi-$username -socket /run/php/php$php_version-fpm.$username.sock -pass-header Authorization

            <Directory \"/usr/lib/cgi-bin\">
                Require all granted
            </Directory>
        </IfModule>
";
fi

conf_file_content="$conf_file_content
        <Directory \"/var/www/$username/sites/$site/public\">
                Options -Indexes +FollowSymLinks
                Require all granted
                AllowOverride All

                Order Allow,Deny
                Allow from all
        </Directory>

        ErrorLog \${APACHE_LOG_DIR}/$domain/error.log
        CustomLog \${APACHE_LOG_DIR}/$domain/access.log combined
</VirtualHost>
";

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

## TODO run certbot and enable https
#certbot certonly --webroot -n --agree-tos -m $webmaster -w /var/www/$username/sites/$site/public -d $domain -d more.domain.com
