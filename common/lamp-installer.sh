#!/bin/sh

# Color green
GREEN='\033[0;32m';
# Color red
RED='\033[0;31m';
# No Color
NC='\033[0m';

# configuration:
version="0.1.0";
install_folder="/usr/local/sbin";
file_list="";
file_list="${file_list} apache2/new-apache2-vhost";
file_list="${file_list} common/lamp-installer";
file_list="${file_list} mysql/new-mysql-db";
file_list="${file_list} php/add-php-fpm-user";
file_list="${file_list} ubuntu/install-amp";

## show version
for i in "$@" ; do
	if [ "$i" = "--version" ] || [ "$i" = "-v" ] ; then
		echo "LAMP Installer Version: ${GREEN}$version${NC}";
		exit;
	fi
done

## check installation
check=false;
for i in "$@" ; do
	if [ "$i" = "--check" ] || [ "$i" = "-c" ] ; then
		check=true;
	fi
done

if [ $check = true ]
	then
		# check all files
		for file in ${file_list}
			do
				file_name="$(echo $file | awk -F'/' '{print $2}')";
				if [ ! -f "$install_folder/$file_name" ]
					then
						echo "${RED}Installation is incomplete.${NC}";
						exit 1;
				fi
		done

		echo "${GREEN}Installation is complete.${NC}";
		exit 0;
fi

# show help
echo "Usage: lamp-installer [OPTION]";
echo "";
echo "Available options:";
echo "    -v, --version            Show the version of LAMP Installer";
echo "    -c, --check              Check if all files exists";
echo "        --help               Show this message";
