#!/usr/bin/env bash

# Mise à jour des dépots
apt-get -qq update

# Configuration de la timezone
echo "Europe/Paris" > /etc/timezone
apt-get install -y tzdata
dpkg-reconfigure -f noninteractive tzdata

# Installation de Java
apt-get -y install openjdk-7-jre-headless

# Installation de Apache et PHP
apt-get -y install libapache2-mod-php5 php5-cli php5-mysqlnd

# Configuration de Apache
sed -i s/AllowOverride\ None/AllowOverride\ All/g /etc/apache2/sites-enabled/000-default
a2enmod rewrite
a2enmod expires
service apache2 reload

# Installation de MySQL
echo "mysql-server mysql-server/root_password password root" | debconf-set-selections
echo "mysql-server mysql-server/root_password_again password root" | debconf-set-selections
apt-get install -y mysql-server

# Installation de PhpMyAdmin
echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections
echo "phpmyadmin phpmyadmin/app-password-confirm password root" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/admin-pass password root" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/app-pass password root" | debconf-set-selections
echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" | debconf-set-selections
apt-get install -y phpmyadmin

# Création des bases de données
# -- forum
mysql --defaults-file=/etc/mysql/debian.cnf -e "drop database if exists new_serendip_arts_org"
mysql --defaults-file=/etc/mysql/debian.cnf -e "create database new_serendip_arts_org default charset utf8 collate utf8_general_ci"
#gunzip -c /vagrant/src/data/net_musiquesincongrues_www_forum.dump.sql.gz | mysql --defaults-file=/etc/mysql/debian.cnf net_musiquesincongrues_www_forum#
# -- asaph
mysql --defaults-file=/etc/mysql/debian.cnf -e "drop database if exists new_serendip_arts_org"
mysql --defaults-file=/etc/mysql/debian.cnf -e "create database new_serendip_arts_org default charset utf8 collate utf8_general_ci"

# Configuration du projet
apt-get install -y ant
cd /vagrant
./composer.phar install --prefer-dist --no-progress
ant configure build -Dprofile=vagrant

# Mise à disposition du projet dans Apache
ln -sf /vagrant/src/wordpress/wp-config.php /vagrant/vendor/johnpbloch/wordpress/
ln -sf /vagrant/vendor/johnpbloch/wordpress/* /var/www/
ln -sf /vagrant/vendor/wordpress/plugins/* /vagrant/vendor/johnpbloch/wordpress/wp-content/plugins/
ln -sf /vagrant/vendor/wordpress/themes/* /vagrant/vendor/johnpbloch/wordpress/wp-content/themes/
rm -f /var/www/index.html

# Informations
echo
echo -e "Le site est disponible à l'adresse : http://new.serendip.vagrant.dev/"
