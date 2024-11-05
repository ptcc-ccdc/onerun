#!/bin/bash
source onerun.env

ecom_fix() {

    #TODO
        # they botched the a script in the /etc/groups file and addes apache twice to the wheel group so they wanted the user to have admin accses but it did not work can probs get IR points
        # the firewall was set to allow dhcpv6 ssh by default and on firewall-cmd reload you need to go to /etc/firewalld and find the file that has the ssh entry you can remove most of the files and add ports man via cli firewall-cmd --permanent 
            #this is the case for most of the servers
        # there was a cron tab for root 
        # phpmyadmin site in /usr/share/phpmyadmin
        # check httpd conf files for include lines those point to alternate webservers most can be located in the /etc/httpd/ dir
        # REMOVE OR MONITOR ANY ADMIN FOLDER!
        # there is a greg user or admin user on presta shop
        # Change mysql ip from 0.0.0.0 to 127.0.0.1 (done?)
        #Remove ssh
        #add a line to the httpd conf to block all acces to any dir with admin in the name 
            # <LocationMatch "(?i)admin">
            #     Order Allow,Deny
            #     Deny from all
            #     Allow from 192.168.1.0/24
            # </LocationMatch>
        # you can remove authentication.tpl in the website files to prevent them from logging in to the "real" admin page you will have to look at source code on github to find where it is
        # if this hardens it to much place the admin_SUMENUMBERS back in the dir and let them in from there just for funzies and IR points
        # they got in via the admin_SUMENUMBERS page they uplaoded a php shell and have accses as the apache user so you can do a lot to minimize what they can do you could probs change the user apache(httpd) runs as to nobody so they cant really do anything
        # the name of the shop is Greg's Shop (Store? idr lol) and i belive that is what they look at for scoring incase you have to restore from the zip backup and reinstall but the script already backed up the website to the /srv/ folder so restore from that if you can so no down time
    mkdir -p /srv/ecomm/backups/
    cp -r /var/www /etc/httpd /srv/ecomm/backups/
    echo "This script fixes the cent os 7 ecom website and other issues commands ran will be stored in $logpath/centOS/ecom_fix.txt"
    systemctl start firewalld
    for srv in $(firewall-cmd --list-services);do firewall-cmd --remove-service=$srv; done
    read -p "Enter to run mysql secure install. Enter 1 to skip or enter to continue (This will take down the website on first run): " mysql_ask
    if [ "$mysql_ask" = "1" ]; then
        mysql_secure_installation
    else
        echo "Skipping..."
    fi
    pause_script
    clear
    read -p "Enter the password you want for the prestashop user: " pass
    echo "Enter the mysql root password (If a blank password works you need to run mysql_secure_install)) "
    mysql -u root -p -e "DROP USER 'prestashop'@'localhost'; CREATE USER 'prestashop'@'localhost' IDENTIFIED BY '$pass'; GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, INDEX, ALTER, DROP, LOCK TABLES ON prestashop.* TO 'prestashop'@'localhost'; FLUSH PRIVILEGES; EXIT;"
    echo "the user prestashop should now have accses to prestashop with the password $pass"
    read -p "You have to edit the configfile in order to fix the database replace the user from root to prestashop and password ($pass)"
    sudo nano /var/www/html/prestashop/config/settings.inc.php
    sudo cp /etc/my.cnf.d/server.cnf /etc/my.cnf.d/server.cnf.bak
    sudo awk '/^\[mysqld\]$/ {print; print "bind-address = 127.0.0.1"; next}1' /etc/my.cnf.d/server.cnf.bak > /etc/my.cnf.d/server.cnf
    read -p "Verify bind-address = 127.0.0.1 is set in /etc/my.cnf.d/server.cnf (Press enter)"
    sudo nano /etc/my.cnf.d/server.cnf
    sudo systemctl restart mariadb.service
    sudo systemctl status mariadb.service
    pause_script
    # echo "Next in /etc/httpd/conf/httpd.conf go to the end and remove Included dirs should be last line"
    # read -p
    # sudo nano /etc/httpd/conf/httpd.conf
    echo -e "RewriteEngine On\nRewriteRule ^/$ /prestashop/ [R,L]" >> /etc/httpd/conf/httpd.conf
    sudo rm -rf /var/www/html/prestashop/install_bkp
    sudo cp -r /usr/share/phpMyAdmin $backuppath/
    sudo rm -rf /usr/share/phpMyAdmin/*
    clear
    echo "Moved "phpMyAdmin folder to $backuppath/phpMyAdmin
    cp ./centosEcom/FBI/index.html /usr/share/phpMyAdmin/
    cp /var/www/html/prestashop_1.5.6.zip ./backups/centos/
    read -p "Enter prems on /var/www/* and reseting httpd"
    chmod -R 700 /var/www/* /usr/share/phpMyAdmin
    chown -R apache:apache /var/www/* /usr/share/phpMyAdmin
    echo "Resetting firewall"
    sudo rm -rf /etc/firewalld/zones/*
    sudo firewall-cmd --complete-reload
    sudo iptables -X
    sudo iptables -F
    sudo iptables -Z
    sudo systemctl enable firewalld
    sudo systemctl start firewalld
    for srv in $(firewall-cmd --list-services);do firewall-cmd --remove-service=$srv; done
    firewall-cmd  --add-port=80/tcp --permanent
    firewall-cmd -reload
    cp /etc/sysconfig/network-scripts/ifcfg-ene32 ./backups/centos/
    clear
    systemctl restart httpd
    systemctl status httpd
    echo "Remeber the database user is 'prestashop' password: $pass and ip is localhost NOT 127.0.0.1"   
    echo "Backups were put in: ./backups/centos/ "
    pass=0 # clear password
    pause_script
    sudo find /etc/httpd/ /var/www/ /usr/share/phpMyAdmin -type d -exec chmod 755 {} \;
    sudo find /etc/httpd/ /var/www/ /usr/share/roundcubemail -type f -exec chmod 644 {} \;
    clear
    echo "Que sera, sera"
}

ubuntu_fix() {
    #TODO
        # change user passwords
    deb_remove_ssh
    echo "This script will install zencart"
    read -p "Enter to run mysql secure install. Enter 1 to skip or enter to continue (This will take down the website on first run): " mysql_ask
    if [ "$mysql_ask" = "1" ]; then
        mysql_secure_installation
    else
        echo "Skipping..."
    fi
    clear
    sudo apt-get update
    sudo apt-get install -y php php7.2-bcmath php7.2-ctype php7.2-curl php7.2-gd php7.2-json php7.2-mbstring php7.2-mysqli php7.2-pdo php7.2-zip php7.2-xml
    sudo cp /etc/mysql/conf.d/mysql.cnf /etc/mysql/conf.d/mysql.cnf.bak
    sudo awk '/^\[mysqld\]$/ {print; print "bind-address = 127.0.0.1"; next}1' /etc/mysql/conf.d/mysql.cnf.bak > /etc/mysql/conf.d/mysql.cnf
    read -p "Verify bind-address = 127.0.0.1 is set in /etc/my.cnf.d/server.cnf (Press enter)"
    sudo nano /etc/my.cnf.d/server.cnf
    clear
    sudo systemctl restart mysql.service
    sudo systemctl status mysql.service    
    read -p "Enter the password you want for the zencart user: " pass
    echo "Enter the mysql root password you just set"
    mysql -u root -p -e "CREATE USER 'zencart'@'localhost' IDENTIFIED BY '$pass'; GRANT SELECT, INSERT, UPDATE, DELETE ON zencart.* TO 'zencart'@'localhost'; FLUSH PRIVILEGES; EXIT;"
    echo "the user zencart should now have accses to the db zencart with the password $pass hit enter"
    read -p
    clear
    mkdir /srv/zen-cart-backup
    mv /var/www/html /srv/zen-cart-backup
    wget -O /var/www/html/zen-cart.zip https://github.com/zencart/zencart/archive/refs/tags/v1.5.8a.zip 
    unzip /var/www/html/zen-cart.zip -d /var/www/html/zen-cart
    echo "Now you have to edit the /etc/apache2/sites-enabled/openshop.conf and change var/www/html/openshop to zen-cart"
    read -p
    sudo nano /etc/apache2/sites-enabled/openshop.conf
    clear
    echo "Ok should be good ressting apache2"
    sudo systemctl restart apache2
    echo "If that went good go to 172.20.242.10/zen-cart/zc_install"
    sudo ufw --force disable
    sudo ufw --force reset
    sudo ufw default deny incoming
    sudo ufw default allow outgoing
    sudo ufw allow 80/tcp
    sudo ufw --force enable
    sudo ufw reload
    echo "Remeber the database user is 'zencart' password: $pass and ip is localhost NOT 127.0.0.1"
    echo "Que sera, sera"
}

fedora_fix() {
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
    
    echo "This script fixes the fedora Roundcube website and other issues commands ran will be stored in $logpath/centOS/ecom_fix.txt"
    sudo systemctl enable firewalld
    sudo systemctl start firewalld
    for srv in $(firewall-cmd --list-services);do firewall-cmd --remove-service=$srv; done
    for port in "${email_ports[@]}"; do sudo firewall-cmd --add-port="$port" --permanent; done 
    sudo firewall-cmd -reload;
    read -p "Enter to run mysql secure install. Enter 1 to skip or enter to continue (This will take down the website on first run): " mysql_ask
    if [ "$mysql_ask" = "1" ]; then
        mysql_secure_installation
    else
        echo "Skipping..."
    fi
    pause_script
    clear
    read -p "Enter the password you want for the roundcube user: " pass
    echo "Enter the mysql root password you just set"
    mysql -u root -p -e "CREATE USER 'roundcube'@'localhost' IDENTIFIED BY '$pass'; GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, INDEX, ALTER, DROP, LOCK TABLES ON roundcubemail.* TO 'roundcube'@'localhost'; FLUSH PRIVILEGES; EXIT;"
    echo "the user roundcube should now have accses to roundcubemail db with the password $pass"
    read -p "You have to edit the configfile in order to fix the database replace the user from root to roundcube and password ($pass)"
    sudo nano /etc/roundcubemail/config.inc.php
    echo "Remove line in conf file that says #Deny from all#"
    read -p "Press Enter to continue..."
    sudo nano /etc/httpd/conf.d/roundcubemail.conf
    sudo chown -R apache:apache /etc/httpd/ /var/www/ /usr/share/roundcubemail
    sudo find /etc/httpd/ /var/www/ /usr/share/roundcubemail -type d -exec chmod 755 {} \;
    sudo find /etc/httpd/ /var/www/ /usr/share/roundcubemail -type f -exec chmod 644 {} \;
    pass=0
    echo "Que sera, sera"


    

}


motd() {
echo > /etc/motd
echo > /etc/issue
echo "UNAUTHORIZED ACCESS TO THIS DEVICE IS PROHIBITED" | sudo tee -a /etc/motd /etc/issue
echo "You must have explicit, authorized permission to access or configure this device. Unauthorized attempts and actions to access or use this system may result in civil and/or criminal penalties. All activities performed on this device are logged and monitored." | sudo tee -a /etc/motd /etc/issue

}


fix_splunk() {
    # there is a admin cookie in the /root/.splunk/ folder no idea what its for probs a premade cookie for root login on splunk we removed it
    # the server was pretty up to date so we didnt have to do much other then change the default user/pass
    chmod -R 644 /opt/splunk/*
    chmod -R 755 /opt/splunk/bin/
    chown -R splunk:splunk /opt/splunk
    chown -R splunk:splunk /opt/splunk/*
    echo "that only changed perms check /root.splunk and other stuff"
    echo "It set perms to the user splunk make sure thats right"
    echo "Que sera, sera"

}


deb_fix() {
    
    userswpass=$(passwd -S -a | grep "P" | cut -d ' ' -f1 )
    for i in $userswpass; do echo "User $i: "; passwd $i; done
    sudo passwd -l promon
    sudo passwd -l produde
    sudo passwd -l proscrape
    sudo apt remove apache2* python* gimp* -y
    deb_remove_ssh
    clear
    cron_check
    sudo ufw --force disable
    sudo ufw --force reset
    sudo ufw default deny incoming
    sudo ufw default allow outgoing
    sudo ufw allow 53
    sudo ufw --force enable
    sudo ufw reload
    sudo cp -r /etc/bind /srv/
    clear
    echo "Que sera, sera"
}

find_setuid() {
    clear
    setuid=$(find / -perm -u=s -type f 2>/dev/null)
    for i in $setuid; do ls -la "$i"; done
}

lock_all_users() {
    sudo awk -F: '{ if ($1 != "root" && $1 != "sysadmin") system("passwd -l " $1) }' /etc/passwd
}






















# rm -rf installed_potentially_malicious.txt installed_services.txt

# servicectl_check() {
#     if command -v systemctl &>/dev/null; then
#         echo "System has systemctl"
#         servicectl="systemctl"
#     elif command -v service &>/dev/null; then
#         echo "System has service"
#         servicectl="service"
#     else
#         echo "Service control method not found, defaulting to service"
#         servicectl="service"
#     fi

#     if [ -d /etc/init.d ]; then
#         echo -e "${YELLOW}Path /etc/init.d exists, take a look to see what there is${ENDCOLOR}"
#     fi
# }

# potentially_malicious_services() {
#     for i in ${potentially_malicious[@]}; do
#         sleep .2
#         command -v $i >/dev/null 2>&1
#         if [ $? -eq 0 ]; then
#             echo "$i is installed"
#             echo "$i" >>installed_potentially_malicious.txt
#         else
#             echo "$i is not installed"
#         fi
#     done
#     echo -e "${GREEN}End of malicious services${ENDCOLOR}"
# }

# common_services_checker() {

#     for i in ${service_detection[@]}; do
#         # sleep .2
#         command -v $i >/dev/null 2>&1
#         if [ $? -eq 0 ]; then
#             echo "$i is installed"
#             echo "$i" >>installed_services.txt

#         else
#             echo "$i is not installed"
#         fi
#     done
#     echo -e "${GREEN}End of common services${ENDCOLOR}"
# }

# service_status() {
#     installed_services=$(cat installed_services.txt)
#     installed_services=(${installed_services})

#     for i in ${installed_services[@]}; do

#         if [ $servicectl == "systemctl" ]; then
#             $servicectl status $i | grep running >/dev/null 2>&1
#             if [ $? -eq 0 ]; then
#                 echo -e "${YELLO}$i${ENDCOLOR} is running"
#             else
#                 echo -e "${GREEN}$i${ENDCOLOR} is not running"
#             fi
#         elif [ $servicectl == "service" ]; then
#             $servicectl $i status | grep running >/dev/null 2>&1
#             if [ $? -eq 0 ]; then
#                 echo -e "${YELLO}$i${ENDCOLOR} is running"
#             else
#                 echo -e "${GREEN}$i${ENDCOLOR} is not running"
#             fi
#         fi
#     done

# }
# servicectl_check
# common_services_checker
# clear
# service_status

# SERVICE_TO_CHECK=("nginx" "docker")
# for i in ${SERVICE_TO_CHECK[@]}; do
#     if [[ "${installed_services[@]}" =~ " ${SERVICE_TO_CHECK} " ]]; then
#         echo "${SERVICE_TO_CHECK} found"
#     else
#         echo "${SERVICE_TO_CHECK} not found"
#     fi
# done



