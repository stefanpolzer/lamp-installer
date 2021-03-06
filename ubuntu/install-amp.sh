#!/bin/sh

# Color green
GREEN='\033[0;32m';
# Color red
RED='\033[0;31m';
# No Color
NC='\033[0m';

# check if root
if [ "$(id -u)" -ne 0 ] ; then
	echo "${RED}\nPlease run this command as root\n${NC}";
	exit 1;
fi

# get latest package info
echo "${GREEN}### get latest package info ###\n${NC}";
apt-get -y update;

# update curent system first
echo "${GREEN}\n### update curent system ###\n${NC}";
apt-get -y dist-upgrade;

# add repoisoty
while true; do
	read -p "Do you wish add repository ppa:ondrej/apache2 [requiert for HTTP/2.0]? (Press y|Y for Yes or n|N for No) : " yn
	case $yn in
		[Yy] ) add-apt-repository ppa:ondrej/apache2; apt-get update; break;;
		[Nn] ) break;;
		* ) echo "${RED}Please answer [y] for yes or [n] for no.${NC}";;
	esac
done

# install apache2.4+
echo "${GREEN}\n### install Apache2.4+ ###\n${NC}";
apt-get -y install apache2;

# install mysql5.7+
echo "${GREEN}\n### install MySql Server 5.7+ ###\n${NC}";
apt-get -y install mysql-server;

# restart mysql
echo "${GREEN}\n### restart MySql server ###\n${NC}";
service mysql restart;

# show mysql status
echo "${GREEN}\n### MySql server status: ###\n${NC}";
systemctl status mysql;

echo "${GREEN}\n### install common programms: ###\n${NC}";
apt-get -y install grep awk sed;

# de-install all php verion
while true; do
	read -p "Do you wish to remove older php versions first? (Press y|Y for Yes or n|N for No) : " yn
	case $yn in
		[Yy] ) apt-get remove '^php5' '^php7\.' '^libapache2-mod-php' '^libapache2-mod-fastcgi' ; break;;
		[Nn] ) break;;
		* ) echo "${RED}Please answer [y] for yes or [n] for no.${NC}";;
	esac
done

# add repoisoty
php_version="7.0";
while true; do
	read -p "Do you wish add repository ppa:ondrej/php [requiert for php 7.2]? (Press y|Y for Yes or n|N for No) : " yn
	case $yn in
		[Yy] ) add-apt-repository ppa:ondrej/php; apt-get update; php_version="7.2"; break;;
		[Nn] ) break;;
		* ) echo "${RED}Please answer [y] for yes or [n] for no.${NC}";;
	esac
done

php_module="";
while true; do
	read -p "Do you wish to install php-[f]pm , apache2-[m]od or [b]oth? : " php_module
	case $php_module in
		[Mm] ) apt-get -y install libapache2-mod-php$php_version libapache2-mod-auth-mysql; break;;
		[Ff] ) apt-get -y install php$php_version-fpm libapache2-mod-fastcgi; break;;
		[Bb] ) apt-get -y install php$php_version-fpm libapache2-mod-fastcgi libapache2-mod-php$php_version; break;;
		* ) echo "${RED}Please answer [f] for  php-fpm, [m] for libapache2-mod-php or [b] for both.${NC}";;
	esac
done

(echo "$php_module" | grep -Eq "^[FfBb]\$");
if [ $? -eq 0 ] ; then
	echo "### enable apache2 fastcgi modules ###";
	a2enmod actions proxy_fcgi fastcgi alias setenvif;
	a2enconf php$php_version-fpm;
fi

while true; do
	read -p "Do you wish to disable Apache Web Server Signature? : " yn
	case $yn in
		[Yy] )
			sed -i 's/^ServerSignature\s\+[Oo][Nn]/ServerSignature Off/' /etc/apache2/conf-available/security.conf;
			sed -i 's/^ServerTokens\s\+[a-zA-Z]\{2,7\}/ServerTokens Prod/' /etc/apache2/conf-available/security.conf;
			break;;
		[Nn] ) break;;
		* ) echo "${RED}Please answer [y] for yes or [n] for no.${NC}";;
	esac
done

echo "${GREEN}\n### Restart Apache server ###\n${NC}";
service apache2 restart;

(echo "$php_module" | grep -Eq "^[FfBb]\$");
if [ $? -eq 0 ] ; then
	echo "### Restart PHP FPM service ###";
	service php$php_version-fpm restart;
fi

echo "${GREEN}\n### install php mysql packages ###\n${NC}";
apt-get -y install php$php_version-mysql;

while true; do
	read -p "Do you wish enable PHP PDO MySql Module? (Press y|Y for Yes or n|N for No) : " yn
	case $yn in
		[Yy] ) phpenmod pdo_mysql; break;;
		[Nn] ) break;;
		* ) echo "${RED}Please answer [y] for yes or [n] for no.${NC}";;
	esac
done

echo "${GREEN}\n### install additional php packages ###\n${NC}";
apt-get -y install php$php_version-xml;

# regiert vor laravel
apt-get -y install php$php_version-mbstring;
phpenmod mbstring;
apt-get -y install php$php_version-mcrypt;
phpenmod mcrypt;
apt-get -y install php$php_version-curl;
apt-get -y install php$php_version-intl;

# Maybe make some modules optional
apt-get -y install php$php_version-gd;
apt-get -y install php$php_version-zip;

while true; do
	read -p "Do you wish enable Apache2 RewriteEngin? (Press y|Y for Yes or n|N for No) : " yn
	case $yn in
		[Yy] ) a2enmod rewrite; break;;
		[Nn] ) break;;
		* ) echo "${RED}Please answer [y] for yes or [n] for no.${NC}";;
	esac
done

while true; do
	read -p "Do you wish enable Apache2 SSL? (Press y|Y for Yes or n|N for No) : " yn
	case $yn in
		[Yy] ) a2enmod ssl; break;;
		[Nn] ) break;;
		* ) echo "${RED}Please answer [y] for yes or [n] for no.${NC}";;
	esac
done

echo "${GREEN}\n### Restart Apache server ###\n${NC}";
service apache2 restart;

# Optional packages

# install vim
while true; do
	read -p "Do you wish to install vim? (Press y|Y for Yes or n|N for No) : " yn
	case $yn in
		[Yy] ) apt-get -y install vim; break;;
		[Nn] ) break;;
		* ) echo "${RED}Please answer [y] for yes or [n] for no.${NC}";;
	esac
done

# install postfix
while true; do
	read -p "Do you wish to install postfix? (Press y|Y for Yes or n|N for No) : " yn
	case $yn in
		[Yy] ) apt-get -y install postfix; break;;
		[Nn] ) break;;
		* ) echo "${RED}Please answer [y] for yes or [n] for no.${NC}";;
	esac
done

# install git
while true; do
	read -p "Do you wish to install git? (Press y|Y for Yes or n|N for No) : " yn
	case $yn in
		[Yy] ) apt-get -y install git; break;;
		[Nn] ) break;;
		* ) echo "${RED}Please answer [y] for yes or [n] for no.${NC}";;
	esac
done

# install composer
while true; do
	read -p "Do you wish to install composer? (Press y|Y for Yes or n|N for No) : " yn
	case $yn in
		[Yy] ) apt-get -y install composer; break;;
		[Nn] ) break;;
		* ) echo "${RED}Please answer [y] for yes or [n] for no.${NC}";;
	esac
done

# install Certbot
is_certbot_installed=false;
while true; do
	read -p "Do you wish to install Certbot to obtain Let's Encrypt - Free SSL/TLS Certificates ? (Press y|Y for Yes or n|N for No) : " yn
	case $yn in
		[Yy] ) add-apt-repository ppa:certbot/certbot; apt-get update; apt-get -y install certbot; is_certbot_installed=true; break;;
		[Nn] ) break;;
		* ) echo "${RED}Please answer [y] for yes or [n] for no.${NC}";;
	esac
done

# add Certbot cronjob
has_certbot_cronjob=true;
certbot_cronjob="certbot renew --post-hook \"service apache2 reload\"";
(crontab -l | grep -Eq "$certbot_cronjob");
if [ $? -ne 0 ] ; then
	has_certbot_cronjob=false;
fi

if [ $is_certbot_installed = true ] && [ $has_certbot_cronjob = false ] ; then
	while true; do
		read -p "Do you with to add cron jobs for Certbot ? (Press y|Y for Yes or n|N for No) : " yn
		case $yn in
			[Yy] ) (crontab -l ; echo "0 3 * * * $certbot_cronjob > /dev/null 2>&1;") | crontab -; break;;
			[Nn] ) break;;
			* ) echo "${RED}Please answer [y] for yes or [n] for no.${NC}";;
		esac
	done
fi

# install phpMyAdmin
is_pma_installed=false;
while true; do
	read -p "Do you wish to install phpMyAdmin? (Press y|Y for Yes or n|N for No) : " yn
	case $yn in
		[Yy] ) apt-get -y install phpmyadmin; is_pma_installed=true; break;;
		[Nn] ) break;;
		* ) echo "${RED}Please answer [y] for yes or [n] for no.${NC}";;
	esac
done

# secure mysql
echo "${GREEN}\n### MySql secure server ###\n${NC}";
mysql_secure_installation;

# secure phpMyAdmin
if [ $is_pma_installed = true ] ; then
	echo "${RED}### Don't forget to protect your phpmyadmin area ###\n${NC}";
fi
