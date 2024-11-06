#!/bin/bash
source /etc/apache2/envvars
echo "This script will install ZenCart"

# Prompt the user for MySQL secure installation
read -p "Press Enter to run MySQL secure installation. Enter 1 to skip or press Enter to continue (This will take down the website on the first run): " mysql_ask
if [ "$mysql_ask" != "1" ]; then
    mysql_secure_installation
else
    echo "Skipping MySQL secure installation..."
fi

clear

# Update and install necessary PHP packages
sudo apt-get update
sudo apt-get install -y unzip php php7.2-bcmath php7.2-ctype php7.2-curl php7.2-gd php7.2-json php7.2-mbstring php7.2-mysqli php7.2-pdo php7.2-zip php7.2-xml

# Backup the MySQL configuration file
sudo cp /etc/mysql/my.cnf /etc/mysql/my.cnf.bak

# Update the bind address in the MySQL configuration

echo "[mysqld]" >/etc/mysql/my.cnf
echo "bind-address = 127.0.0.1" >>/etc/mysql/my.cnf
# Prompt the user to verify the bind address
read -p "Verify 'bind-address = 127.0.0.1' is set in /etc/mysql/my.cnf (Press Enter to continue)"
sudo nano /etc/mysql/my.cnf

clear

# Restart MySQL service and check its status
sudo systemctl restart mysql.service
sudo systemctl status mysql.service

# Set up the ZenCart MySQL user
read -p "Enter the password you want for the ZenCart user: " pass
echo "Enter the MySQL root password you just set"
mysql -u root -p -e "CREATE USER 'zencart'@'localhost' IDENTIFIED BY '$pass'; GRANT SELECT, INSERT, UPDATE, DELETE ON zencart.* TO 'zencart'@'localhost'; FLUSH PRIVILEGES; EXIT;"

echo "The user 'zencart' should now have access to the database 'zencart' on "localhost" with the password $pass. Press Enter to continue."
read -p

clear

echo "Creating backup of the existing web directory..."
mkdir -p /srv/zen-cart-backup
cp -ra /var/www/html /srv/zen-cart-backup
echo "Backup created at /srv/zen-cart-backup"
mv /var/www/html /var/www/html-old
mkdir /var/www/html

echo "Downloading ZenCart..."
wget -O /srv/zen-cart.zip https://github.com/zencart/zencart/archive/refs/tags/v1.5.6.zip
unzip /srv/zen-cart.zip -d /tmp/
mv /tmp/zen* /var/www/zen-cart
echo "ZenCart downloaded and extracted."

read -p "Check what user apache is running as (should be www-data). Press Enter to continue..."
sudo nano /etc/apache2/envvars

echo "Backing up existing openshop.conf..."
sudo mv /etc/apache2/sites-enabled/openshop.conf /etc/apache2/sites-enabled/openshop.conf.bak



echo "Disabling old site configurations..."
sudo a2dissite openshop.conf
sudo a2dissite 000-default.conf

echo "Copying new configuration file..."
sudo cp dependencies/www-conf/openshop.conf /etc/apache2/sites-available/openshop.conf

read -p "Now edit /etc/apache2/sites-available/openshop.conf and change 'var/www/html/openshop' to 'var/www/html/zen-cart'. Press Enter to continue..."
sudo nano /etc/apache2/sites-available/openshop.conf

echo "Enabling the new openshop.conf..."
sudo a2ensite openshop.conf

echo "Checking Apache configuration..."
sudo apache2ctl configtest

read -p "Pause"


clear
sudo chown -R www-data:www-data /var/www/

# Set directory permissions to 755 (drwxr-xr-x)
sudo find /var/www/ -type d -exec chmod 755 {} \;

# Set file permissions to 644 (-rw-r--r--)
sudo find /var/www/ -type f -exec chmod 644 {} \;

# Restart Apache service

echo "Restarting Apache2..."
sudo systemctl restart apache2

echo "If everything went well, go to http://172.20.242.10/zen-cart/zc_install"

# Update UFW firewall rules
sudo ufw --force disable
sudo ufw --force reset
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 80/tcp
sudo ufw --force enable
sudo ufw reload

# Reminder about database credentials
echo "Remember, the database user is 'zencart', password: $pass, and the IP is 'localhost' (NOT 127.0.0.1)."
read -p "Que sera, sera"
