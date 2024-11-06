#!/bin/bash

# Function to fix the CentOS 7 e-commerce website and related issues
ecom_fix() {

    #TODO
        # add .htaccess with (deny from all) in any folder you dont want people to see you can get finer security if you want with it
        # the firewall was set to allow dhcpv6 ssh by default and on firewall-cmd reload you need to go to /etc/firewalld and find the file that has the ssh entry you can remove most of the files and add ports man via cli firewall-cmd --permanent 
        # your on your own for the email server good ruck
        # Probably shouldnt change all the users passwords other then root and sysadmin and non email users because the users need to login to send emails i dont think red team is allowed to use service accounts to gain accses
        # Remember the "real" database is roundcubemail not roundcube
        #config database for roundcube (etc/roundcubemail/config.inc.php)
        #does roundcube need to be accessible from outside? (yes?) i dont think so i only opned ports for email and service stayed up 
        #remove installer
        #check out htaccess (https://github.com/roundcube/roundcubemail/blob/ff2d721680f9f9ede820e69e3116fe3684d6149e/INSTALL#L163)
        #roundcubemail.conf is all wrong allowing all users to see everything chnage to deny from all instead of allow
        #fix perms on all /etc/httpd/ var/www/ /usr/share/roundcubemail (defaiult apache perms)
            #   sudo find /etc/httpd/ /var/www/ /usr/share/phpMyAdmin -type d -exec chmod 700 {} \;
            #   sudo find /etc/httpd/ /var/www/ /usr/share/roundcubemail -type f -exec chmod 600 {} \;
            #   chown -R apache:apache /var/www/* # might be httpd idk
        #set allow overide to All in httpd.conf
        #add .htaccess in bin folder (deny from all)

    # Create backup directory and copy web files
    mkdir -p /srv/ecomm/backups/ $backuppath/ECOM/
    cp -r /var/www /etc/httpd /srv/ecomm/backups/
    cp -r /var/www /etc/httpd $backuppath/ECOM/
    echo "This script fixes the CentOS 7 e-commerce website and other issues. Commands ran will be stored in $logpath/centOS/ecom_fix.txt"
    read -p "Pause"



    # Run MySQL secure installation
    read -p "Enter to run MySQL secure installation. Enter 1 to skip or Enter to continue (This will take down the website on first run): " mysql_ask
    if [ "$mysql_ask" != "1" ]; then
        mysql_secure_installation
    else
        echo "Skipping..."
    fi
    read -p "Pause"
    clear

    # Set MySQL user password for Prestashop
    read -p "Enter the password you want for the Prestashop user: " pass
    echo "Enter the MySQL root password (If a blank password works, you need to run mysql_secure_install))"
    mysql -u root -p -e "DROP USER 'prestashop'@'localhost'; CREATE USER 'prestashop'@'localhost' IDENTIFIED BY '$pass'; GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, INDEX, ALTER, DROP, LOCK TABLES ON prestashop.* TO 'prestashop'@'localhost'; FLUSH PRIVILEGES; EXIT;"
    echo "The user 'prestashop' should now have access to Prestashop with the password $pass"
    read -p "Pause"

    # Edit Prestashop config file to update database user and password
    read -p "You have to edit the config file to fix the database. Replace the user from root to prestashop and password ($pass). Press enter to continue."
    sudo nano /var/www/html/prestashop/config/settings.inc.php

    # Update MySQL bind address
    sudo cp /etc/my.cnf.d/server.cnf /etc/my.cnf.d/server.cnf.bak
    sudo awk '/^

\[mysqld\]

$/ {print; print "bind-address = 127.0.0.1"; next}1' /etc/my.cnf.d/server.cnf.bak > /etc/my.cnf.d/server.cnf
    read -p "Verify bind-address = 127.0.0.1 is set in /etc/my.cnf.d/server.cnf (Press enter)"
    sudo nano /etc/my.cnf.d/server.cnf
    sudo systemctl restart mariadb.service
    sudo systemctl status mariadb.service
    read -p "Pause"

    # Update httpd configuration
    echo -e "RewriteEngine On\nRewriteRule ^/$ /prestashop/ [R,L]" >> /etc/httpd/conf/httpd.conf
    sudo rm -rf /var/www/html/prestashop/install_bkp
    sudo cp -r /usr/share/phpMyAdmin $backuppath/ECOM/
    sudo rm -rf /usr/share/phpMyAdmin/*
    clear
    echo "Moved phpMyAdmin folder to $backuppath/ECOM/phpMyAdmin"
    cp dependencies/index.html /usr/share/phpMyAdmin/
    cp /var/www/html/prestashop*.zip $backuppath/ECOM/
    read -p "Set permissions on /var/www/* and reset httpd (Press enter to continue)."
    chmod -R 700 /var/www/* /usr/share/phpMyAdmin
    chown -R apache:apache /var/www/* /usr/share/phpMyAdmin

    # Start firewall and remove unnecessary services
    systemctl start firewalld
    for srv in $(firewall-cmd --list-services); do firewall-cmd --remove-service=$srv; done

    # Reset firewall rules
    echo "Resetting firewall"
    sudo rm -rf /etc/firewalld/zones/*
    sudo firewall-cmd --complete-reload
    sudo iptables -X
    sudo iptables -F
    sudo iptables -Z
    sudo systemctl enable firewalld
    sudo systemctl start firewalld
    for srv in $(firewall-cmd --list-services); do firewall-cmd --remove-service=$srv; done
    firewall-cmd --add-port=80/tcp --permanent
    firewall-cmd --reload

    # Backup network configuration
    cp /etc/sysconfig/network-scripts/ifcfg-ene32 ./backups/centos/
    clear

    # Restart and check httpd service
    systemctl restart httpd
    systemctl status httpd
    echo "Remember the database user is 'prestashop', password: $pass, and the IP is localhost NOT 127.0.0.1"
    echo "Backups were put in: ./backups/centos/"
    pass=0  # Clear password
    read -p "Pause"

    # Set permissions
    sudo find /etc/httpd/ /var/www/ /usr/share/phpMyAdmin -type d -exec chmod 755 {} \;
    sudo find /etc/httpd/ /var/www/ /usr/share/roundcubemail -type f -exec chmod 644 {} \;
    clear
    echo "Que sera, sera"
}
