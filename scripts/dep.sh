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
apt-get -y --force-yes install mysql-server mysql-client apache2 php5 php5-mysql php5-mcrypt php5-curl php5-xdebug php5-gd

# Adding some default config for xdebug
cat <<EOF >> /etc/php5/mods-available/xdebug.ini
xdebug.max_nesting_level = 400
xdebug.remote_enable=on
xdebug.remote_connect_back=on
html_errors=1
xdebug.extended_info=1
EOF

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
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer.phar

# Creating a custom php.ini for composer, without xdebug
mkdir /etc/php5/composer

cp -R /etc/php5/cli/* /etc/php5/composer

rm -f /etc/php5/composer/conf.d/20-xdebug.ini

# Creating a composer executable
cat <<EOF > /usr/local/bin/composer
#!/usr/bin/env bash

phprc=\${PHPRC}
phppath=\${PHP_INI_SCAN_DIR}

export PHPRC=/etc/php5/composer
export PHP_INI_SCAN_DIR=/etc/php5/composer/conf.d

/usr/local/bin/composer.phar "\$@"

export PHPRC=\${phprc}
export PHP_INI_SCAN_DIR=\${phppath}

EOF

chmod 755 /usr/local/bin/composer
