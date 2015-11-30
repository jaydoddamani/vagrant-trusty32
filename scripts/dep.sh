#!/bin/bash

# Adding MySQL repository
gpg --keyserver keys.gnupg.net --recv-keys 5072E1F5

touch /etc/apt/sources.list.d/mysql.list

echo -e "deb http://repo.mysql.com/apt/ubuntu/ trusty mysql-5.7" >> /etc/apt/sources.list.d/mysql.list

# Adding base packages
apt-get -y install software-properties-common python-software-properties

# Adding PHP repository
add-apt-repository ppa:ondrej/php5-5.6

# Repo update and package upgrade
apt-get -y update
apt-get -y upgrade

# Setting MySQL root password to empty string
export DEBIAN_FRONTEND="noninteractive"

# Installing all the fun things
apt-get -y --force-yes install mysql-server mysql-client apache2 php5 php5-mysql php5-mcrypt php5-curl

# Adding the apache user to the vagrant group, so /vagrant can be the docroot
adduser www-data vagrant

# Adding /vagrant as default virtual host
cat <<EOF > /etc/apache2/sites-available/vagrant.conf

<VirtualHost *:80>
    DocumentRoot /vagrant
    <Directory /vagrant/>
        Options -Indexes +FollowSymLinks +MultiViews
        AllowOverride All
        Order allow,deny
        allow from all
        Require all granted
    </Directory>
    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

rm -rf /etc/apache2/sites-enabled/*

ln -s /etc/apache2/sites-available/vagrant.conf /etc/apache2/sites-enabled/vagrant.conf

a2enmod rewrite

service apache2 restart

# Exposing MySQL to be accessible from the outside

cat <<EOF > /etc/mysql/conf.d/vagrant.cnf
[mysqld]

bind-address    = 0.0.0.0

EOF

service mysql restart

# Installing composer
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
