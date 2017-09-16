# Documentation
### Install the Software on a Ubuntu Server
1) Get the Script form Github
```
wget https://raw.githubusercontent.com/stefanpolzer/lamp-installer/master/ubuntu/install.sh
```
2) Change the file permission
```
chmod +x install.sh
```
3) Run the shell script
```
sudo ./install.sh
```
You have now access to all commands

### Install the AMP (Apache MySQL PHP) Software
```
sudo install-amp
```
You have the option between php-fpm , apache2-mod or both.  
You can also choose if you want to enable Apache2 RewriteEngin and/or SSL  
At the end you can optional install vim, git, composer, phpmyadmin and certbot used for Let's Encrypt.  
Maybe some of this additionals Programs are already installed on your Server  

### Add new Apache Virtual Host
Run the shell script
```
sudo new-apache2-vhost
```

### Add new MySQL Database
Run the shell script
```
sudo new-mysql-db dbname username
```
