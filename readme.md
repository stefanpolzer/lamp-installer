# Documentation
### Install the AMP (Apache MySQL PHP) Software
1) Get the Script form Github
```
wget https://raw.githubusercontent.com/stefanpolzer/lamp-installer/master/ubuntu/install-amp.sh
```
2) Change the file permission
```
chmod +x install-amp.sh
```
3) Run the shell script
```
sudo ./install-amp.sh
```
You have the option between php-fpm , apache2-mod or both.  
You can also choose if you want to enable Apache2 RewriteEngin and/or SSL  
At the end you can optional install vim, git, composer and phpmyadmin.  

### Add new PHP-FPM user
1) Get the Script form Github
```
wget https://raw.githubusercontent.com/stefanpolzer/lamp-installer/master/php/add-fpm-user.sh
```
2) Change the file permission
```
chmod +x add-fpm-user.sh
```
3) Run the shell script
```
sudo ./add-fpm-user.sh
```