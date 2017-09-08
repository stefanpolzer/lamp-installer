#!/bin/sh

# Color green
GREEN='\033[0;32m';
# Color red
RED='\033[0;31m';
# No Color
NC='\033[0m';

version="0.0.1";

for i in "$@" ; do
	if [ "$i" = "--version" ] || [ "$i" = "-v" ] ; then
		echo "LAMP Installer Version: ${GREEN}$version${GREEN}";
		exit;
	fi
done

check=false;
for i in "$@" ; do
	if [ "$i" = "--check" ] || [ "$i" = "-c" ] ; then
		check=true;
	fi
done

folder="~/lamp-installer";

if [ $check = true ] ; then
	if [ ! -f "$folder/install-amp" ] || [ ! -f "$folder/add-fpm-user" ] || [ ! -f "$folder/new-db" ] || [ ! -f "$folder/add-libapache2-mod-php-vhost" ] || [ ! -f "$folder/add-php-fpm-vhost" ] || [ ! -f "$folder/install-ssl" ] || [ ! -f "$folder/html/coming-soon.html" ]
	then
		echo "${RED}Installation is incomplete.${NC}";
		exit 1;
	else
		echo "${GREEN}Installation is complete.${NC}";
		exit 0;
	fi
fi

echo "Usage: lamp-installer [OPTION]";
echo "";
echo "Available options:";
echo "    -v, --version            Show the version of LAMP Installer";
echo "    -c, --check              Check if all files exists";
echo "        --help               Show this message";
