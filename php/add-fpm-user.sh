#!/bin/sh

## get first parameter
if [ -z "$1" ]
	then echo "Wrong syntax: add-fpm-user [username]"; exit;
	else username=$1;
fi

(echo "$username" | grep -Eq  "^[a-z][a-z0-9]{2,14}$") || (echo "User did not match credentials. Only a-z and numbers, start with a character and a total length between 3 and 15."; exit;);

## get php Version
php_version="$(php -r '$v = phpversion(); echo substr($v, 0,3);')";
case $php_version in
	7.[0-9] ) break;;
	* ) echo "You need PHP version 7+"; exit;;
esac

echo $username;
echo $php_version;

touch /etc/php/$php_version/fpm/pool.d/$username.conf;
