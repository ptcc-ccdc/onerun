#!/bin/bash
#source functions
clear
users=$(cut -d: -f1 /etc/passwd)
mkdir -p ./backups ./logs ./logs/centOS ./ssh ./backups/centos
rm -rf /usr/share/local
logpath=./logs
backuppath=./backups
http_ports=(80 443)
email_ports=(25/tcp 587/tcp 465/tcp 110/tcp 995/tcp 143/tcp)
dns_ports=(53)


chmod 700 /etc/shadow
chmod 700 /etc/passwd
rm -rf /etc/ssh/ssh*
chown root:root /etc/shadow
chown root:root /etc/passwd

#why not
pause_script() {
    read -p "Press Enter to continue..."
    clear
}

# User check
if [ "$EUID" -ne 0 ]; then
    echo "Current user is not root some fuctions will not work. Current user is:"$USER
    else echo "Running this script as '$USER'"
    fi
    pause_script
    clear

# command logger
log_command() {
    echo "At $(date) the user $USER ran: $1" >> $logpath/ran_commands.txt
}

echo "do not run this script on a real computer. there is stuff that auto runs CTL+C to end"
pause_script

log_command "mkdir -p ./backups ./logs"

echo "Logs will be stored in $logpath/"
echo "Looking for ssh authorized_keys..."
find /  -type f -name "authorized_keys" 2>/dev/null > $logpath/ssh/found-ssh-keys-"$(date "+%H:%M")".txt
keys_path=$(find /  -type f -name "authorized_keys" 2>/dev/null)
for path in $keys_path
    do mv "$path" $logpath/ssh/unalterd_keys-"$(date "+%H:%M")".txt
        log_command "mv $path $logpath/ssh/unalterd_keys-$(date "+%H:%M").txt"
        echo "Key found: $path"
        echo "$path:" >> $logpath/ssh/alterd_keys-"$(date "+%H:%M")".txt
        log_command "echo $path: >> $logpath/ssh/alterd_keys-$(date "+%H:%M").txt"
        sed -e 's/^.\{10\}//' $logpath/ssh/unalterd_keys-"$(date "+%H:%M")".txt >> $logpath/ssh/alterd_keys-"$(date "+%H:%M")".txt
        log_command "sed -e 's/^.\{10\}//' $logpath/ssh/unalterd_keys-$(date "+%H:%M").txt >> $logpath/ssh/alterd_keys-$(date "+%H:%M").txt"
        rm -rf $logpath/ssh/unalterd_keys-"$(date "+%H:%M")".txt
        log_command "rm -rf $logpath/ssh/unalterd_keys-$(date "+%H:%M").txt"
        rm -rf "$path"
        log_command "rm -rf $path"
    done
echo "If any keys have been found they have been logged to $logpath/ssh/alterd_keys-$(date "+%H:%M").txt and removed.
alterd unusable copies have been made in $logpath/ssh/alterd_keys-$(date "+%H:%M").txt"
pause_script
clear





man_os () {
    select os in "Debian" "Ubuntu" "Fedora" "Splunk" "CentOS 7"; do
        case $os in
            "Debian" ) os="Debian" os_type="Debian"; break;;
            "Ubuntu" ) os="Ubuntu" os_type="Debian"; break;;      
            "Fedora" ) os="Fedora" os_type="redhat"; break;;
            "Splunk" ) os="Splunk" os_type="redhat"; break;;
            "CentOS 7" ) os="CentOS 7" os_type="redhat"; break;;
            * ) echo "Invalid selection";;
        esac
    done
}

auto_os () {
    os=$(grep "ID=" /etc/os-release | sed '/^V/d' | cut -c 4- | tr -d '\"')
    if [ "$os" = "debian" ]; then
        os="Debian" os_type="Debian"
        return
    elif [ "$os" = "ubuntu" ]; then
        os="Ubuntu" os_type="Debian"
        return
    elif [ "$os" = "fedora" ]; then
        os="Fedora" os_type="redhat"
        return
    elif [ "$os" = "centos" ]; then
        os="Centos" os_type="redhat"
        return        
    else
        echo "Failed to determain OS going stick boi"
        man_os
    fi

}

open_menu () {
    if [ "$os_type" = "redhat" ]; then
        clear
        redhat_main_menu
        elif [ "$os_type" = "Debian" ]; then
        clear
        Debian_main_menu

        else echo "Uh you shouldn't see this"

        fi    
}

redhat_main_menu () {
    echo "OS is" "$os"
    select ubuntu_option in "Remove ssh" "Change ALL users passwords" "Check users that can login" "Check Firewall" "users w/o passwords" "cron check" "remove users cron" "Fix ECOMM" "find setuid" "marmot" "quick change pass" "fedora fix" "fix splunk" "lock all non users" "mysql user check"; do
        case $ubuntu_option in
            "Remove ssh" ) red_remove_ssh; open_menu;;
            "Change ALL users passwords" ) change_all_pass; open_menu;;
            "Check users that can login" ) echo "not done"; open_menu;;
            "Check Firewall" ) red_firewall_check; open_menu;;
            "Enter services" ) echo "Should auto find service but have option to add man"; break;;
            "users w/o passwords" ) users_no_pass; open_menu;;
            "cron check" ) cron_check; open_menu;;
        #  "CentOS 7" ) echo "CentOS 7"; break;;
            "remove cron" ) remove_cron; open_menu;;
            "Fix ECOMM" ) ecom_fix; open_menu;;
            "find setuid" ) find_setuid; open_menu;;
            "marmot" ) marmot; open_menu;;
            "quick change pass" ) quick_change_pass; open_menu;;
            "fedora fix" ) fedora_fix; open_menu;;           
            "fix splunk" ) fix_splunk; open_menu;;
            "lock all non users" ) lock_all_non_users; open_menu;;
            "mysql user check" ) mysql_user_check; open_menu;;
            * ) echo "Invalid selection"; sleep .7; clear; redhat_main_menu ;;
        esac
    done    
}


Debian_main_menu () {
    clear
    echo "OS is" "$os"
    select ubuntu_option in "Remove ssh" "Change ALL users passwords" "Check users that can login" "users w/o passwords" "Check Firewall" "Remove .ssh" "Backup dirs" "cron check" "remove users cron" "find setuid" "marmot" "quick change pass" "tripwire" "mysql user check" "ubuntu fix"; do
        case $ubuntu_option in
            "Remove ssh" ) deb_remove_ssh;;
            "Change ALL users passwords" ) change_all_pass; open_menu;;
            "Check users that can login" ) echo "Ubuntu 14"; break;;
            "Check Firewall" ) deb_firewall_check;;
            "Enter services" ) echo "Should auto find service but have option to add man"; break;;
            "users w/o passwords" ) users_no_pass;;
            "Remove .ssh" ) remove_.ssh; open_menu;;
            "Backup dirs" ) backup; open_menu;;
        #  "CentOS 7" ) echo "CentOS 7"; break;;
            "cron check" ) cron_check; open_menu;;
            "remove users cron" ) remove_cron; open_menu;;
            "find setuid" ) find_setuid; open_menu;;
            "marmot" ) marmot; open_menu;;            
            "quick change pass" ) quick_change_pass; open_menu;;
            "tripwire" ) tripwire; open_menu;;
            "mysql user check" ) mysql_user_check; open_menu;;
            "ubuntu fix" ) ubuntu_fix; open_menu;;
            "lock all non users" ) lock_all_non_users; open_menu;;
            
            * ) echo "Invalid selection"; sleep .7; clear; Debian_main_menu ;;
        esac
    done    

}

#start of opeing menus from $os value



remove_.ssh() {
    # look at this i dont think im done test to make sure i think its done jan18 11pm
    for user in $users;
    do echo "Removing $user .ssh dir"
        log_command "rm -rf $user/.ssh)"
        rm -rf /home/"$user"/.ssh 
    done
}

deb_remove_ssh () {
    echo "this will completly remove ssh and prevent future installs"
    echo "This will also most likey remove any ssh keys so run "Check ssh keys" if you havent before (check logs in $logpath/ssh)"
    echo "removing all users in passwd list .ssh"
    remove_.ssh
    read -p  "Press enter to remove SSH"
    echo "Removing openssh-server"
    sudo apt-get remove openssh-server
    echo "Purging openssh-server"
    sudo apt-get purge openssh-server
    sudo apt-get autoremove
    sudo touch /etc/apt/preferences.d/block-ssh
    echo "Package: openssh-server" | sudo tee -a /etc/apt/preferences.d/block-ssh > /dev/null
    echo "Pin: version *" | sudo tee -a /etc/apt/preferences.d/block-ssh > /dev/null
    echo "Pin-Priority: -1" | sudo tee -a /etc/apt/preferences.d/block-ssh > /dev/null
    echo "# removed SSH $(date)" >> $logpath/ran_commands.txt
    log_command "sudo apt-get remove openssh-server"
    log_command "sudo apt-get purge openssh-server"
    log_command "sudo apt-get autoremove"
    log_command "sudo touch /etc/apt/preferences.d/block-ssh"
    log_command "echo 'Package: openssh-server' | sudo tee -a /etc/apt/preferences.d/block-ssh > /dev/null"
    log_command "echo 'Pin: version *' | sudo tee -a /etc/apt/preferences.d/block-ssh > /dev/null"
    log_command "echo 'Pin-Priority: -1' | sudo tee -a /etc/apt/preferences.d/block-ssh > /dev/null"
    clear
    open_menu      
}

red_remove_ssh() {
    echo "this will completly remove ssh and prevent future installs"
    echo "This will also most likey remove any ssh keys so run "Check ssh keys" if you havent before"
    echo "Removing openssh-server"
    echo "# removed (REDHAT) SSH $(date)" >> $logpath/ran_commands.txt
    log_command "yum remove openssh-server"
    yum remove openssh-server
    echo "Removing /etc/ssh"
    log_command "rm -rf /etc/ssh"
    rm -rf /etc/ssh
    echo "Removing /etc/ssh/ssh_host_*"
    log_command "rm -rf /etc/ssh/ssh_host_*"
    rm -rf /etc/ssh/ssh_host_*
    echo "Disabling sshd.service"
    log_command "systemctl disable sshd.service"
    systemctl disable sshd.service
    if id -u sshd > /dev/null 2>&1; then
        echo "Removing user sshd"
        log_command "userdel sshd"
        userdel sshd
        else echo "$(date) The user "sshd" dose not exsit" >> $logpath/ran_commands.txt
    fi
    echo "Touching /etc/yum.conf"
    log_command "touch /etc/yum.conf"
    touch /etc/yum.conf

    echo "Adding 'exclude=openssh*' to /etc/yum.conf"
    log_command "echo 'exclude=openssh*' >> /etc/yum.conf"
    echo 'exclude=openssh*' >> /etc/yum.conf
    clear
    open_menu       
}

users_no_pass() {
    nopass=$(passwd -S -a | grep NP | cut -f1 -d" ")
    echo "$nopass" > $logpath/user-logs/users_with_no_pass-"$(date "+%H:%M")".txt
    clear
    for user in $nopass
        do clear
            echo "user $user has no password enter one now?"
            read -p "enter 1 to set $user's password else hit enter to skip this user: " setpass
            if [ "$setpass" = "1" ]; then
                passwd "$user"
            else clear
                echo "ok loged users that had no password in $logpath"
                echo "going to main menu"
                pause_script
                clear
                open_menu
            fi
    done
}

change_all_pass() {
    clear
    read -p "This will prompt you to change ALL users passwords.
    enter 1 to continue or enter to go back to main menu: " ask_cap
    clear
    if [ "$ask_cap" = "1" ]; then
        for user in $users
        do echo "enter new password for $user"
            passwd "$user"
            log_command "passwd $user"
        done
        open_menu
    else clear
        open_menu
    fi
}

deb_firewall_check() {
    if command -v ufw >/dev/null 2>&1; then
        echo "UFW installed would you like to reset and open set ports or custom ports?
    1. set ports
    2. custom ports
    Enter to skip"
        read -p "Option:" ufw_set
        if [ "$ufw_set" = 1 ]; then
            echo "Restting UFW..."
            sudo ufw --force reset
            log_command "sudo ufw --force reset"
            echo "Enableing UFW"
            sudo ufw enable
            log_command "sudo ufw enable"   
            echo "Setting default deny incoming and default allow outgoing"         
            sudo ufw default deny incoming
            log_command "sudo ufw default deny incoming"
            sudo ufw default allow outgoing
            log_command "sudo ufw default allow outgoing"
            clear
            echo "enter the number that you want to allow on the firewall"
            select os in "HTTP" "EMAIL" "DNS" "NTP"; do
                case $os in
                    "HTTP" ) sudo ufw allow 80/tcp,443/tcp; log_command "sudo ufw allow 80/tcp,443/tcp"; log_command "ufw enabled"; ufw enabled;  echo "Here are the firewall rules Enter to continue"; sudo ufw status; read -p;  open_menu;;
                    "EMAIL" ) sudo  ufw allow "${email_ports[0]}","${email_ports[1]}","${email_ports[2]}","${email_ports[3]}","${email_ports[4]}", "${email_ports[5]}"; log_command "sudo ufw allow ${email_ports[0]},{http_ports[1]},${email_ports[2]},${email_ports[3]},${email_ports[4]}", "${email_ports[5]}"; log_command "ufw enabled"; ufw enabled;  echo "Here are the firewall rules Enter to continue"; sudo ufw status; read -p;  open_menu;;      
                    "DNS" ) sudo ufw allow 53/udp; log_command "sudo ufw allow ${dns_ports[0]}"; log_command "ufw enabled"; ufw enabled;  echo "Here are the firewall rules Enter to continue"; sudo ufw status; read -p;  open_menu;;
                    "NTP" ) sudo ufw allow 123; log_command "sudo ufw allow 123"; log_command "ufw enabled"; ufw enabled;  echo "Here are the firewall rules Enter to continue"; sudo ufw status; read -p;  open_menu;;
                    "Splunk" ) sudo ufw allow 8089; log_command "sudo ufw allow 8089"; log_command "ufw enabled"; ufw enabled;  echo "Here are the firewall rules Enter to continue"; sudo ufw status; read -p;  open_menu;;
                    * ) echo "Invalid selection";;
                esac
            done
            clear
            open_menu                

        elif [ "$ufw_set" = "2" ]; then
            clear
            echo "Manual mode"
            echo "Please enter ports divided by spaces. 80 443..."
            read -a cust_ports
            clear
            echo "allowing ports ${cust_ports[*]}"
            for port in "${cust_ports[@]}"; do
                sudo ufw allow "$port"
                log_command "sudo ufw allow $port"
                done
            sudo ufw enable
            log_command "ufw enabled"
            echo "Here are the firewall rules Enter to continue"; sudo ufw status; read -p;          
            clear
            open_menu        
        else
            clear
            open_menu               

        fi
        
    else 
        clear
        echo "UFW is not installed"
        echo "Would you like to install UFW, enable and set ports now?"
        read -p "Enter 1 to install or enter to skip: " ufw_ins
        if [ "$ufw_ins" = "1" ]; then
            echo "Installing UFW with apt now..."
            sudo apt install ufw -y
            log_command "sudo apt install ufw -y"
            echo "Restting UFW..."
            sudo ufw --force reset
            log_command "sudo ufw --force reset"
            echo "Enableing UFW"
            sudo ufw enable
            log_command "sudo ufw enable"   
            echo "Setting default deny incoming and default allow outgoing"         
            sudo ufw default deny incoming
            log_command "sudo ufw default deny incoming"
            sudo ufw default allow outgoing
            log_command "sudo ufw default allow outgoing"
            clear
            deb_firewall_check      
        fi
    fi
}

red_firewall_check() {
    if command -v firewalld >/dev/null 2>&1; then
        echo "Firewalld is installed"
        echo "Would you like to reset, enable and set ports now?
        1. set ports
        2. custom ports
        Enter to skip"
        read redfwinstall
        if [ "$redfwinstall" = "1" ]; then
            echo "Backing up firewall config ""/etc/firewalld/zones"" "
            mkdir $backuppath/zonebackup/zonebackup-"$(date "+%H:%M")"
            log_command "mkdir -p $backuppath/zonebackup/zonebackup-$(date "+%H:%M")"
            cp /etc/firewalld/zones/* $backuppath/zonebackup/zonebackup-"$(date "+%H:%M")"
            log_command "cp /etc/firewalld/zones/* $backuppath/zonebackup/zonebackup-$(date "+%H:%M")"
            sudo rm -rf /etc/firewalld/zones/*
            for srv in $(firewall-cmd --list-services);do firewall-cmd --remove-service=$srv; done
            sudo firewall-cmd --complete-reload
            sudo iptables -X
            sudo iptables -F
            sudo iptables -Z
            sudo systemctl restart firewalld
            log_command "rm -rf /etc/firewalld/zones/*"; log_command "sudo firewall-cmd --complete-reload"; log_command "sudo iptables -X"; log_command "sudo iptables -F"; log_command "sudo iptables -Z"; log_command "sudo systemctl restart firewalld"; 
            echo "enter the number that you want to allow on the firewall"
            select port in "HTTP" "EMAIL" "DNS" "NTP"; do
                case $port in
                    "HTTP" ) for port in "${http_ports[@]}"; do sudo firewall-cmd --add-port="$port" --permanent; sudo firewall-cmd -reload; log_command "sudo firewall-cmd -reload"; log_command "sudo firewall-cmd  --add-port=$port/tcp --permanent"; done; echo "Here are the firewall rules"; sudo firewall-cmd --list-ports; read -p "Enter to continue";  open_menu;;
                    "EMAIL" ) for port in "${email_ports[@]}"; do sudo firewall-cmd --add-port="$port" --permanent; sudo firewall-cmd -reload; log_command "sudo firewall-cmd -reload"; log_command "sudo firewall-cmd  --add-port=$port/tcp --permanent"; done; echo "Here are the firewall rules"; sudo firewall-cmd --list-ports; read -p "Enter to continue";  open_menu;;
                    "DNS" ) sudo firewall-cmd  --add-port=53/udp --permanent;  sudo firewall-cmd -reload; log_command "sudo firewall-cmd -reload"; log_command "sudo firewall-cmd  --add-port=53/udp --permanent"; echo "Here are the firewall rules"; sudo firewall-cmd --list-ports; read -p "Enter to continue";  open_menu;;
                    "NTP" ) sudo firewall-cmd  --add-port=123/udp --permanent;  log_command "sudo firewall-cmd  --add-port=123/udp --permanent"; echo "Here are the firewall rules"; sudo firewall-cmd --list-ports; read -p "Enter to continue";  open_menu;;
                    * ) echo "Invalid selection";;
                esac
            done        
        elif [ "$redfwinstall" = "2" ]; then
                    clear
                    echo "Manual mode"
                    echo "Please enter ports divided by spaces (All ports will be TCP not udp). 80 443..."
                    read  -a cust_ports
                    clear
                    echo "allowing ports ${cust_ports[*]}"
                    for port in "${cust_ports[@]}"; do
                        sudo firewall-cmd  --add-port="$port"/tcp --permanent
                        log_command "firewall-cmd  --add-port=$port/tcp --permanent"
                        done
                    echo "Here are the firewall rules Enter to continue"
                    sudo firewall-cmd -reload
                    sudo firewall-cmd --list-ports;
                    read -p;
                    clear
                    open_menu
        fi

    else
        if command -v iptables >/dev/null 2>&1; then
                echo "iptables is installed"
                echo "Dont run iptables on anything other then centOS 6"
                echo "Enter what you want to do"
            select port in "HTTP" "EMAIL" "DNS" "NTP"; do
                case $port in
                    "HTTP" ) for port in "${http_ports[@]}"; do sudo iptables -A INPUT -p tcp --dport "$port" -j ACCEPT; log_command "sudo iptables -A INPUT -p tcp --dport $port -j ACCEPT"; done;  open_menu;;
                    "EMAIL" ) for port in "${email_ports[@]}"; do sudo iptables -A INPUT -p tcp --dport "$port" -j ACCEPT; log_command "sudo iptables -A INPUT -p tcp --dport $port -j ACCEPT"; done;  open_menu;;      
                    "DNS" ) sudo iptables -A INPUT -p udp --dport 53 -j ACCEPT; log_command "sudo iptables -A INPUT -p udp --dport 53 -j ACCEPT";  open_menu;;
                    "NTP" ) sudo iptables -A INPUT -p udp --dport 123 -j ACCEPT; log_command "sudo iptables -A INPUT -p udp --dport 123 -j ACCEPT"; open_menu;;
                    * ) echo "Invalid selection";;
                esac
            done 
        else
            echo "Neither firewalld nor iptables found!"
            echo "Would you like to install a firewall?
        1. Install firewalld (centOS7 and fedora21)
        2. Install IPtables (centos6 splunk)
        Enter to skip"
        read  install_firewall
            if [ "$install_firewall" = 1 ]; then
            sudo yum install firewalld -y
            log_command "sudo yum install firewalld -y"
            open_menu

            elif [ "$install_firewall" = 2 ]; then
            sudo yum install iptables-services -y
            log_command "sudo yum install iptables-services -y"
            open_menu
            fi
        fi
    fi

}

backup() {
    echo "Please enter from the list of predesited dir or enter the path to the folder you want backed up: /var/www/html..."
    select backupdir in "NGINX" "Apache" "MySQL" "Splunk" "NTP" "DNS" "SMTP" "IMAP"; do
        case $backupdir in
            "NGINX" ) echo "Backing up NGINX config and data dir ""/usr/share/nginx/html /etc/nginx"" "; mkdir -p $backuppath/nginx/nginx-backup-"$(date "+%H:%M")"; cp  /usr/share/nginx/html /etc/nginx $backuppath/nginx/nginx-backup-"$(date "+%H:%M")"; echo "This is what was ran: cp  /usr/share/nginx/html /etc/nginx $backuppath/nginx/nginx-backup-$(date "+%H:%M")">> $backuppath/nginx/nginx-backup-"$(date "+%H:%M")"/nginx-backup-log.txt; log_command "mkdir -p $backuppath/nginx/nginx-backup-$(date "+%H:%M")"; log_command "cp  /usr/share/nginx/html /etc/nginx $backuppath/nginx/nginx-backup-$(date "+%H:%M")"; open_menu;;
            "Apache(HTTPD)" ) echo "Backing up Apache(HTTPD) config and data dir ""/var/www /etc/httpd"" "; mkdir -p $backuppath/apache/apache-backup-"$(date "+%H:%M")"; cp  /var/www /etc/httpd $backuppath/apache/apache-backup-"$(date "+%H:%M")"; echo "cp  /var/www /etc/httpd $backuppath/apache/apache-backup-$(date "+%H:%M")" >> $backuppath/apache/apache-backup-"$(date "+%H:%M")"/apache-backup-log.txt; log_command "mkdir -p $backuppath/apache/apache-backup-$(date "+%H:%M")"; log_command "cp  /var/www /etc/httpd $backuppath/apache/apache-backup-$(date "+%H:%M")"; open_menu;;
            "MySQL" ) os="MySQL"; os_type="database server"; break;;
            "Splunk" ) os="Splunk"; os_type="log management"; break;;
            "NTP" ) os="NTP"; os_type="network protocol"; break;;
            "DNS" ) os="DNS"; os_type="network protocol"; break;;
            "SMTP" ) os="SMTP"; os_type="mail protocol"; break;;
            "IMAP" ) os="IMAP"; os_type="mail protocol"; break;;
            * ) echo "Invalid selection";;
        esac
    done
}

cron_check() {
    for user in $users
    do
        echo "User: $user"
        crontab -l -u $user
        read -p "Press enter to continue"
    done
    clear
    echo "No more users make sure you took screen shots if any crontabs were found!"
    pause_script
}

remove_cron() {
    for user in $users
    do 
    echo "Removing $user's cron"
    crontab -r -u $user
    done
    clear
    echo "No more users"
    pause_script    
}

ecom_fix() {

    #TODO
        # Change mysql ip from 0.0.0.0 to 127.0.0.1 (done?)
        #Remove ssh
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
    echo "Enter the mysql root password you just set"
    mysql -u root -p -e "CREATE USER 'prestashop'@'localhost' IDENTIFIED BY '$pass'; GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, INDEX, ALTER, DROP, LOCK TABLES ON prestashop.* TO 'prestashop'@'localhost'; FLUSH PRIVILEGES; EXIT;"
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
    pass=0
    pause_script
    sudo find /etc/httpd/ /var/www/ /usr/share/phpMyAdmin -type d -exec chmod 755 {} \;
    sudo find /etc/httpd/ /var/www/ /usr/share/roundcubemail -type f -exec chmod 644 {} \;
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
}

fedora_fix() {
    #TODO
        # Remember the "real" database is roundcubemail not roundcube
        #config database for roundcube (etc/roundcubemail/config.inc.php)
        #does roundcube need to be accessible from outside? (yes?)
        #remove installer
        #check out htaccess (https://github.com/roundcube/roundcubemail/blob/ff2d721680f9f9ede820e69e3116fe3684d6149e/INSTALL#L163)
        #roundcubemail.conf is all wrong allowing all users to see everything chnage to deny from all instead of allow
        #fix perms on all /etc/httpd/ var/www/ /usr/share/roundcubemail (defaiult apache perms)
        #set allow overide to All in httpd.conf
        #add htacses in bin folder (deny from all)
    
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


    

}


motd() {
echo > /etc/motd
echo > /etc/issue
echo "UNAUTHORIZED ACCESS TO THIS DEVICE IS PROHIBITED" | sudo tee -a /etc/motd /etc/issue
echo "You must have explicit, authorized permission to access or configure this device. Unauthorized attempts and actions to access or use this system may result in civil and/or criminal penalties. All activities performed on this device are logged and monitored." | sudo tee -a /etc/motd /etc/issue

}


fix_splunk() {
    chmod -R 644 /opt/splunk/*
    chmod -R 755 /opt/splunk/bin/
    chown -R splunk:splunk /opt/splunk
    chown -R splunk:splunk /opt/splunk/*
    echo "that only changed perms check /root.splunk and other stuff"
    echo "It set perms to the user splunk make sure that right"
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
}

find_setuid() {
    clear
    setuid=$(find / -perm -u=s -type f 2>/dev/null)
    for i in $setuid; do ls -la "$i"; done
}

lock_all_users() {
    sudo awk -F: '{ if ($1 != "root" && $1 != "sysadmin") system("passwd -l " $1) }' /etc/passwd
}


quick_change_pass() {
    read -p "Enter the password you want to set all users to including root: " password
        for user in `awk -F: '($3>=1000)&&($1!="nobody"){print $1}' /etc/passwd`
    do
        echo "$password" | sudo passwd --stdin "$user"
    done
}

lock_all_non_users() {
    for user in `awk -F: '($1!="root")&&($1!="nobody")&&($1!="sysadmin"){print $1}' /etc/passwd`
    do
        passwd -l $user
    done
}

marmot() {
    read -p "Run this on differnt tty then tty1"
    if [ $os_type = "redhat" ]; then 
        sudo yum install -y inotify-tools
    elif [ $os_type = "Debian" ]; then 
        sudo apt install -y inotify-tools
    else echo "Is your os not set??"

    fi
    read -e -p "Enter path of dir to monitor (You can do multiple paths.. /var/www /etc/mysql): " dirtowatch; inotifywait -r -m $dirtowatch | ts '[%H:%M:%S]' | tee -a ./logs/modifed-files.txt
}

mysql_user_check() {
    mysql -u root -p -e "SELECT User, Host, authentication_string FROM mysql.user;"
    pause_script
}

tripwire() {

    sudo apt update 
    sudo apt install tripwire
    yum update 
    yum install epel-release 
    yum install tripwire
    tripwire –-init
    tripwire  --check

    crontab -e
    40 5  *  *  *  /usr/sbin/tripwire   --check
}


motd
auto_os

echo "OS detected: $os
Enter 1 to switch OS's or enter to continue"
read ask_man
clear
if [ "$ask_man" = "1" ]; then
    clear
    man_os
fi
clear
open_menu

