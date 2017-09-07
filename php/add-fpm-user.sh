#!/bin/sh

## get the user name
if [ -z "$1" ]
	then
		echo "Wrong syntax: add-fpm-user username [\"Full Name\"]";
		exit;
	else
		username=$1;
fi

## check the username syntax
(echo "$username" | grep -Eq "^[a-z][a-z0-9]{2,14}\$");
if [ $? -ne 0 ]
	then
		echo "User did not match credentials. Only a-z and numbers, start with a character and have a total length between 3 and 15.";
		exit;
fi

## check PHP Version
php_version="$(php -r '$v = phpversion(); echo substr($v, 0,3);')";
case $php_version in
	7.[0-9] ) break;;
	* ) echo "You need PHP version 7+"; exit;;
esac

## create default home directory
home_dir="/var/www/$username/";
mkdir $home_dir > /dev/null 2>&1;

## check if user exists
(id -u $username > /dev/null 2>&1)
if [ $? -eq 0 ]
	then
		echo "The user \"$username\" already exists on your system. We do not create a new one";
	else
		echo "The user \"$username\" do not exists on your system. We create it now";
		adduser --home /var/www/$username/ --no-create-home --gecos "" --disabled-password --disabled-login $username > /dev/null 2>&1;
		usermod --shell "/bin/false" $username;
		if [ -z "$2" ]
			then
				usermod --comment "" $username;
			else
				usermod --comment "$2" $username;
		fi
fi

chown $username:$username $home_dir;
chmod 755 $home_dir;

## set password for user
while true; do
	read -p "Do you wish to set/change the password for the user \"$username\"?" yn
	case $yn in
		[Yy] ) passwd $username; break;;
		[Nn] ) break;;
		* ) echo "Please answer [y] for yes or [n] for no.";;
	esac
done

## set shell for user
password_status="$(passwd --status $username | awk -F ' ' '{print $2}')";
if [ "$password_status" = "P" ]
	then
		while true; do
			read -p "Do you want to set the sehll for user \"$username\"?" yn
			case $yn in
				[Yy] ) usermod  --shell "/bin/bash" $username; break;;
				[Nn] ) break;;
				* ) echo "Please answer [y] for yes or [n] for no.";;
			esac
		done
fi

fpm_path="/etc/php/$php_version/fpm/pool.d";
fpm_file="$fpm_path/$username.conf";
touch $fpm_file;

fpm_file_content="[$username]
    user = $username
    group = $username
    listen = /run/php/php$php_version-fpm.$username.sock
    listen.owner = www-data
    listen.group = www-data

    pm = dynamic
    pm.max_children = 5
    pm.start_servers = 2
    pm.min_spare_servers = 1
    pm.max_spare_servers = 3";

echo "$fpm_file_content" > "$fpm_file";

while true; do
	read -p "Do you wish to disable default fpm config (www.conf)?" yn
	case $yn in
		[Yy] ) mv $fpm_path/www.conf $fpm_path/www.conf.disabled > /dev/null 2>&1; break;;
		[Nn] ) break;;
		* ) echo "Please answer [y] for yes or [n] for no.";;
	esac
done

service php$php_version-fpm reload;
