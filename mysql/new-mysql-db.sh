#!/bin/sh

# Color green
GREEN='\033[0;32m';
# Color red
RED='\033[0;31m';
# No Color
NC='\033[0m';

# check if root
if [ "$(id -u)" -ne 0 ] ; then
	echo "${RED}Please run this command as root${NC}";
	exit 1;
fi

# check if mysql is installed
(mysql -V > /dev/null 2>&1);
if [ $? -ne 0 ] ; then
	echo "${RED}MySQL is not installed or not configured correctly${NC}";
	exit 1;
fi

# get the db and user name
if [ -z "$1" ] || [ -z "$2" ] ; then
	echo "${RED}Wrong syntax: new-mysql-db dbname username${NC}";
	exit 1;
else
	db=$1;
	user=$2;
fi

# check the db syntax
(echo "$db" | grep -Eq "^[a-z0-9_]{3,32}\$");
if [ $? -ne 0 ] ; then
	echo "DB-Name do not meet expectation: only a-z, 0-9 and _ and between 3 and 32 characters long";
	exit 1;
fi

# check the user syntax
(echo "$user" | grep -Eq "^[a-z][a-z0-9_]{1,30}[a-z0-9]\$");
if [ $? -ne 0 ] ; then
	echo "DB-User do not meet expectation: only a-z, 0-9 and _ and between 3 and 32 characters long starting with character and ending wit a character or a number";
	exit 1;
fi

rootpw="";
while true; do
	read -p "Please enter the root password : " rootpw;
	mysql -u root -p$rootpw -Bse "SELECT count(*) FROM mysql.user;" > /dev/null 2>&1;
	if [ $? -ne 0 ] ; then
		echo "${RED}root password not correct${NC}";
	else
		echo "${GREEN}root password is correct${NC}";
		break;
	fi
	echo "";
done

sql="$(mysql -u root -p$rootpw -qfsBe "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='$db'" 2>&1)";
(echo "$sql" | grep -Eq "$db\$");
if [ $? -eq 0 ] ; then
	echo "${RED}The database \"$db\" already exists${NC}";
	exit 1;
else
	echo "${GREEN}The database \"$db\" does not exists${NC}";
fi

sql="$(mysql -u root -p$rootpw -qfsBe "SELECT User FROM mysql.user WHERE User='$user'" 2>&1)";
(echo "$sql" | grep -Eq "$user\$");
if [ $? -eq 0 ] ; then
	echo "${RED}the user \"$user\" already exists${NC}";
	exit 1;
else
	echo "${GREEN}The user \"$user\" does not exists${NC}";
fi

invalid=true;
while $invalid; do
	invalid=false;
	echo "";
	read -p "Please enter a password for the NEW user \"$user\" : " password;
	
	(echo "$password" | grep -Eq "^.{8,}\$");
	if [ $? -ne 0 ] ; then
		echo "${RED}The password length is less than 8 characters${NC}";
		invalid=true;
	else
		echo "${GREEN}The password length is at least 8 characters${NC}";
	fi
	
	(echo "$password" | grep -Eq "[ABCDEFGHIJKLMNOPQRSTUVWXYZ]");
	if [ $? -ne 0 ] ; then
		echo "${RED}The password must have at least one uppercase character${NC}";
		invalid=true;
	else
		echo "${GREEN}The password have at least one uppercase character${NC}";
	fi
	
	(echo "$password" | grep -Eq "[abcdefghijklmnopqrstuvwxyz]");
	if [ $? -ne 0 ] ; then
		echo "${RED}The password must have at least one lowercase character${NC}";
		invalid=true;
	else
		echo "${GREEN}The password have at least one lowercase character${NC}";
	fi
	
	(echo "$password" | grep -Eq "[0123456789]");
	if [ $? -ne 0 ] ; then
		echo "${RED}The password must have at least one number${NC}";
		invalid=true;
	else
		echo "${GREEN}The password have at least one number${NC}";
	fi

	(echo "$password" | grep -Eq "[\#\!\$\%\&\?\*\+]");
	if [ $? -ne 0 ] ; then
		echo "${RED}The password must have at least one allowed spcial character: [${GREEN}#!\$%&?*+${RED}]${NC}";
		invalid=true;
	else
		echo "${GREEN}The password have at least one allowed spcial character${NC}";
	fi

	(echo "$password" | grep -Eq "[^ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789\#\!\$\%\&\?\*\+]");
	if [ $? -eq 0 ] ; then
		echo "${RED}The password have at least one unallowed character, only: [${GREEN}A-Za-z0-9#!\$%&?*+${RED}]${NC}";
		invalid=true;
	else
		echo "${GREEN}The password have no unallowed character${NC}";
	fi
done

charset="";
collate="";
while true; do
	read -p "Do you want to use [u]tf8 or utf8[m]b4 (recommended) characterset: " set;
	case $set in
		[Uu] ) charset="utf8"; collate="utf8_general_ci"; break;;
		[Mm] ) charset="utf8mb4"; collate="utf8mb4_unicode_ci"; break;;
		* ) echo "${RED}Please enter [u] for utf8 or [m] for utf8mb4.${NC}";;
	esac
done

echo "";

sql="CREATE DATABASE $db CHARACTER SET $charset COLLATE $collate;GRANT ALL PRIVILEGES ON $db.* TO '$user'@'localhost' IDENTIFIED BY '$password';"
result="$(mysql -u root -p$rootpw -Bse "$sql" 2>&1;)";
if [ $? -eq 0 ] ; then
	echo "${GREEN}Created database \"$db\" with user \"$user\" successful${NC}";
else
	echo "${RED}Some error occurred: ${NC}";
	warning="mysql: \[Warning\] Using a password on the command line interface can be insecure\.";
	empty="";
	result="$(echo "$result" | sed "s/$warning/$empty/")";
	echo $result;
fi
