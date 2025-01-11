#!/bin/bash
DATABASE_PASS='admin123'
sudo yum update -y
sudo yum install epel-release -y
sudo yum install git zip unzip -y
sudo yum install mariadb-server -y


# starting & enabling mariadb-server
sudo systemctl start mariadb
sudo systemctl enable mariadb
cd /tmp/
git clone -b main https://github.com/paskcse/vprofile-project.git
# Setting the root password and securing the installation
sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$DATABASE_PASS';"
sudo mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
sudo mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.user WHERE User='';"
sudo mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%';"
sudo mysql -u root -p"$DATABASE_PASS" -e "FLUSH PRIVILEGES;"

# Creating the database and granting privileges
sudo mysql -u root -p"$DATABASE_PASS" -e "CREATE DATABASE accounts;"
sudo mysql -u root -p"$DATABASE_PASS" -e "GRANT ALL PRIVILEGES ON accounts.* TO 'admin'@'localhost' IDENTIFIED BY '$DATABASE_PASS';"
sudo mysql -u root -p"$DATABASE_PASS" -e "GRANT ALL PRIVILEGES ON accounts.* TO 'admin'@'%' IDENTIFIED BY '$DATABASE_PASS';"
sudo mysql -u root -p"$DATABASE_PASS" -e "FLUSH PRIVILEGES;"

# Restoring the database dump
sudo mysql -u root -p"$DATABASE_PASS" accounts < /tmp/vprofile-project/src/main/resources/db_backup.sql


# Restart mariadb-server
sudo systemctl restart mariadb


#starting the firewall and allowing the mariadb to access from port no. 3306
sudo systemctl start firewalld
sudo systemctl enable firewalld
sudo firewall-cmd --get-active-zones
sudo firewall-cmd --zone=public --add-port=3306/tcp --permanent
sudo firewall-cmd --reload
sudo systemctl restart mariadb
