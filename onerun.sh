#!/bin/bash
#source functions
clear
users=$(awk -F':' '{ print $1}' /etc/passwd)
# touch /var/log/onerun-history.txt
logpath=./logs

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

echo "Logs will be stored in $logpath/"
echo "Looking for ssh authorized_keys..."
find /  -type f -name "authorized_keys" 2>/dev/null > $logpath/ssh/found-ssh-keys-"$(date "+%H:%M")".txt
keys_path=$(find /  -type f -name "authorized_keys" 2>/dev/null)
for path in $keys_path
    do cp "$path" $logpath/ssh/unalterd_keys-"$(date "+%H:%M")".txt
        log_command "mv $path $logpath/ssh/unalterd_keys-$(date "+%H:%M").txt"
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
    echo "OS is" "$os"
    select ubuntu_option in "Remove ssh" "Change ALL users passwords" "Check users that can login" "users w/o passwords"; do
        case $ubuntu_option in
            "Remove ssh" ) echo "Will remove ssh "; break;;
            "Change ALL users passwords" ) chnage_all_pass;;
            "Check users that can login" ) echo "Ubuntu 14"; break;;
            "Check Firwall" ) echo "Check UFW and service ports"; break;;
            "Enter services" ) echo "Should auto find service but have option to add man"; break;;
            "users w/o passwords" ) users_no_pass;;
        #  "CentOS 7" ) echo "CentOS 7"; break;;
            * ) echo "Invalid selection"; sleep .7; clear; Debian_main_menu ;;
        esac
    done    

}

#start of opeing menus from $os value

open_menu () {
    if [ "$os_type" = "redhat" ]; then
        redhat_main_menu
        elif [ "$os_type" = "Debian" ]; then
        Debian_main_menu

        else echo "Uh you shouldn't see this"

        fi    
}

remove_.ssh() {
    # look at this i dont think im done
    for user in $users;
    do echo "Removing $user .ssh dir"
        log_command "rm -rf $user)"
        rm -rf /home/$user/.ssh 
    done
}

deb_remove_ssh_diabled () {
    echo "this will completly remove ssh and prevent future installs"
    echo "This will also most likey remove any ssh keys so run "Check ssh keys" if you havent before"
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


