#!/bin/bash
clear
mkdir ./logs
logpath=./logs
log_command() {
    echo "At $(date) the user $USER ran: $1" >> $logpath/ran_commands.txt
}

#check cron tab


#back up network config

#disable admin log (php)

#incidnet reports (good pdf? summary, affected vms, evidence and proff of removal)

#MYSQL back up and setup


#fix


# users=$(awk -F':' '{ print $1}' /etc/passwd)
# echo $users

# for user in $users;
#     do echo $user
# done

# find -name . "authorized_keys"
##DO NOT DELETE BELOW WORK ON REMOVING ALL SSH STUFF
# find /  -type f -name "authorized_keys" 2>/dev/null > ./logs/found-ssh-keys.txt

# remove_.ssh() {
#     for user in $users;
#     do echo "Removing $user .ssh dir"
#         log_command "rm -rf $user)"
#         rm -rf /home/$user/.ssh 
# done
# }

# cat ./logs/found-ssh-keys.txt | while read line 
# do
#    echo $line
# done
###########

# find auth keys files log them then delete all users .ssh

# users_no_pass() {
#     nopass=$(passwd -S -a | grep NP | cut -f1 -d" ")
#     echo "$nopass" > $logpath/users_with_no_pass-"$(date "+%H:%M")".txt
#     clear
#     for user in $nopass
#         do clear
#             echo "user $user has no password enter one now?"
#             echo "enter 1 to set $user's password else hit enter to skip this user"
#             read -r setpass
#             if [ "$setpass" = "1" ]; then
#                 passwd "$user"
#             else clear
#                 echo "ok loged users that had no password in $logpath"
#                 echo "going to main menu"
#                 open_menu
#             fi
#     done
# }
# auto_os () {
#     os=$(grep "ID=" /etc/os-release | sed '/^V/d' | cut -c 4-)
#     echo $os
#     if [ "$os" = "debian" ]; then
#         os="Debian" os_type="Debian"
#     elif [ "$os" = "ubuntu" ]; then
#         os="Ubuntu" os_type="Debian"
#     elif [ "$os" = "fedora" ]; then
#         os="Fedora" os_type="redhat"
#     else
#         echo "Failed to determain OS going stick mode boi"
#         man_os
#     fi
# }

# auto_os

#check var names before adding funtion and set to rm instead of cp and add commnd log



# findrm_keys() {
#     logpath=./logs
#     log_command() {
#         echo "At $(date) the user $USER ran: $1" >> $logpath/ran_commands.txt
#     }
#     find /  -type f -name "authorized_keys" 2>/dev/null > $logpath/ssh/found-ssh-keys-"$(date "+%H:%M")".txt
#     keys_path=$(find /  -type f -name "authorized_keys" 2>/dev/null)

#     for path in $keys_path
#         do cp "$path" $logpath/ssh/unalterd_keys-"$(date "+%H:%M")".txt
#             log_command "mv $path $logpath/ssh/unalterd_keys-$(date "+%H:%M").txt"
#             echo "$path:" >> $logpath/ssh/alterd_keys-"$(date "+%H:%M")".txt
#             log_command "echo $path: >> $logpath/ssh/alterd_keys-$(date "+%H:%M").txt"
#             sed -e 's/^.\{10\}//' $logpath/ssh/unalterd_keys-"$(date "+%H:%M")".txt >> $logpath/ssh/alterd_keys-"$(date "+%H:%M")".txt
#             log_command "sed -e 's/^.\{10\}//' $logpath/ssh/unalterd_keys-$(date "+%H:%M").txt >> $logpath/ssh/alterd_keys-$(date "+%H:%M").txt"
#             rm -rf $logpath/ssh/unalterd_keys-"$(date "+%H:%M")".txt
#             log_command "rm -rf $logpath/ssh/unalterd_keys-$(date "+%H:%M").txt"
#         done

# }
http_ports=(80 443)
email_ports=(25 587 465 110 995)
dns_ports=(53)


deb_firewall_check() {
    if command -v ufw >/dev/null 2>&1; then
        echo "UFW is installed"
    else 
        echo "UFW is not installed"
        echo "Would you like to install UFW, enable and set ports now?"
        echo "Enter 1 to install or enter to skip"
        read -r ufw_in
        if [ $ufw_in = "1" ]; then
            echo "Installing UFW with apt now..."
            sudo apt install ufw -y
            log_command "sudo apt install ufw -y"
            sudo ufw --force reset
            log_command "sudo ufw --force reset"
            sudo ufw enable
            log_command "sudo ufw enable"            
            sudo ufw default deny incoming
            log_command "sudo ufw default deny incoming"
            sudo ufw default allow outgoing
            log_command "sudo ufw default allow outgoing"

            echo "UFW installed and enabled would you like to open set ports or custom ports?
            1. set ports
            2. custom ports
            Enter to skip"
            read -r deb_ports
            if [ "$deb_ports" = "1" ]; then
                echo "enter the number that you want to allow on the firewall"
                select os in "HTTP" "EMAIL" "DNS"; do
                    case $os in
                        "HTTP" ) sudo ufw allow "${http_ports[0]}","${http_ports[1]}"; log_command "sudo ufw allow ${http_ports[0]},${http_ports[1]}";  break;;
                        "EMAIL" ) sudo  ufw allow "${email_ports[0]}","${email_ports[1]}","${email_ports[2]}","${email_ports[3]}"."${email_ports[4]}"; log_command "sudo ufw allow ${email_ports[0]},{http_ports[1]},${email_ports[2]},${email_ports[3]}.${email_ports[4]}"; break;;      
                        "DNS" ) sudo ufw allow "${dns_ports[0]}"; log_command "sudo ufw allow ${dns_ports[0]}"; break;;
                        * ) echo "Invalid selection";;
                    esac
                done

            elif [ "$deb_ports" = "2" ]; then
                echo "Manual mode"
                echo "Please enter ports divided by spaces. 80 443..."
                read -r -a cust_ports
                echo "allowing ports ${cust_ports[*]}"
                for port in "${cust_ports[@]}"; do
                    sudo ufw allow "$port"
                    log_command "sudo ufw allow $port"
                    done
                sudo ufw enable
            fi
        fi
    fi
}

deb_firewall_check