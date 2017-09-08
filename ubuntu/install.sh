#!/bin/sh

# Color green
GREEN='\033[0;32m';
# Color red
RED='\033[0;31m';
# No Color
NC='\033[0m';

folder="$HOME/lamp-installer" ;
mkdir $folder > /dev/null 2>&1;
mkdir $folder/html > /dev/null 2>&1;

export="export PATH=~/lamp-installer:\$PATH";
bashrc="$HOME/.bashrc";
grep -q "$export" "$bashrc" || echo "$export" >> "$bashrc";

apt-get -y install wget > /dev/null 2>&1;

#get lamp-installer.sh
echo "### getting lamp-installer ###";
wget "https://raw.githubusercontent.com/stefanpolzer/lamp-installer/master/common/lamp-installer.sh" -O "$folder/lamp-installer" > /dev/null 2>&1;
chmod +x "$folder/lamp-installer";

#get install-amp.sh
echo "### getting install-amp ###";
wget "https://raw.githubusercontent.com/stefanpolzer/lamp-installer/master/ubuntu/install-amp.sh" -O "$folder/install-amp" > /dev/null 2>&1;
chmod +x "$folder/install-amp";

#get add-fpm-user.sh
echo "### getting add-fpm-user ###";
wget "https://raw.githubusercontent.com/stefanpolzer/lamp-installer/master/php/add-fpm-user.sh" -O "$folder/add-fpm-user" > /dev/null 2>&1;
chmod +x "$folder/add-fpm-user";

#get new-db.sh
echo "### getting new-db ###";
wget "https://raw.githubusercontent.com/stefanpolzer/lamp-installer/master/mysql/new-db.sh" -O "$folder/new-db" > /dev/null 2>&1;
chmod +x "$folder/new-db";

#get add-libapache2-mod-php-vhost.sh
echo "### getting add-libapache2-mod-php-vhost ###";
wget "https://raw.githubusercontent.com/stefanpolzer/lamp-installer/master/apache2/add-libapache2-mod-php-vhost.sh" -O "$folder/add-libapache2-mod-php-vhost" > /dev/null 2>&1;
chmod +x "$folder/add-libapache2-mod-php-vhost";

#get add-php-fpm-vhost.sh
echo "### getting add-php-fpm-vhost.sh ###";
wget "https://raw.githubusercontent.com/stefanpolzer/lamp-installer/master/apache2/add-php-fpm-vhost.sh" -O "$folder/add-php-fpm-vhost" > /dev/null 2>&1;
chmod +x "$folder/add-php-fpm-vhost";

#get install-ssl.sh
echo "### getting install-ssl ###";
wget "https://raw.githubusercontent.com/stefanpolzer/lamp-installer/master/apache2/install-ssl.sh" -O "$folder/install-ssl" > /dev/null 2>&1;
chmod +x "$folder/install-ssl";

#get coming-soon.html
echo "### getting coming-soon.html ###";
wget "https://raw.githubusercontent.com/stefanpolzer/lamp-installer/master/apache2/html/coming-soon.html" -O "$folder/html/coming-soon.html" > /dev/null 2>&1;

exec /bin/bash;
