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
		exit 0;
	fi
done

## check installation
check=false;
for i in "$@" ; do
	if [ "$i" = "--check" ] || [ "$i" = "-c" ] ; then
		check=true;
	fi
done

if [ $check = true ] ; then
	# check all files
	for file in ${file_list} ; do
		file_name="$(echo $file | awk -F'/' '{print $2}')";
		if [ ! -f "$install_folder/$file_name" ] ; then
			echo "${RED}Installation is incomplete.${NC}";
			exit 1;
		fi
	done
	echo "${GREEN}Installation is complete.${NC}";
	exit 0;
fi

## remove apache and fpm config
for i in "$@" ; do
	if [ "$i" = "--remove-all-sites" ] ; then
		# Get PHP Version
		php_major_version="$(php -r '$v = phpversion(); echo substr($v, 0,1);')";
		(echo "$php_major_version" | grep -Eq "^[57]$");
		if [ $? -ne 0 ] ; then
			php_major_version=false;
		fi

		php_version=$php_major_version;
		if [ $php_major_version = "7" ] ; then
			php_version="$(php -r '$v = phpversion(); echo substr($v, 0,3);')";
		fi

		echo "${RED}#######################################################";
		echo "# DO NOT USE THIS COMMAND ON A PRODUCTION ENVIRONMENT #";
		echo "#######################################################";
		echo "# -------------------- ATTENTION -------------------- #";
		echo "# ${NC}If you continue this cannot be reversed!${RED}            #";
		echo "# ${NC}This will delete all files and folders at:${RED}          #";
		echo "# ${NC}/etc/apache2/sites-available/${RED}                       #";
		echo "# ${NC}/etc/apache2/sites-enabled/${RED}                         #";
		echo "# ${NC}/etc/letsencrypt/${RED}                                   #";
		if [ $php_major_version = "7" ] ; then
			echo "# ${NC}/etc/php/$php_version/fpm/pool.d/${RED}                            #";
		fi
		if [ $php_major_version = "5" ] ; then
			echo "# ${NC}/etc/php$php_version/fpm/pool.d/${RED}                               #";
		fi
		echo "# ${NC}/var/www/${RED}                                           #";
		echo "# -------------------- ATTENTION -------------------- #";
		echo "#######################################################";
		echo "${NC}";

		while true; do
			read -p "Do you really want to delete all apache2 sites and php-fpm config files? (Press y|Y for Yes or n|N for No) : " yn
			case $yn in
				[Yy] )
					find /var/www/* ! -name 'html' -type d -exec rm -r -f {} + > /dev/null 2>&1;
					find /etc/apache2/sites-enabled/*.conf ! -name '000-default.conf' ! -name 'default-ssl.conf' -type l -exec rm -f {} + > /dev/null 2>&1;
					find /etc/apache2/sites-available/*.conf ! -name '000-default.conf' ! -name 'default-ssl.conf' -type f -exec rm -f {} + > /dev/null 2>&1;
					find /etc/letsencrypt/* -type d -exec rm -r -f {} + > /dev/null 2>&1;
					if [ $php_major_version = "7" ] ; then
						find /etc/php/$php_version/fpm/pool.d/*.conf ! -name 'www.conf' -type f -exec rm -f {} + > /dev/null 2>&1;
						service php$php_version-fpm reload > /dev/null 2>&1;
					fi
					if [ $php_major_version = "5" ] ; then
						find /etc/php$php_version/fpm/pool.d/*.conf ! -name 'www.conf' -type f -exec rm -f {} + > /dev/null 2>&1;
						service php$php_version-fpm reload > /dev/null 2>&1;
					fi
					service apache2 reload > /dev/null 2>&1;

					echo "${GREEN}All deleted${NC}";
					break;;
				[Nn] ) echo "${GREEN}Aborted${NC}"; break;;
				* ) echo "${RED}Please answer [y] for yes or [n] for no.${NC}";;
			esac
		done
		exit 0;
	fi
done

# show help
echo "Usage: lamp-installer [OPTION]";
echo "";
echo "Available options:";
echo "    -v, --version            Show the version of LAMP Installer";
echo "    -c, --check              Check if all files exists";
echo "        --remove-all-sites   Remove all custom apache2 sites and all php-fpm config files";
echo "        --help               Show this message";
