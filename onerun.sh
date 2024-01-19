#!/bin/bash
#source functions
clear
users=$(awk -F':' '{ print $1}' /etc/passwd)
logpath=./logs
http_ports=(80 443)
email_ports=(25 587 465 110 995)
dns_ports=(53)


#why not
pause_script() {
    read -r -p "Press Enter to continue..."
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
read -r -p

echo "Logs will be stored in $logpath/"
echo "Looking for ssh authorized_keys..."
find /  -type f -name "authorized_keys" 2>/dev/null > $logpath/ssh/found-ssh-keys-"$(date "+%H:%M")".txt
keys_path=$(find /  -type f -name "authorized_keys" 2>/dev/null)
for path in $keys_path
    do cp "$path" $logpath/ssh/unalterd_keys-"$(date "+%H:%M")".txt
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
echo "If any keys have been found they have been logged to $logpath/ssh/found_keys-DATE.txt and removed.
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
    os=$(grep "ID=" /etc/os-release | sed '/^V/d' | cut -c 4-)
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
        redhat_main_menu
        elif [ "$os_type" = "Debian" ]; then
        Debian_main_menu

        else echo "Uh you shouldn't see this"

        fi    
}

redhat_main_menu () {
    echo "OS is" "$os"
    select ubuntu_option in "Remove ssh" "Change ALL users passwords" "Check users that can login" "users w/o passwords"; do
        case $ubuntu_option in
            "Remove ssh" ) echo "Will remove ssh "; break;;
            "Change ALL users passwords" ) echo "Will change all user passwords"; break;;
            "Check users that can login" ) echo "Ubuntu 14"; break;;
            "Check Firwall" ) echo "Check UFW and service ports"; break;;
            "Enter services" ) echo "Should auto find service but have option to add man"; break;;
            "users w/o passwords" ) users_no_pass;;
        #  "CentOS 7" ) echo "CentOS 7"; break;;
            * ) echo "Invalid selection"; sleep .7; clear; redhat_main_menu ;;
        esac
    done    
}


Debian_main_menu () {
    clear
    echo "OS is" "$os"
    select ubuntu_option in "Remove ssh" "Change ALL users passwords" "Check users that can login" "users w/o passwords" "Check Firewall"; do
        case $ubuntu_option in
            "Remove ssh" ) deb_remove_ssh;;
            "Change ALL users passwords" ) chnage_all_pass;;
            "Check users that can login" ) echo "Ubuntu 14"; break;;
            "Check Firewall" ) deb_firewall_check;;
            "Enter services" ) echo "Should auto find service but have option to add man"; break;;
            "users w/o passwords" ) users_no_pass;;
        #  "CentOS 7" ) echo "CentOS 7"; break;;
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

deb_remove_ssh_diabled () {
    echo "this will completly remove ssh and prevent future installs"
    echo "This will also most likey remove any ssh keys so run "Check ssh keys" if you havent before (check logs in $logpath/ssh)"
    echo "removing all users in passwd list .ssh"
    remove_.ssh
    read -p -r "Press enter to remove SSH"
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
            echo "enter 1 to set $user's password else hit enter to skip this user"
            read -r setpass
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

chnage_all_pass() {
    clear
    echo "This will prompt you to change ALL users passwords.
    enter 1 to continue or enter to go back to main menu"
    read -r ask_cap
    clear
    if [ "$ask_cap" = "1" ]; then
        for user in $users
        do echo "enter new password for $user"
            passwd "$user"
            log_command "passwd $user"
        done
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
        read -r ufw_set
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
            select os in "HTTP" "EMAIL" "DNS"; do
                case $os in
                    "HTTP" ) sudo ufw allow "${http_ports[0]}","${http_ports[1]}"; log_command "sudo ufw allow ${http_ports[0]},${http_ports[1]}"; open_menu;;
                    "EMAIL" ) sudo  ufw allow "${email_ports[0]}","${email_ports[1]}","${email_ports[2]}","${email_ports[3]}"."${email_ports[4]}"; log_command "sudo ufw allow ${email_ports[0]},{http_ports[1]},${email_ports[2]},${email_ports[3]}.${email_ports[4]}"; open_menu;;      
                    "DNS" ) sudo ufw allow "${dns_ports[0]}"; log_command "sudo ufw allow ${dns_ports[0]}"; open_menu;;
                    * ) echo "Invalid selection";;
                esac
            done
            clear
            open_menu                

        elif [ "$ufw_set" = "2" ]; then
            clear
            echo "Manual mode"
            echo "Please enter ports divided by spaces. 80 443..."
            read -r -a cust_ports
            clear
            echo "allowing ports ${cust_ports[*]}"
            for port in "${cust_ports[@]}"; do
                sudo ufw allow "$port"
                log_command "sudo ufw allow $port"
                done
            sudo ufw enable
            clear
            open_menu        
        else
            clear
            open_menu               

        fi
        
    else 
        echo "UFW is not installed"
        echo "Would you like to install UFW, enable and set ports now?"
        echo "Enter 1 to install or enter to skip"
        read -r ufw_ins
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
            echo "UFW installed and enabled would you like to open set ports or custom ports?
    1. set ports
    2. custom ports
    Enter to skip"
            read -r deb_ports
            if [ "$deb_ports" = "1" ]; then
                echo "enter the number that you want to allow on the firewall"
                select os in "HTTP" "EMAIL" "DNS"; do
                    case $os in
                        "HTTP" ) sudo ufw allow "${http_ports[0]}","${http_ports[1]}"; log_command "sudo ufw allow ${http_ports[0]},${http_ports[1]}"; open_menu;;
                        "EMAIL" ) sudo  ufw allow "${email_ports[0]}","${email_ports[1]}","${email_ports[2]}","${email_ports[3]}"."${email_ports[4]}"; log_command "sudo ufw allow ${email_ports[0]},{http_ports[1]},${email_ports[2]},${email_ports[3]}.${email_ports[4]}"; open_menu;;      
                        "DNS" ) sudo ufw allow "${dns_ports[0]}"; log_command "sudo ufw allow ${dns_ports[0]}"; open_menu;;
                        * ) echo "Invalid selection";;
                    esac
                done
                clear
                open_menu                

            elif [ "$deb_ports" = "2" ]; then
                clear
                echo "Manual mode"
                echo "Please enter ports divided by spaces. 80 443..."
                read -r -a cust_ports
                clear
                echo "allowing ports ${cust_ports[*]}"
                for port in "${cust_ports[@]}"; do
                    sudo ufw allow "$port"
                    log_command "sudo ufw allow $port"
                    done
                sudo ufw enable
                clear
                open_menu
            else
                clear
                open_menu                
            fi
        fi
    fi
}

auto_os

echo "OS detected: $os
Enter 1 to switch OS's or enter to continue"
read -r ask_man
clear
if [ "$ask_man" = "1" ]; then
    clear
    man_os
fi
clear
open_menu


