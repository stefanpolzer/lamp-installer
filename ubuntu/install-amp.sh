#!/bin/sh

# get latest package info
echo '### get latest package info ###';
apt-get -y update;

# update curent system first
echo '### update curent system ###';
apt-get -y upgrade;

# install apache2.4+
echo '### install Apache2.4+ ###';
apt-get -y install apache2;

# install mysql5.7+
echo '### install MySql Server 5.7+ ###';
apt-get -y install mysql-server;

#configure mysql
echo '### MySql server status: ###';
systemctl status mysql;
echo '### MySql secure server ###';
mysql_secure_installation;

# de-install all php verion
while true; do
    read -p "Do you wish to remove older php versions first" yn
    case $yn in
        [Yy] ) apt-get remove '^php5' '^php7\.' '^libapache2-mod-php' '^libapache2-mod-fastcgi' ; break;;
        [Nn] ) break;;
        * ) echo "Please answer [y] for yes or [n] for no.";;
    esac
done

# add repoisoty
php_version="7.0";
while true; do
    read -p "Do you wish add repository ppa:ondrej/php (requiert for php 7.1)?" yn
    case $yn in
        [Yy] ) add-apt-repository ppa:ondrej/php; apt-get update; php_version="7.1"; break;;
        [Nn] ) break;;
        * ) echo "Please answer [y] for yes or [n] for no.";;
    esac
done

while true; do
    read -p "Do you wish to install php-[f]pm , apache2-[m]od or [b]oth?" php_module
    case $php_module in
		[Mm] ) apt-get -y install libapache2-mod-php$php_version; break;;
		[Ff] ) apt-get -y install php$php_version-fpm libapache2-mod-fastcgi; break;;
		[Bb] ) apt-get -y install php$php_version-fpm libapache2-mod-fastcgi libapache2-mod-php$php_version; break;;
        * ) echo "Please answer [f] for  php-fpm, [m] for libapache2-mod-php or [b] for both.";;
    esac
done

case $php_module in
	[FfBb] ) a2enmod actions proxy_fcgi fastcgi alias setenvif; a2enconf php$php_version-fpm;;
esac

echo '### Restart Apache server ###';
service apache2 restart;

echo '### install php mysql packages ###';
apt-get -y install php$php_version-mysql;

while true; do
    read -p "Do you wish enable PHP PDO MySql Module?" yn
    case $yn in
        [Yy] ) phpenmod pdo_mysql;; break;;
        [Nn] ) break;;
        * ) echo "Please answer [y] for yes or [n] for no.";;
    esac
done

echo '### install additional php packages ###';
apt-get -y install php$php_version-xml;

## regiert vor laravel
apt-get -y install php$php_version-mbstring;
phpenmod mbstring;
apt-get -y install php$php_version-mcrypt;
phpenmod mcrypt;
apt-get -y install php$php_version-curl;
apt-get -y install php$php_version-intl;

## Maybe make some modules optional
apt-get -y install php$php_version-gd;
apt-get -y install php$php_version-zip;

while true; do
    read -p "Do you wish enable Apache2 RewriteEngin?" yn
    case $yn in
        [Yy] ) a2enmod rewrite; break;;
        [Nn] ) break;;
        * ) echo "Please answer [y] for yes or [n] for no.";;
    esac
done

while true; do
    read -p "Do you wish enable Apache2 ssl?" yn
    case $yn in
        [Yy] ) a2enmod ssl; break;;
        [Nn] ) break;;
        * ) echo "Please answer [y] for yes or [n] for no.";;
    esac
done

echo '### Restart Apache server ###';
service apache2 restart;

## Optional packages

# install vim
while true; do
    read -p "Do you wish to install vim?" yn
    case $yn in
        [Yy] ) apt-get -y install vim; break;;
        [Nn] ) break;;
        * ) echo "Please answer [y] for yes or [n] for no.";;
    esac
done

# install git
while true; do
    read -p "Do you wish to install git?" yn
    case $yn in
        [Yy] ) apt-get -y install git; break;;
        [Nn] ) break;;
        * ) echo "Please answer [y] for yes or [n] for no.";;
    esac
done

# install composer
while true; do
    read -p "Do you wish to install composer?" yn
    case $yn in
        [Yy] ) apt-get -y install composer; break;;
        [Nn] ) break;;
        * ) echo "Please answer [y] for yes or [n] for no.";;
    esac
done
