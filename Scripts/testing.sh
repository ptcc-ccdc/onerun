# #!/bin/bash
# clear
# mkdir -p ./logs
# logpath=./logs
# backuppath=./backups
# log_command() {
#     echo "At $(date) the user $USER ran: $1" >> $logpath/ran_commands.txt
# }

# #check cron tab


# #back up network config

# #disable admin log (php)

# #incidnet reports (good pdf? summary, affected vms, evidence and proff of removal)

# #MYSQL back up and setup


# #fix


# # users=$(awk -F':' '{ print $1}' /etc/passwd)
# # echo $users

# # for user in $users;
# #     do echo $user
# # done

# # find -name . "authorized_keys"
# ##DO NOT DELETE BELOW WORK ON REMOVING ALL SSH STUFF
# # find /  -type f -name "authorized_keys" 2>/dev/null > ./logs/found-ssh-keys.txt

# # remove_.ssh() {
# #     for user in $users;
# #     do echo "Removing $user .ssh dir"
# #         log_command "rm -rf $user)"
# #         rm -rf /home/$user/.ssh 
# # done
# # }

# # cat ./logs/found-ssh-keys.txt | while read line 
# # do
# #    echo $line
# # done
# ###########

# # find auth keys files log them then delete all users .ssh

# # users_no_pass() {
# #     nopass=$(passwd -S -a | grep NP | cut -f1 -d" ")
# #     echo "$nopass" > $logpath/users_with_no_pass-"$(date "+%H:%M")".txt
# #     clear
# #     for user in $nopass
# #         do clear
# #             echo "user $user has no password enter one now?"
# #             echo "enter 1 to set $user's password else hit enter to skip this user"
# #             read -r setpass
# #             if [ "$setpass" = "1" ]; then
# #                 passwd "$user"
# #             else clear
# #                 echo "ok loged users that had no password in $logpath"
# #                 echo "going to main menu"
# #                 open_menu
# #             fi
# #     done
# # }
# # auto_os () {
# #     os=$(grep "ID=" /etc/os-release | sed '/^V/d' | cut -c 4-)
# #     echo $os
# #     if [ "$os" = "debian" ]; then
# #         os="Debian" os_type="Debian"
# #     elif [ "$os" = "ubuntu" ]; then
# #         os="Ubuntu" os_type="Debian"
# #     elif [ "$os" = "fedora" ]; then
# #         os="Fedora" os_type="redhat"
# #     else
# #         echo "Failed to determain OS going stick mode boi"
# #         man_os
# #     fi
# # }

# # auto_os

# #check var names before adding funtion and set to rm instead of cp and add commnd log



# # findrm_keys() {
# #     logpath=./logs
# #     log_command() {
# #         echo "At $(date) the user $USER ran: $1" >> $logpath/ran_commands.txt
# #     }
# #     find /  -type f -name "authorized_keys" 2>/dev/null > $logpath/ssh/found-ssh-keys-"$(date "+%H:%M")".txt
# #     keys_path=$(find /  -type f -name "authorized_keys" 2>/dev/null)

# #     for path in $keys_path
# #         do cp "$path" $logpath/ssh/unalterd_keys-"$(date "+%H:%M")".txt
# #             log_command "mv $path $logpath/ssh/unalterd_keys-$(date "+%H:%M").txt"
# #             echo "$path:" >> $logpath/ssh/alterd_keys-"$(date "+%H:%M")".txt
# #             log_command "echo $path: >> $logpath/ssh/alterd_keys-$(date "+%H:%M").txt"
# #             sed -e 's/^.\{10\}//' $logpath/ssh/unalterd_keys-"$(date "+%H:%M")".txt >> $logpath/ssh/alterd_keys-"$(date "+%H:%M")".txt
# #             log_command "sed -e 's/^.\{10\}//' $logpath/ssh/unalterd_keys-$(date "+%H:%M").txt >> $logpath/ssh/alterd_keys-$(date "+%H:%M").txt"
# #             rm -rf $logpath/ssh/unalterd_keys-"$(date "+%H:%M")".txt
# #             log_command "rm -rf $logpath/ssh/unalterd_keys-$(date "+%H:%M").txt"
# #         done

# # }
# # http_ports=(80 443)
# # email_ports=(25 587 465 110 995)
# # dns_ports=(53)


# # deb_firewall_check() {
# #     if command -v ufw >/dev/null 2>&1; then
# #         echo "UFW is installed"
# #     else 
# #         echo "UFW is not installed"
# #         echo "Would you like to install UFW, enable and set ports now?"
# #         echo "Enter 1 to install or enter to skip"
# #         read -r ufw_in
# #         if [ "$ufw_in" = "1" ]; then
# #             echo "Installing UFW with apt now..."
# #             sudo apt install ufw -y
# #             log_command "sudo apt install ufw -y"
# #             sudo ufw --force reset
# #             log_command "sudo ufw --force reset"
# #             sudo ufw enable
# #             log_command "sudo ufw enable"            
# #             sudo ufw default deny incoming
# #             log_command "sudo ufw default deny incoming"
# #             sudo ufw default allow outgoing
# #             log_command "sudo ufw default allow outgoing"
# #             clear
# #             echo "UFW installed and enabled would you like to open set ports or custom ports?
# #     1. set ports
# #     2. custom ports
# #     Enter to skip"
# #             read -r deb_ports
# #             if [ "$deb_ports" = "1" ]; then
# #                 echo "enter the number that you want to allow on the firewall"
# #                 select os in "HTTP" "EMAIL" "DNS"; do
# #                     case $os in
# #                         "HTTP" ) sudo ufw allow "${http_ports[0]}","${http_ports[1]}"; log_command "sudo ufw allow ${http_ports[0]},${http_ports[1]}"; open_menu;;
# #                         "EMAIL" ) sudo  ufw allow "${email_ports[0]}","${email_ports[1]}","${email_ports[2]}","${email_ports[3]}"."${email_ports[4]}"; log_command "sudo ufw allow ${email_ports[0]},{http_ports[1]},${email_ports[2]},${email_ports[3]}.${email_ports[4]}"; open_menu;;      
# #                         "DNS" ) sudo ufw allow "${dns_ports[0]}"; log_command "sudo ufw allow ${dns_ports[0]}"; open_menu;;
# #                         * ) echo "Invalid selection";;
# #                     esac
# #                 done

# #             elif [ "$deb_ports" = "2" ]; then
# #                 clear
# #                 echo "Manual mode"
# #                 echo "Please enter ports divided by spaces. 80 443..."
# #                 read -r -a cust_ports
# #                 clear
# #                 echo "allowing ports ${cust_ports[*]}"
# #                 for port in "${cust_ports[@]}"; do
# #                     sudo ufw allow "$port"
# #                     log_command "sudo ufw allow $port"
# #                     done
# #                 sudo ufw enable
# #                 clear
# #                 open_menu
# #             else
# #                 clear
# #                 open_menu                
# #             fi
# #         fi
# #     fi
# # }

# # red_firewall_check() {
# # if command -v firewalld >/dev/null 2>&1; then
# #     echo "Firewalld is installed"
# #     echo "Would you like to reset, enable and set ports now?
# #     1. set ports
# #     2. custom ports
# #     Enter to skip"
# #     read -r redfwinstall
# #     if [ "$redfwinstall" = "1" ]; then
# #         echo "Backing up firewall config ""/etc/firewalld/zones"" "
# #         mkdir $backuppath/zonebackup/zonebackup-"$(date "+%H:%M")"
# #         log_command "mkdir $backuppath/zonebackup/zonebackup-$(date "+%H:%M")"
# #         cp /etc/firewalld/zones/* $backuppath/zonebackup/zonebackup-"$(date "+%H:%M")"
# #         log_command "cp /etc/firewalld/zones/* $backuppath/zonebackup/zonebackup-$(date "+%H:%M")"
# #         sudo rm -rf /etc/firewalld/zones/*
# #         sudo firewall-cmd --complete-reload
# #         sudo iptables -X
# #         sudo iptables -F
# #         sudo iptables -Z
# #         sudo systemctl restart firewalld
# #         log_command "rm -rf /etc/firewalld/zones/*"; log_command "sudo firewall-cmd --complete-reload"; log_command "sudo iptables -X"; log_command "sudo iptables -F"; log_command "sudo iptables -Z"; log_command "sudo systemctl restart firewalld"; 
# #         echo "enter the number that you want to allow on the firewall"
# #         select port in "HTTP" "EMAIL" "DNS" "NTP"; do
# #             case $port in
# #                 "HTTP" ) for port in "${http_ports[@]}"; do sudo firewall-cmd --zone=public --add-port="$port"/tcp --permanent; log_command "sudo firewall-cmd --zone=public --add-port=$port/tcp --permanent"; done;  open_menu;;
# #                 "EMAIL" ) for port in "${email_ports[@]}"; do sudo firewall-cmd --zone=public --add-port="$port"/tcp --permanent; log_command "sudo firewall-cmd --zone=public --add-port=$port/tcp --permanent"; done;  open_menu;;      
# #                 "DNS" ) sudo firewall-cmd --zone=public --add-port=53/udp --permanent; log_command "sudo firewall-cmd --zone=public --add-port=53/udp --permanent";  open_menu;;
# #                 "NTP" ) sudo firewall-cmd --zone=public --add-port=123/udp --permanent; log_command "sudo firewall-cmd --zone=public --add-port=123/udp --permanent"; open_menu;;
# #                 * ) echo "Invalid selection";;
# #             esac
# #         done        

# #     fi

# # else
# #     if command -v iptables >/dev/null 2>&1; then
# #             echo "iptables is installed"
# #             echo "Dont run iptables on anything other then centOS 6"
# #             echo "Enter what you want to do"
# #         select os in "HTTP" "EMAIL" "DNS" "NTP"; do
# #             case $os in
# #                 "HTTP" ) for port in "${http_ports[@]}"; do sudo iptables -A INPUT -p tcp --dport "$port" -j ACCEPT; log_command "sudo iptables -A INPUT -p tcp --dport $port -j ACCEPT"; done;  open_menu;;
# #                 "EMAIL" ) for port in "${email_ports[@]}"; do sudo iptables -A INPUT -p tcp --dport "$port" -j ACCEPT; log_command "sudo iptables -A INPUT -p tcp --dport $port -j ACCEPT"; done;  open_menu;;      
# #                 "DNS" ) sudo iptables -A INPUT -p udp --dport 53 -j ACCEPT; log_command "sudo iptables -A INPUT -p udp --dport 53 -j ACCEPT";  open_menu;;
# #                 "NTP" ) sudo iptables -A INPUT -p udp --dport 123 -j ACCEPT; log_command "sudo iptables -A INPUT -p udp --dport 123 -j ACCEPT"; open_menu;;
# #                 * ) echo "Invalid selection";;
# #             esac
# #         done 
# #     else
# #         echo "Neither firewalld nor iptables found!"
# #         echo "Would you like to install a firewall?
# #     1. Install firewalld (centOS7 and fedora21)
# #     2. Install IPtables (centos6 splunk)
# #     Enter to skip"
# #     read -r install_firewall
# #         if [ "$install_firewall" = 1 ]; then
# #         sudo yum install firewalld -y
# #         log_command "sudo yum install firewalld -y"
# #         open_menu

# #         elif [ "$install_firewall" = 2 ]; then
# #         sudo yum install iptables-services -y
# #         log_command "sudo yum install iptables-services -y"
# #         open_menu
# #         fi
# #     fi
# # fi

# # }


# # If installing on Ubuntu using apt-get, try /usr/share/nginx/www.

# # On more recent versions the path has changed to: /usr/share/nginx/html

# # red_firewall_check


# backup() {
#     echo "Please enter from the list of predesited dir or enter the path to the folder you want backed up: /var/www/html..."
#     select backupdir in "NGINX" "Apache(HTTPD)" "MySQL" "Splunk" "NTP" "DNS" "SMTP" "IMAP"; do
#         case $backupdir in
#             "NGINX" ) echo "Backing up NGINX config and data dir ""/usr/share/nginx/html /etc/nginx"" "; mkdir -p $backuppath/nginx/ngix-backup-"$(date "+%H:%M")"; cp -r /usr/share/nginx/html /etc/nginx $backuppath/nginx/ngix-backup-"$(date "+%H:%M")"; echo "This is what was ran: cp -r /usr/share/nginx/html /etc/nginx $backuppath/nginx/ngix-backup-$(date "+%H:%M")">> $backuppath/nginx/ngix-backup-"$(date "+%H:%M")"/nginx-backup-log.txt; log_command "mkdir -p $backuppath/nginx/ngix-backup-$(date "+%H:%M")"; log_command "cp -r /usr/share/nginx/html /etc/nginx $backuppath/nginx/ngix-backup-$(date "+%H:%M")"; open_menu;;
#             # add logging to apache
#             "Apache(HTTPD)" ) echo "Backing up Apache(HTTPD) config and data dir ""/var/www/* /etc/httpd/*"" "; mkdir -p $backuppath/nginx/apache-backup-"$(date "+%H:%M")"; cp -r /usr/share/nginx/html /etc/nginx $backuppath/apache/apache-backup-"$(date "+%H:%M")"; echo "This is what was ran: cp -r /usr/share/nginx/html /etc/nginx $backuppath/apache/apache-backup-$(date "+%H:%M")">> $backuppath/nginx/ngix-backup-"$(date "+%H:%M")"/nginx-backup-log.txt; log_command "mkdir -p $backuppath/apache/apache-backup-$(date "+%H:%M")"; log_command "cp -r /usr/share/nginx/html /etc/nginx $backuppath/nginx/ngix-backup-$(date "+%H:%M")"; open_menu;;
#             "MySQL" ) echo  "Not fast enough :("; break;;
#             "Splunk" ) echo  "Not fast enough :("; break;;
#             "NTP" ) echo  "Not fast enough :("; break;;
#             "DNS" ) oecho  "Not fast enough :("; break;;
#             "SMTP" ) echo  "Not fast enough :("; break;;
#             "IMAP" ) echo  "Not fast enough :("; break;;
#             * ) echo "Invalid selection";;
#         esac
#     done
# }
# backup

# log_command "mkdir -p $backuppath/nginx/ngix-backup-$(date "+%H:%M")"; log_command "cp -r /usr/share/nginx/html /etc/nginx $backuppath/nginx/ngix-backup-$(date "+%H:%M")";













read -p "Enter base IP address: " base_range
base_range_formated=$(echo $base_range | sed 's/\./ /g')
echo "Formatted base IP address: $base_range_formated"
read -p "Enter last IP in range: " max_range
max_range_formated=$(echo $max_range | sed 's/\./ /g')
echo "Formatted last IP address: $max_range_formated"
base_range_formated=( ${base_range_formated} )
max_range_formated=( ${max_range_formated} )
for i in {0..1}; do
    command[$i]="(${base_range_formated[$i]}\.)"
done

if [ ${max_range_formated[2]} != ${base_range_formated[2]} ]; then
    command[2]="([${base_range_formated[2]}-${max_range_formated[2]}]\.)"

    fi
last_octet_regex='([0-9]{1,3})'

full_pattern="${command[0]}${command[1]}${command[2]}$last_octet_regex"

echo "Full regex pattern: '$full_pattern'"

grep -E "$full_pattern" testing,log



# count=0
# for i in {0..3}; do
#     if [ ${base_range_formated[$i]} == ${max_range_formated[$i]} ]; then
#         echo "same"
#         command[$i]="(${base_range_formated[$i]}\.)"
#     elif [ $i == 3 ]; then
#             last_octet_regex='([0-9]{1,3})'
#     else 
#         echo "diff"
#         echo "else" $count $command
#         command[$i]='([0-9]{1}|1)'
        
#     fi
# done
# echo "$command"


# grep -E '192\.168\.1\.([0-9]{1,3})' filename


# grep -E '192\.168\.10\.([1-9][0-9]?|[1-9]|100)' filename