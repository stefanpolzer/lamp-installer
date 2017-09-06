apt-get update;
apt-get upgrade;

# install apache2.4+
apt-get -y install apache2;

# install mysql5.7+
apt-get -y install mysql-server;

#configure mysql
systemctl status mysql;
mysql_secure_installation;

# install vim
while true; do
    read -p "Do you wish to install vim?" yn
    case $yn in
        [Yy]* ) apt-get -y install vim; break;;
        [Nn]* ) break;;
        * ) echo "Please answer [y]es or [n]o.";;
    esac
done

# install git
while true; do
    read -p "Do you wish to install git?" yn
    case $yn in
        [Yy]* ) apt-get -y install git; break;;
        [Nn]* ) break;;
        * ) echo "Please answer [y]es or [n]o.";;
    esac
done

# install composer
while true; do
    read -p "Do you wish to install composer?" yn
    case $yn in
        [Yy]* ) apt-get -y install composer; break;;
        [Nn]* ) break;;
        * ) echo "Please answer [y]es or [n]o.";;
    esac
done

# add repoisoty
$php_version="7.0";
while true; do
    read -p "Do you wish add repository ppa:ondrej/php (requiert for php 7.1)?" yn
    case $yn in
		$php_version="7.1";
        [Yy]* ) apt-get -y install software-properties-common python-software-properties; add-apt-repository ppa:ondrej/php; break;;
        [Nn]* ) break;;
        * ) echo "Please answer [y]es or [n]o.";;
    esac
done

# de-install all php verion
while true; do
    read -p "Do you wish remove all php" yn
    case $yn in
        [Yy]* ) apt-get remove php* ; break;;
        [Nn]* ) break;;
        * ) echo "Please answer [y]es or [n]o.";;
    esac
done

apt-get -y install libapache2-mod-fastcgi;
a2enmod actions fastcgi alias;
service apache2 restart;

if [ $php_version = "7.1" ]; then
	apt-get -y install php7.1;
	apt-get -y install php7.1-fpm;
	apt-get -y install php7.1-cli;
	apt-get -y install php7.1-common;
	apt-get -y install php7.1-mbstring;
	apt-get -y install php7.1-gd;
	apt-get -y install php7.1-intl;
	apt-get -y install php7.1-xml;
	apt-get -y install php7.1-mysql;
	apt-get -y install php7.1-mcrypt;
	apt-get -y install php7.1-zip;
	apt-get -y install php7.1-curl;
	
else
	apt-get -y install php7.0;
	apt-get -y install php7.0-fpm;
	apt-get -y install php7.0-cli;
	apt-get -y install php7.0-common;
	apt-get -y install php7.0-mbstring;
	apt-get -y install php7.0-gd;
	apt-get -y install php7.0-intl;
	apt-get -y install php7.0-xml;
	apt-get -y install php7.0-mysql;
	apt-get -y install php7.0-mcrypt;
	apt-get -y install php7.0-zip;
	apt-get -y install php7.0-curl;
fi
