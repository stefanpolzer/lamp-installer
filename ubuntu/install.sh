#!/bin/sh

# Color green
GREEN='\033[0;32m';
# Color red
RED='\033[0;31m';
# No Color
NC='\033[0m';

# configuration:
install_folder="/usr/local/sbin";
resource_location="https://raw.githubusercontent.com/stefanpolzer/lamp-installer/master";
file_list="";
file_list="${file_list} apache2/new-apache2-vhost";
file_list="${file_list} common/lamp-installer";
file_list="${file_list} mysql/new-mysql-db";
file_list="${file_list} php/add-php-fpm-user";
file_list="${file_list} ubuntu/install-amp";

# check if root
if [ "$(id -u)" -ne 0 ]
	then
		echo "${RED}Please run this command as root${NC}";
		exit 1;
fi

# create install folder
mkdir $install_folder > /dev/null 2>&1;

# install wget if not install already
apt-get -y install wget > /dev/null 2>&1;

# get all files
for file in ${file_list}
	do
		file_name="$(echo $file | awk -F'/' '{print $2}')";
		echo "### getting $file_name ###";
		wget -q "$resource_location/$file.sh" -O "$install_folder/$file_name" > /dev/null 2>&1;
		if [ $? -eq 0 ]
			then
				chmod +x "$install_folder/$file_name" > /dev/null 2>&1;
				echo "${GREEN}Got $file_name successful${NC}";
			else
				chmod -x "$install_folder/$file_name" > /dev/null 2>&1;
				echo "${RED}Error while getting $file_name${NC}";
		fi
done
