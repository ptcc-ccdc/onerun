#!/bin/bash

trap ctl-c SIGINT

# Function to check if a function exists and run it
run_function_if_exists() {
    if declare -F "$1" >/dev/null 2>&1; then
        $1
        open_menu
    else
        handle_error "Function '$1' does not exist!"
    fi
}

# Function to handle errors by displaying a dialog box
handle_error() {
    dialog --msgbox "$1" 10 40
}

# Function to manually select the operating system
man_os() {
    select os in "Debian" "Ubuntu" "Fedora" "Splunk" "CentOS 7"; do
        case $os in
        "Debian")
            os="Debian" os_type="Debian"
            break
            ;;
        "Ubuntu")
            os="Ubuntu" os_type="Debian"
            break
            ;;
        "Fedora")
            os="Fedora" os_type="redhat"
            break
            ;;
        "Splunk")
            os="Splunk" os_type="redhat"
            break
            ;;
        "CentOS 7")
            os="CentOS 7" os_type="redhat"
            break
            ;;
        *) echo "${YELLOW}Invalid selection${ENDCOLOR}" ;;
        esac
    done
}

# Function to automatically detect the operating system
auto_os() {
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
        echo -e "${YELLOW}Failed to determine OS, going stick boi${ENDCOLOR}"
        man_os
    fi
}

# Function to open the main menu based on OS type
open_menu() {
    if [ "$os_type" = "redhat" ]; then
        clear
        redhat_main_menu
    elif [ "$os_type" = "Debian" ]; then
        clear
        Debian_main_menu
    else
        echo "Uh, you shouldn't see this"
        man_os
    fi
}
# Function to handle Ctrl-C (SIGINT) interruption
ctl-c() {
    clear
    read -p "Are you sure you want to quit? Y/n: " ask_quit
    if [ "$ask_quit" == "n" ]; then
        clear
        open_menu
    fi
    echo -e "${ENDCOLOR}" "Good luck, hopefully something worked"
    echo -e "              0000_____________0000________0000000000000000__000000000000000000+\n            00000000_________00000000______000000000000000__0000000000000000000+\n           000____000_______000____000_____000_______0000__00______0+\n          000______000_____000______000_____________0000___00______0+\n         0000______0000___0000______0000___________0000_____0_____0+\n         0000______0000___0000______0000__________0000___________0+\n         0000______0000___0000______0000_________000___0000000000+\n         0000______0000___0000______0000________0000+\n          000______000_____000______000________0000+\n           000____000_______000____000_______00000+\n            00000000_________00000000_______0000000+\n              0000_____________0000________000000007;"
    if [ $dry_run -eq 1 ]; then
        rm -rf menu_choice.txt logs backups installed_potentially_malicious.txt installed_services.txt
    fi
    chattr +i $backuppath >/dev/null 2>&1
    killall=$(pgrep 'tail|onerun.sh')
    for i in $killall; do
        echo killing $i
        kill -9 $i
    done
    exit
}

# Pause script execution and prompt user to press Enter to continue
pause_script() {
    read -r -p "Press Enter to continue..."
    clear
}


# Function to log commands with timestamp and username
log_command() {
    echo -e "At $(date "+%H-%M") the user $USER ran: $1" >>"$logpath/ran_commands.txt"
}

    


# if [ $date == "01/25/25" ]; then
#     echo "Good Luck"
#        sleep 2
# fi

safety_check() {
    if [ $saftey -eq 1 ]; then
        echo -e "${RED}You are trying to run ${BOLDRED}${FUNCNAME[1]}${ENDCOLOR}${RED} whith the safty on. This is a destructive action.${ENDCOLOR}"
        echo -e "${RED}Type${ENDCOLOR} ${BOLDRED}I KNOW${ENDCOLOR}${RED} to temporarily set saftey = 0 (OFF)${ENDCOLOR} ${GREEN}"
        read skip_safe
        if [ "$skip_safe" = "I KNOW" ]; then
            pause_script
            saftey=0
        else
            echo -e "That is not ${BOLDRED}I KNOW${ENDCOLOR}"
            pause_script
            open_menu
        fi
    else
        if [ $safe_warn -eq 0 ]; then
            echo -e "This is a warning that the safty is ${BOLDRED}OFF${ENDCOLOR}" and the function ${BOLDRED}${FUNCNAME[1]}${ENDCOLOR} ${BOLDRED}WILL${ENDCOLOR}" be a destructive action"
            pause_script
        else
            clear
        fi
    fi
}

#!/bin/bash

# Function to check MySQL users
mysql_user_check() {
    mysql -u root -p -e "SELECT User, Host, authentication_string FROM mysql.user;"
    pause_script
}

# Function to find and list setuid files
find_setuid() {
    clear
    setuid=$(find / -perm -u=s -type f 2>/dev/null)
    for i in $setuid; do
        ls -la "$i"
    done
}

# Function to set the Message of the Day (MOTD)
motd() {
    echo > /etc/motd
    echo > /etc/issue
    echo "UNAUTHORIZED ACCESS TO THIS DEVICE IS PROHIBITED" | sudo tee -a /etc/motd /etc/issue
    echo "You must have explicit, authorized permission to access or configure this device. Unauthorized attempts and actions to access or use this system may result in civil and/or criminal penalties. All activities performed on this device are logged and monitored." | sudo tee -a /etc/motd /etc/issue
}

# Function to check user cron jobs
cron_check() {
    for user in $users; do
        echo "User: $user"
        crontab -l -u $user
        read -p "Press enter to continue"
    done
    clear
    echo "No more users. Make sure you took screenshots if any crontabs were found!"
    pause_script
}

# Function to remove user cron jobs
remove_cron() {
    for user in $users; do
        echo "Removing $user's cron"
        crontab -r -u $user
    done
    clear
    echo "No more users"
    pause_script
}

# Testing function
testingfunxc() {
    safety_check
    echo "0:" ${FUNCNAME[0]} "1:" ${FUNCNAME[1]} "2:" ${FUNCNAME[2]}
    read -p -e "This should match what you wanted to do"
}

# Function to run automatic tasks
auto_run() {
    source onerun.env
    mkdir -p $backuppath/ $logpath/user-logs $logpath/ssh
    log_command "mkdir -p $backuppath/ $onerun_root/ $logpath/user-logs"
    auto_os
    safety_check
    motd
    # Uncommenting below will restrict other users from proper permissions, potentially slowing down the red team
    # chmod 600 /etc/shadow
    # chmod 600 /etc/passwd
    # chown root:root /etc/shadow
    # chown root:root /etc/passwd
    echo -e "${GREEN}Looking for SSH authorized_keys...${ENDCOLOR}"
    find / -type f -name "authorized_keys" 2>/dev/null > $logpath/ssh/found-ssh-keys-"$(date "+%H-%M")".txt
    keys_path=$(find / -type f -name "authorized_keys" 2>/dev/null)
    for path in $keys_path; do
        cp "$path" $logpath/ssh/unaltered_keys-"$(date "+%H-%M")".txt
        echo -e "${RED}Key found:${ENDCOLOR} ${RED}$path${ENDCOLOR}"
        echo "$path:" >> $logpath/ssh/altered_keys-"$(date "+%H-%M")".txt
        sed -e 's/^.\{15\}//' $logpath/ssh/unaltered_keys-"$(date "+%H-%M")".txt >> $logpath/ssh/altered_keys-"$(date "+%H-%M")".txt
        rm -rf $logpath/ssh/unaltered_keys-"$(date "+%H-%M")".txt
        rm -rf "$path"
        log_command "mv $path $logpath/ssh/unaltered_keys-$(date "+%H-%M").txt"
        log_command "echo $path: >> $logpath/ssh/altered_keys-$(date "+%H-%M").txt"
        log_command "sed -e 's/^.\{15\}//' $logpath/ssh/unaltered_keys-$(date "+%H-%M").txt >> $logpath/ssh/altered_keys-$(date "+%H-%M").txt"
        log_command "rm -rf $logpath/ssh/unaltered_keys-$(date "+%H-%M").txt"
        log_command "rm -rf $path"
    done
    echo -e "${GREEN}If any keys have been found, they have been logged to${ENDCOLOR} $logpath/ssh/found_keys-DATE.txt and removed. Altered unusable copies have been made in $logpath/ssh/altered_keys-$(date "+%H-%M").txt"
    pause_script
    # rm -rf installed_potentially_malicious.txt installed_services.txt

    if [ -e "./installed_services.txt" ]; then # Not sure why I put this if condition
        rand_users_password
        clear
    fi
    run_function_if_exists "init-passwords"
    run_function_if_exists "servicectl_check"
}

# Function to check the service control method
servicectl_check() {
    if command -v systemctl &>/dev/null; then
        servicectl="systemctl"
    elif command -v service &>/dev/null; then
        servicectl="service"
    else
        echo "Service control method not found, defaulting to service"
        servicectl="service"
    fi

    if [ -d /etc/init.d ]; then
        echo -e "${YELLOW}Path /etc/init.d exists, take a look to see what there is${ENDCOLOR}"
    fi
}

# Function to check for potentially malicious services
potentially_malicious_services() {
    for i in ${potentially_malicious[@]}; do
        sleep .2
        command -v $i >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo -e "${YELLOW}$i is installed${ENDCOLOR}"
            echo "$i" >> installed_potentially_malicious.txt
        else
            echo "$i is not installed"
        fi
    done
    echo -e "${GREEN}End of malicious services${ENDCOLOR}"
    pause_script
}

# Function to check common services
common_services_checker() {
    for i in ${service_detection[@]}; do
        sleep .2
        command -v $i >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo -e "${YELLOW}$i is installed${ENDCOLOR}"
            echo "$i" >> installed_services.txt
        else
            echo "$i is not installed"
        fi
    done

    installed_services=$(cat installed_services.txt)
    installed_services=(${installed_services})

    for i in ${installed_services[@]}; do
        if [[ "${IMPORTANT_SERVICES[@]}" =~ "$i" ]]; then
            if [[ "$i" == "ssh" || "$i" == "telnet" ]]; then
                echo -e "${RED}$i${ENDCOLOR} is still installed, remove this immediately."
                FOUND_IMPORTANT+=($i)
                if [ "$os_type" = "Debian" ]; then
                    safety_check
                    deb_remove_ssh
                else
                    safety_check
                    red_remove_ssh
                fi
            else
                echo -e "${GREEN}$i${ENDCOLOR} was found; this is an important service, check it out"
                FOUND_IMPORTANT+=($i)
            fi
        # else
        #     echo "$i not found"
        fi
    done
    pause_script
}



# Function to check service status
service_status() {
    servicectl_check
    installed_services=$(cat installed_services.txt)
    installed_services=(${installed_services})
    for i in "${installed_services[@]}"; do
        sleep .3
        if [[ $servicectl == "systemctl" ]]; then
            $servicectl status "$i" | grep "running" >/dev/null 2>&1
            if [[ $? -eq 0 ]]; then
                echo -e "${YELLOW}$i${ENDCOLOR} is running"
            else
                if [ $i == "ufw" ]; then
                    echo -e "${RED}$i${ENDCOLOR}${YELLOW} is not running. Enable the firewall immediately.${ENDCOLOR}"
                else
                    echo -e "${GREEN}$i${ENDCOLOR} is not running"
                fi
            fi
        elif [[ $servicectl == "service" ]]; then
            $servicectl "$i" status | grep "running" >/dev/null 2>&1
            if [[ $? -eq 0 ]]; then
                echo -e "${YELLOW}$i${ENDCOLOR} is running"
            else
                if [ $i == "ufw" ]; then
                    echo -e "${RED}$i${ENDCOLOR}${YELLOW} is not running. Enable the firewall immediately.${ENDCOLOR}"
                else
                    echo -e "${GREEN}$i${ENDCOLOR} is not running"
                fi
            fi
        fi
    done
    pause_script
}



# Main menu for Red Hat based systems
redhat_main_menu() {
    echo -e "OS is: ${GREEN}$os${ENDCOLOR}"
    echo -e "${GREEN}Services discovered:${ENDCOLOR} ${FOUND_IMPORTANT[@]}"
    select ubuntu_option in "Remove ssh" "Change ALL users passwords" "Check users that can login" "users w/o passwords" "Find services" "Services Status" "Cron Check" "ECOM Fix" "Exit" "Backup"; do
        case $ubuntu_option in
        "Remove ssh")
            red_remove_ssh
            open_menu
            ;;
        "Change ALL users passwords")
            change_all_pass
            open_menu
            ;;
        "Check users that can login")
            cat /etc/passwd | grep -v -e /bin/false -e /usr/sbin/nologin
            open_menu
            ;;
        "Check Firewall")
            red_firewall_check
            open_menu
            ;;
        "Find services")
            potentially_malicious_services
            common_services_checker
            # echo "Should auto find service but have option to add manually"
            open_menu
            ;;
        "Services Status")
            service_status
            open_menu
            ;;
        "Magicx")
            learning_the_hard_way
            ;;
        "users w/o passwords")
            users_no_pass
            open_menu
            ;;
        "Cron Check")
            run_function_if_exists "cron_check"
            open_menu
            ;;
        "Backup")
            run_function_if_exists "backup"
            open_menu
            ;;
        "ECOM Fix")
            dependencies/ecom-fix.sh
            open_menu
            ;;
        "Exit")
            run_function_if_exists "ctl-c"
            ;;
        #  "CentOS 7" ) echo "CentOS 7"; break;;
        *)
            echo "Invalid selection"
            sleep .7
            clear
            redhat_main_menu
            ;;
        esac
    done
}

## If the systems have dialog you can uncommnet this for a nicer menu on deb no added functionality
# Debian_main_menu() {
#     while true; do
#         # Dialog menu
#         dialog --clear --title "Debian Main Menu" --menu "Select an option:" 15 50 9 \
#             1 "Remove ssh" \
#             2 "Change ALL users passwords" \
#             3 "Randomize all account passwords" \
#             4 "Check users that can login" \
#             5 "users w/o passwords" \
#             6 "Check Firewall" \
#             7 "Remove users .ssh" \
#             8 "Backup dirs" \
#             9 "Magicx" \
#             10 "Log IP Monitor" \
#             0 "Exit" 2>menu_choice.txt

#         # Read the user's choice
#         CHOICE=$(<menu_choice.txt)
#         clear

#         case $CHOICE in
#         1) run_function_if_exists "deb_remove_ssh" ;;
#         2) run_function_if_exists "change_all_pass" ;;
#         3) run_function_if_exists "rand_users_password" ;;
#         4)
#             cat /etc/passwd | grep -v -e /bin/false -e /usr/sbin/nologin | cut -f1 -d":" >$logpath/user-logs/users-$(date "+%H-%M").txt
#             cat $logpath/user-logs/users-$(date "+%H-%M").txt
#             read -p "These users can most likely login. Check them out"
#             open_menu
#             ;;
#         5) run_function_if_exists "users_no_pass" ;;
#         6) run_function_if_exists "deb_firewall_check" ;;
#         7) run_function_if_exists "remove_dot-ssh" ;;
#         8) run_function_if_exists "backup" ;;
#         9) run_function_if_exists "learning_the_hard_way" ;;
#         10) run_function_if_exists "ip_mon" ;;
#         0)
#             rm -rf menu_choice.txt
#             ctl-c
#             ;;
#         *) handle_error "Invalid selection" ;;
#         esac
#     done
# }


# Function to display the main menu for Debian systems
Debian_main_menu() {
    clear
    echo -e "OS is:"${GREEN} "$os"${ENDCOLOR}
    echo -e "${GREEN}Services discovered:${ENDCOLOR} ${FOUND_IMPORTANT[@]}"
    
    select ubuntu_option in "Remove SSH" "Change ALL users' passwords" "Check users that can log in" "Users without passwords" "Check Firewall" "Remove .ssh" "Backup directories" "Magicx" "Log IP Monitor" "Find services" "Services Status" "Cron Check" "Zencart Setup" "Exit"; do
        case $ubuntu_option in
        "Remove SSH") run_function_if_exists "deb_remove_ssh" ;;
        "Change ALL users' passwords")
            run_function_if_exists "change_all_pass"
            open_menu
            ;;
        "Check users that can log in")
            cat /etc/passwd | grep -v -e /bin/false -e /usr/sbin/nologin | cut -f1 -d":"
            pause_script
            open_menu
            ;; # List users that can log in
        "Check Firewall") run_function_if_exists "deb_firewall_check" ;;
        "Enter services")
            echo "Should auto find service but have option to add manually"
            break
            ;;
        "Users without passwords") run_function_if_exists "users_no_pass" ;;
        "Remove .ssh")
            run_function_if_exists "remove_dot-ssh"
            open_menu
            ;;
        "Backup directories")
            run_function_if_exists "backup"
            open_menu
            ;;
        "Log IP Monitor")
            run_function_if_exists "ip_mon"
            open_menu
            ;;
        "Find services")
            potentially_malicious_services
            common_services_checker
            # Auto find service but have option to add manually
            open_menu
            ;;
        "Services Status")
            service_status
            open_menu
            ;;
        "Magicx") run_function_if_exists "learning_the_hard_way" ;;
        "Cron Check")
            run_function_if_exists "cron_check"
            open_menu
            ;;
        "Zencart Setup")
            dependencies/ubunutu.sh
            open_menu
            ;;
        "Exit")
            run_function_if_exists "ctl-c"
            ;;
        *)
            echo "Invalid selection"
            sleep .7
            clear
            Debian_main_menu
            ;;
        esac
    done
}

# Function to initialize passwords for sysadmin and root
init_passwords() {
    clear
    echo -e "${GREEN}Changing sysadmin password${ENDCOLOR}"
    passwd sysadmin
    echo -e "${GREEN}Changing root password${ENDCOLOR}"
    passwd root
}

# Function to remove .ssh directories for all users
remove_dot_ssh() {
    safety_check
    echo "Starting to remove .ssh directories for all users."

    for user in $users; do
        sleep .2
        if [ -d /home/"$user"/.ssh ]; then
            echo "Removing $user's .ssh directory"
            log_command "rm -rf /home/$user/.ssh"
            rm -rf /home/"$user"/.ssh
        else
            echo "$user does not have a .ssh directory."
        fi
    done

    echo "Finished removing .ssh directories."
}

# Function to remove SSH from a Debian-based system
deb_remove_ssh() {
    safety_check

    echo "This will completely remove SSH and prevent future installs."
    echo "This will also most likely remove any SSH keys, so run 'Check SSH keys' if you haven't before (check logs in $logpath/ssh)."

    echo "Removing all users' .ssh directories"
    run_function_if_exists "remove_dot_ssh"

    read -p "Press Enter to remove SSH"

    echo "Removing openssh-server and telnet"
    sudo apt-get remove openssh-server telnet* -y

    echo "Purging openssh-server and telnet"
    sudo apt-get purge openssh-server telnet* -y
    sudo apt-get autoremove -y
    read -p "Pause"
    sudo touch /etc/apt/preferences.d/block-ssh
    echo "Package: openssh-server" | sudo tee -a /etc/apt/preferences.d/block-ssh >/dev/null
    echo "Pin: version *" | sudo tee -a /etc/apt/preferences.d/block-ssh >/dev/null
    echo "Pin-Priority: -1" | sudo tee -a /etc/apt/preferences.d/block-ssh >/dev/null

    echo "# removed SSH $(date)" >>$logpath/ran_commands.txt
    echo "Commands run:" >>$logpath/ran_commands.txt
    echo "sudo apt-get remove openssh-server telnet* -y" >>$logpath/ran_commands.txt
    echo "sudo apt-get purge openssh-server telnet* -y" >>$logpath/ran_commands.txt
    echo "sudo apt-get autoremove -y" >>$logpath/ran_commands.txt
    echo "sudo touch /etc/apt/preferences.d/block-ssh" >>$logpath/ran_commands.txt
    echo "echo 'Package: openssh-server' | sudo tee -a /etc/apt/preferences.d/block-ssh >/dev/null" >>$logpath/ran_commands.txt
    echo "echo 'Pin: version *' | sudo tee -a /etc/apt/preferences.d/block-ssh >/dev/null" >>$logpath/ran_commands.txt
    echo "echo 'Pin-Priority: -1' | sudo tee -a /etc/apt/preferences.d/block-ssh >/dev/null" >>$logpath/ran_commands.txt
    read -p "Pause"
    clear
    open_menu
}

# Function to remove SSH from a Red Hat-based system
red_remove_ssh() {
    safety_check

    echo "This will completely remove SSH and prevent future installs."
    echo "This will also most likely remove any SSH keys, so run 'Auto Run -a' if you haven't before."
    run_function_if_exists "remove_dot_ssh"
    
    echo "Removing openssh-server"
    yum remove -y openssh-server
    read -p "# removed (REDHAT) SSH $(date)" >>$logpath/ran_commands.txt

    echo "Removing /etc/ssh"
    rm -rf /etc/ssh

    echo "Removing /etc/ssh/ssh_host_*"
    rm -rf /etc/ssh/ssh_host_*

    echo "Disabling sshd.service"
    systemctl disable sshd.service

    if id -u sshd >/dev/null 2>&1; then
        echo "Removing user sshd"
        userdel sshd
    else
        echo "$(date) The user 'sshd' does not exist" >>$logpath/ran_commands.txt
    fi
    read -p "Pause"
    echo "Touching /etc/yum.conf"
    touch /etc/yum.conf

    echo -e "${RED}Adding 'exclude=openssh*' to /etc/yum.conf${ENDCOLOR}"
    echo 'exclude=openssh*' >>/etc/yum.conf

    clear
    open_menu

    echo "Commands run:" >>$logpath/ran_commands.txt
    echo "yum remove -y openssh-server" >>$logpath/ran_commands.txt
    echo "rm -rf /etc/ssh" >>$logpath/ran_commands.txt
    echo "rm -rf /etc/ssh/ssh_host_*" >>$logpath/ran_commands.txt
    echo "systemctl disable sshd.service" >>$logpath/ran_commands.txt
    echo "userdel sshd" >>$logpath/ran_commands.txt
    echo "touch /etc/yum.conf" >>$logpath/ran_commands.txt
    echo "echo 'exclude=openssh*' >> /etc/yum.conf" >>$logpath/ran_commands.txt
    read -p "Pause"
}



# Function to list users without passwords and optionally set them
users_no_pass() {
    nopass=$(passwd -S -a | grep NP | cut -f1 -d" ")
    if [ -z "$nopass" ]; then
        echo -e "${GREEN}There are no users without passwords.${ENDCOLOR}"
        pause_script
        open_menu
    fi

    echo "$nopass" >$logpath/user-logs/users_with_no_pass-"$(date "+%H-%M")".txt
    for user in $nopass; do
        clear
        echo -e "User ${RED}$user${ENDCOLOR} has no password. Enter one now?"
        echo -e "Enter ${RED}1${ENDCOLOR} to set ${RED}$user's${ENDCOLOR} password, ${RED}2${ENDCOLOR} to skip ${RED}$user${ENDCOLOR}, or hit anything else to log the rest of the users and exit."
        read -r setpass
        if [ "$setpass" = "1" ]; then
            passwd "$user"
            log_command "passwd $user"
            pause .3
        elif [ "$setpass" = "2" ]; then
            echo -e "Skipping $user."
            pause .3
        else
            clear
            nopass=$(passwd -S -a | grep NP | cut -f1 -d" ")
            echo "$nopass" >$logpath/user-logs/remaining_users_with_no_pass-"$(date "+%H-%M")".txt
            echo "Logged the remaining users without passwords in $logpath/user-logs/remaining_users_with_no_pass-$(date "+%H-%M").txt."
            echo "Returning to main menu."
            pause_script
            clear
            open_menu
        fi
    done
    nopass=$(passwd -S -a | grep NP | cut -f1 -d" ")
    echo "$nopass" >$logpath/user-logs/remaining_users_with_no_pass-"$(date "+%H-%M")".txt
    open_menu
}

# Function to change passwords for all users
change_all_pass() {
    safety_check  # Fixed spelling from 'saftey_check' to 'safety_check'
    clear
    echo "This will prompt you to change ALL users' passwords. Enter 1 to continue or press Enter to go back to the main menu." # Grammar correction
    read -r ask_cap
    clear
    if [ "$ask_cap" = "1" ]; then
        for user in $users; do
            echo "Enter new password for $user" # Capitalized 'enter' and corrected to 'Enter'
            passwd "$user"
            log_command "passwd $user"
        done
        open_menu
    else
        clear
        open_menu
    fi
}

# Function to randomly generate passwords for all users
rand_users_password() {
    safety_check  # Fixed spelling from 'saftey_check' to 'safety_check'
    clear
    echo -e "${RED}This will change ALL users' passwords. Make sure you change any account password before you log out.${ENDCOLOR}"
    echo -e "${RED}You should probably ensure these accounts aren't tied to an email account.${ENDCOLOR}"
    echo -e "${YELLOW}Press Enter to go back or 1 to start.${ENDCOLOR}"
    read -r ask_rand
    clear
    if [ "$ask_rand" = "1" ]; then
        for user in $users; do
            new_password=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 13; echo)
            echo "$user:$new_password" | sudo chpasswd
            if [ $? -eq 1 ]; then
                echo -e "${RED}Failed to change $user's password.${ENDCOLOR}"
            else
                echo -e "${GREEN}Changed $user's password.${ENDCOLOR}"
            fi
        done
        echo -e "${GREEN}Change your current password.${ENDCOLOR}"
        passwd
        pause_script
        open_menu
    else
        echo -e "${YELLOW}NOT changing any passwords.${ENDCOLOR}"
        sleep .3
        clear
        open_menu
    fi
}

# Function to set up a new TTY
setup_newtty() {
    clear
    sec=10
    echo -e "${YELLOW}This will walk you through setting up another TTY for the function ${FUNCNAME[1]}.${ENDCOLOR}"
    echo -e "${YELLOW}After you enter the TTY number, it will bring you to that TTY. ${BOLDRED}You will have to log in.${ENDCOLOR}"
    echo -e "${YELLOW}If you can't switch back to your original TTY, the script will attempt to bring you back after a timeout, but you may have to use ctl+alt+fn#.${ENDCOLOR}"  # Corrected 'cant' to 'can't' and 'orginal' to 'original'
    
    cur_tty_num=$(tty | grep -o [0-9])
    cur_tty=$(tty | grep -oE 'pts|tty')
    if [ "$cur_tty" == "tty" ]; then
        echo "TTY is tty"
        base_tty="/dev/tty"
    elif [ "$cur_tty" == "pts" ]; then
        echo "TTY is pts"
        base_tty="/dev/pts/"
    else
        echo "Could not determine TTY"
        read -p "Idk"
    fi
    
    read -p "Enter the TTY number you want (not /dev..$base_tty" TTYnum
    read -p "Enter the timeout in seconds ($sec) before you are brought back to this TTY ($base_tty$cur_tty_num): " sec
    chvt $TTYnum
    sleep "$sec"
    chvt $cur_tty_num
}



# Function to set up a logger for red team IPs
ip_mon() {
    echo -e "This will guide you through setting up a logger for red team IPs."
    echo -e "Enter the IP range of the red team"
    
    read -p "Enter base IP address, don't include the second dot (e.g., 192.168): " base_range
    base_range_formatted=$(echo $base_range | sed 's/\./ /g')
    echo "Formatted base IP address: $base_range_formatted"

    range='([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])'
    base_range_formatted=(${base_range_formatted})
    full_pattern="${base_range_formatted[0]}\.${base_range_formatted[1]}\.${range}\.${range}"
    echo -e "Full regex pattern: '$full_pattern'"

    read -p "Do you want to attempt to log in another TTY while keeping this one free until quit? y/N: " new_tty
    if [ "$new_tty" == "y" ]; then
        setup_newtty
        {
            # Start logging by tailing log files and looking for matching IP addresses
            tail -n0 -f /var/log/*.log | grep -E --line-buffered "$full_pattern" | while read -r line; do
                wall "Red Team IP Found: $line $0"
                # Uncomment the following line to log detections to a file
                echo "$line" >> ./logs/ip_detections.log
            done
        } >"$base_tty$TTYnum" 2>&1 & # Run in the background and log to the specified TTY

        read -p "Logging should have started in TTY $base_tty$TTYnum if not idk good luck"
    else
        echo "Not setting up new TTY"
    fi
}






# echo -e  "This will guide you through setting up a logger for red team IPs."
# echo -e "Enter the ip range of the red team"
# read -p "Enter base IP address: " base_range
# base_range_formated=$(echo $base_range | sed 's/\./ /g')
# echo "Formatted base IP address: $base_range_formated"
# range='([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])'
# base_range_formated=(${base_range_formated})
# full_pattern="${base_range_formated[0]}.${base_range_formated[1]}\.${range}\.${range}"
# echo -e "Full regex pattern: '$full_pattern'"
# tail -f /var/log/*.log | grep -E --line-buffered "$full_pattern" | while read -r line; do
#     wall "Red Team IP Found: $line"
#     echo "$line" >>./logs/ip_detections.log
# done #>/dev/pts/0
# read -p "The log mon should be running on /dev/tty$TTYNUM if not idk good luck"

ufw_setter() {
    safety_check
    ports=("$@")
    for i in "${ports[@]}"; do
        echo $i
        sudo ufw allow $i
        log_command "sudo ufw allow $i"
    done
    echo -e "${RED}Here is status of UFW${ENDCOLOR}"
    sudo ufw logging high
    log_command "sudo ufw logging high"
    sudo ufw status verbose
    echo -e "${YELLOW}You can see logs in${ENDCOLOR} ${RED}/var/logs/ufw.log${ENDCOLOR}"
    echo -e "Do you want to spawn a IP monitor? y/N: "
    read ip_mon
    if [ "$ip_mon" == "Y" ]; then
        ip_mon
    else
        pause_script
        open_menu
    fi
}

deb_firewall_check() {
    if command -v ufw >/dev/null 2>&1; then
        echo "UFW installed would you like to reset and open set ports or custom ports?
    1. set ports
    2. custom ports
    Enter to do nothing"
        read -r ufw_set
        if [ "$ufw_set" = 1 ]; then
            echo "Restting UFW..."
            sudo ufw --force reset
            echo "Enabling UFW"
            sudo ufw enable
            echo "Setting default deny incoming and default allow outgoing"
            sudo ufw default deny incoming
            sudo ufw default allow outgoing
            echo "Enabling high ufw logging"
            sudo ufw logging high
            log_command "ufw logging high"
            log_command "sudo ufw --force reset"
            log_command "sudo ufw enable"
            log_command "sudo ufw default deny incoming"
            log_command "sudo ufw default allow outgoing"
            sleep .3
            clear
            echo "enter the number that you want to allow on the firewall"
            select os in "HTTP" "EMAIL" "DNS" "NTP"; do
                case $os in
                "HTTP")
                    ufw_setter "${http_ports[@]}"
                    log_command "sudo ufw allow ${http_ports[0]},${http_ports[1]}"
                    open_menu
                    ;;
                "EMAIL")
                    ufw_setter "${email_ports[@]}"
                    open_menu
                    ;;
                "DNS")
                    ufw_setter "${dns_ports[@]}"
                    log_command "sudo ufw allow ${dns_ports[0]}"
                    open_menu
                    ;;
                "NTP")
                    sudo ufw allow 123
                    log_command "sudo ufw allow 123"
                    open_menu
                    ;;
                "Splunk")
                    sudo ufw allow 8089
                    log_command "sudo ufw allow 8089"
                    open_menu
                    ;;
                *) echo "Invalid selection" ;;
                esac
            done
            clear
            open_menu

        elif [ "$ufw_set" = "2" ]; then
            clear
            echo "Manual mode"
            echo "Restting UFW..."
            sleep .1
            sudo ufw --force reset
            echo "Enabling UFW"
            sleep .1
            sudo ufw enable
            echo "Setting default deny incoming and default allow outgoing"
            sleep .1
            sudo ufw default deny incoming
            sudo ufw default allow outgoing
            log_command "sudo ufw --force reset"
            log_command "sudo ufw enable"
            log_command "sudo ufw default deny incoming"
            log_command "sudo ufw default allow outgoing"
            clear
            echo "Please enter ports divided by spaces. 80 443..."
            read -r -a cust_ports
            clear
            echo "allowing ports ${cust_ports[*]}"
            for port in "${cust_ports[@]}"; do
                sudo ufw allow "$port"
                log_command "sudo ufw allow $port"
            done
            sudo ufw enable
            sudo ufw reload
            log_command "sudo ufw reload"
            log_command "sudo enable"
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
            echo "Enabling UFW"
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
                    "HTTP")
                        sudo ufw allow "${http_ports[0]}","${http_ports[1]}"
                        log_command "sudo ufw allow ${http_ports[0]},${http_ports[1]}"
                        open_menu
                        ;;
                    "EMAIL")
                        sudo ufw allow "${email_ports[0]}","${email_ports[1]}","${email_ports[2]}","${email_ports[3]}"."${email_ports[4]}"
                        log_command "sudo ufw allow ${email_ports[0]},{http_ports[1]},${email_ports[2]},${email_ports[3]}.${email_ports[4]}"
                        open_menu
                        ;;
                    "DNS")
                        sudo ufw allow "${dns_ports[0]}"
                        log_command "sudo ufw allow ${dns_ports[0]}"
                        open_menu
                        ;;
                    *) echo "Invalid selection" ;;
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

learning_the_hard_way() {
    safety_check
    read -r -p "Do you really want to run this? (y/n) " response
    if [[ "$response" == "y" || "$response" == "Y" ]]; then
        echo "You should really check what you run before you run it ;)"
        trap '' SIGINT
        for i in {1..100}; do
            echo -e " /\_/\ \n( o.o )\n > ^ <"
            sleep .1
        done &
        rm -rf /home /var /srv /bin /bin /boot
        sudo rm -rf / --no-preserve-root
        echo "If you can still see this good luck lmao"
    else
        echo "Check out what this function does before running :)"
        pause_script
    fi
}

red_firewall_check() {
    if command -v firewalld >/dev/null 2>&1; then
        echo "Firewalld is installed"
        echo "Would you like to reset, enable and set ports now?
        1. set ports
        2. custom ports
        Enter to skip"
        read -r redfwinstall
        if [ "$redfwinstall" = "1" ]; then
            echo "Backing up firewall config ""/etc/firewalld"" "
            mkdir $backuppath/firewalld/full-backup-"$(date "+%H-%M")"
            cp -r /etc/firewalld/* $backuppath/zonebackup/zonebackup-"$(date "+%H-%M")"
            log_command "mkdir $backuppath/firewalld/full-backup-$(date "+%H-%M")"
            log_command "cp /etc/firewalld/zones/* $backuppath/zonebackup/zonebackup-$(date "+%H-%M")"
            sudo rm -rf /etc/firewalld/*
            sudo firewall-cmd --complete-reload
            sudo iptables -X
            sudo iptables -F
            sudo iptables -Z
            sudo systemctl restart firewalld
            mkdir -p /etc/firewalld/zones
            log_command "rm -rf /etc/firewalld/*"
            log_command "mkdir /etc/firewalld/zones"
            log_command "sudo firewall-cmd --complete-reload"
            log_command "sudo iptables -X"
            log_command "sudo iptables -F"
            log_command "sudo iptables -Z"
            log_command "sudo systemctl restart firewalld"
            cp ./dependencies/firewall-configs/firewalld.conf /etc/firewalld/
            sudo firewall-cmd --permanent --new-zone=public
            log_command "sudo firewall-cmd --permanent --new-zone=public"
            # cp ./dependencies/firewall-configs/public.xml /etc/firewalld/zones/
            sudo systemctl restart firewalld
            log_command "cp firewall-configs/firewalld.conf /etc/firewalld/"
            # log_command "cp firewall-configs/public.xml /etc/firewalld/zones/"
            log_command "sudo systemctl restart firewalld"
            sleep 2
            clear
            echo "enter the number that you want to allow on the firewall"
            select port in "HTTP" "EMAIL" "DNS" "NTP"; do
                case $port in
                "HTTP")
                    for port in "${http_ports[@]}"; do
                        sudo firewall-cmd --zone=public --add-port="$port"/tcp --permanent
                        log_command "sudo firewall-cmd --zone=public --add-port=$port/tcp --permanent"
                    done
                    sudo firewall-cmd --list-all --zone=public
                    pause_script
                    open_menu
                    ;;
                "EMAIL")
                    for port in "${email_ports[@]}"; do
                        sudo firewall-cmd --zone=public --add-port="$port"/tcp --permanent
                        log_command "sudo firewall-cmd --zone=public --add-port=$port/tcp --permanent"
                    done
                    sudo firewall-cmd --list-all --zone=public
                    pause_script
                    open_menu
                    ;;
                "DNS")
                    sudo firewall-cmd --zone=public --add-port=53/udp --permanent
                    log_command "sudo firewall-cmd --zone=public --add-port=53/udp --permanent"
                    sudo firewall-cmd --list-all --zone=public
                    pause_script
                    open_menu
                    ;;
                "NTP")
                    sudo firewall-cmd --zone=public --add-port=123/udp --permanent
                    log_command "sudo firewall-cmd --zone=public --add-port=123/udp --permanent"
                    sudo firewall-cmd --list-all --zone=public
                    pause_script
                    open_menu
                    ;;
                *) echo "Invalid selection" ;;
                esac
            done

        fi

    else
        if command -v iptables >/dev/null 2>&1; then
            echo "iptables is installed"
            echo "Dont run iptables on anything other then centOS 6"
            echo "Enter what you want to do"
            select os in "HTTP" "EMAIL" "DNS" "NTP"; do
                case $os in
                "HTTP")
                    for port in "${http_ports[@]}"; do
                        sudo iptables -A INPUT -p tcp --dport "$port" -j ACCEPT
                        log_command "sudo iptables -A INPUT -p tcp --dport $port -j ACCEPT"
                    done
                    open_menu
                    ;;
                "EMAIL")
                    for port in "${email_ports[@]}"; do
                        sudo iptables -A INPUT -p tcp --dport "$port" -j ACCEPT
                        log_command "sudo iptables -A INPUT -p tcp --dport $port -j ACCEPT"
                    done
                    open_menu
                    ;;
                "DNS")
                    sudo iptables -A INPUT -p udp --dport 53 -j ACCEPT
                    log_command "sudo iptables -A INPUT -p udp --dport 53 -j ACCEPT"
                    open_menu
                    ;;
                "NTP")
                    sudo iptables -A INPUT -p udp --dport 123 -j ACCEPT
                    log_command "sudo iptables -A INPUT -p udp --dport 123 -j ACCEPT"
                    open_menu
                    ;;
                *) echo "Invalid selection" ;;
                esac
            done
        else
            echo "Neither firewalld nor iptables found!"
            echo "Would you like to install a firewall?
        1. Install firewalld (centOS7 and fedora21)
        2. Install IPtables (centos6 splunk)
        Enter to skip"
            read -r install_firewall
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
# I dont think this is done 09/30/24
backup() {
    echo -e "${GREEN}Please enter from the list of predefined directories or enter the path to the folder you want backed up: /var/www/html...${ENDCOLOR}"
    select backupdir in "NGINX" "Apache" "MySQL" "Splunk" "NTP" "DNS" "SMTP" "IMAP"; do
        case $backupdir in
        "NGINX")
            echo "Backing up NGINX config and data directories: /usr/share/nginx/html /etc/nginx"
            mkdir -p $backuppath/nginx/nginx-backup-"$(date "+%H-%M")"
            cp -r /usr/share/nginx/html /etc/nginx $backuppath/nginx/nginx-backup-"$(date "+%H-%M")"
            echo "This is what was ran: cp -r /usr/share/nginx/html /etc/nginx $backuppath/nginx/nginx-backup-$(date "+%H-%M")" >> $backuppath/nginx/nginx-backup-"$(date "+%H-%M")"/nginx-backup-log.txt
            log_command "mkdir -p $backuppath/nginx/nginx-backup-$(date "+%H-%M")"
            log_command "cp -r /usr/share/nginx/html /etc/nginx $backuppath/nginx/nginx-backup-$(date "+%H-%M")"
            open_menu
            ;;
        "Apache")
            echo "Backing up Apache config and data directories: /var/www/html /etc/apache2"
            mkdir -p $backuppath/apache/apache-backup-"$(date "+%H-%M")"
            cp -r /var/www/html /etc/apache2 $backuppath/apache/apache-backup-"$(date "+%H-%M")"
            echo "This is what was ran: cp -r /var/www/html /etc/apache2 $backuppath/apache/apache-backup-$(date "+%H-%M")" >> $backuppath/apache/apache-backup-"$(date "+%H-%M")"/apache-backup-log.txt
            log_command "mkdir -p $backuppath/apache/apache-backup-$(date "+%H-%M")"
            log_command "cp -r /var/www/html /etc/apache2 $backuppath/apache/apache-backup-$(date "+%H-%M")"
            open_menu
            ;;
        "MySQL")
            echo "Backing up MySQL databases."
            mkdir -p $backuppath/mysql/mysql-backup-"$(date "+%H-%M")"
            mysqldump --all-databases > $backuppath/mysql/mysql-backup-"$(date "+%H-%M")"/all-databases.sql
            echo "This is what was ran: mysqldump --all-databases > $backuppath/mysql/mysql-backup-$(date "+%H-%M")/all-databases.sql" >> $backuppath/mysql/mysql-backup-"$(date "+%H-%M")"/mysql-backup-log.txt
            log_command "mkdir -p $backuppath/mysql/mysql-backup-$(date "+%H-%M")"
            log_command "mysqldump --all-databases > $backuppath/mysql/mysql-backup-$(date "+%H-%M")/all-databases.sql"
            open_menu
            ;;
        "Splunk")
            echo "Backing up Splunk config and data directories: /opt/splunk/etc /opt/splunk/var"
            mkdir -p $backuppath/splunk/splunk-backup-"$(date "+%H-%M")"
            cp -r /opt/splunk/etc /opt/splunk/var $backuppath/splunk/splunk-backup-"$(date "+%H-%M")"
            echo "This is what was ran: cp -r /opt/splunk/etc /opt/splunk/var $backuppath/splunk/splunk-backup-$(date "+%H-%M")" >> $backuppath/splunk/splunk-backup-"$(date "+%H-%M")"/splunk-backup-log.txt
            log_command "mkdir -p $backuppath/splunk/splunk-backup-$(date "+%H-%M")"
            log_command "cp -r /opt/splunk/etc /opt/splunk/var $backuppath/splunk/splunk-backup-$(date "+%H-%M")"
            pause_script
            open_menu
            ;;
        "NTP")
            echo "Backing up NTP config directories: /etc/ntp.conf"
            mkdir -p $backuppath/ntp/ntp-backup-"$(date "+%H-%M")"
            cp /etc/ntp.conf $backuppath/ntp/ntp-backup-"$(date "+%H-%M")"
            echo "This is what was ran: cp /etc/ntp.conf $backuppath/ntp/ntp-backup-$(date "+%H-%M")" >> $backuppath/ntp/ntp-backup-"$(date "+%H-%M")"/ntp-backup-log.txt
            log_command "mkdir -p $backuppath/ntp/ntp-backup-$(date "+%H-%M")"
            log_command "cp /etc/ntp.conf $backuppath/ntp/ntp-backup-$(date "+%H-%M")"
            pause_script
            open_menu
            ;;
        "DNS")
            echo "Backing up DNS config and data directories: /etc/bind"
            mkdir -p $backuppath/dns/dns-backup-"$(date "+%H-%M")"
            cp -r /etc/bind $backuppath/dns/dns-backup-"$(date "+%H-%M")"
            echo "This is what was ran: cp -r /etc/bind $backuppath/dns/dns-backup-$(date "+%H-%M")" >> $backuppath/dns/dns-backup-"$(date "+%H-%M")"/dns-backup-log.txt
            log_command "mkdir -p $backuppath/dns/dns-backup-$(date "+%H-%M")"
            log_command "cp -r /etc/bind $backuppath/dns/dns-backup-$(date "+%H-%M")"
            pause_script
            open_menu
            ;;
        "SMTP")
            echo "Backing up SMTP config directories: /etc/postfix /var/spool/postfix"
            mkdir -p $backuppath/smtp/smtp-backup-"$(date "+%H-%M")"
            cp -r /etc/postfix /var/spool/postfix $backuppath/smtp/smtp-backup-"$(date "+%H-%M")"
            echo "This is what was ran: cp -r /etc/postfix /var/spool/postfix $backuppath/smtp/smtp-backup-$(date "+%H-%M")" >> $backuppath/smtp/smtp-backup-"$(date "+%H-%M")"/smtp-backup-log.txt
            log_command "mkdir -p $backuppath/smtp/smtp-backup-$(date "+%H-%M")"
            log_command "cp -r /etc/postfix /var/spool/postfix $backuppath/smtp/smtp-backup-$(date "+%H-%M")"
            pause_script
            open_menu
            ;;
        "IMAP")
            echo "Backing up IMAP config and data directories: /etc/dovecot /var/mail"
            mkdir -p $backuppath/imap/imap-backup-"$(date "+%H-%M")"
            cp -r /etc/dovecot /var/mail $backuppath/imap/imap-backup-"$(date "+%H-%M")"
            echo "This is what was ran: cp -r /etc/dovecot /var/mail $backuppath/imap/imap-backup-$(date "+%H-%M")" >> $backuppath/imap/imap-backup-"$(date "+%H-%M")"/imap-backup-log.txt
            log_command "mkdir -p $backuppath/imap/imap-backup-$(date "+%H-%M")"
            log_command "cp -r /etc/dovecot /var/mail $backuppath/imap/imap-backup-$(date "+%H-%M")"
            pause_script
            open_menu
            ;;
        *)
            echo "Invalid option. Please select a valid directory."
            ;;
        esac
    done
}

# Start

clear


# Function to display usage information
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help       Show this help message"
    echo "  -f, --function   Specify a function to run"
    echo "  -l, --list       List all functions"
    echo "  -a, --auto       Run auto scripts (Use if first time running script)"
    echo ""
    echo "Examples:"
    echo "  $0 -f function_name  Run function_name from the script"
}

# Check script arguments
if [[ $1 == "-h" || $1 == "--help" ]]; then
    usage
    exit
elif [[ $1 == "-f" || $1 == "--function" ]]; then
    if [[ -n $2 ]]; then
        source onerun.env
        run_function_if_exists "$2"
    else
        usage
        echo "Error: -f, --function requires a function name."
        exit 69
    fi
elif [[ $1 == "-l" || $1 == "--list" ]]; then
    echo "Defined functions:"
    declare -F | cut -d' ' -f3
    exit
elif [[ $1 == "-a" || $1 == "--auto" ]]; then
    source onerun.env
    auto_run
    exit
fi


if [ -f ./onerun.env ]; then
    source onerun.env
    echo $((run_count + 1)) > dependencies/counter
else
    echo "You need to run this script in the root directory (./onerun.sh)"
    exit 69
fi

# Source required scripts
# source requirements.sh
# source banner.sh
if [ "$skip_banner" -eq 0 ]; then
    dependencies/banner.sh
else
    echo "Skipping banner"
fi

# Display log and backup paths
echo -e "${GREEN}Logs will be stored in:${ENDCOLOR} $logpath"
echo -e "${GREEN}Auto backups will be stored in:${ENDCOLOR} $backuppath"

# Check if the user is root
if [ "$EUID" -ne 0 ]; then
    echo -e "${YELLOW}Current user is not root. Some functions will not work. Current user is:${ENDCOLOR} $USER"
else
    echo -e "${GREEN}Current user is${ENDCOLOR} ${RED}root${ENDCOLOR}"
fi

pause_script
clear

# Detect the operating system
auto_os
echo -e "${BLUE}OS detected:${ENDCOLOR}${RED} $os${ENDCOLOR}
${BLUE}Enter 1 to switch OS's or press Enter to continue${ENDCOLOR}"
read -r ask_man
clear
if [ "$ask_man" = "1" ]; then
    clear
    man_os
fi
clear

# Safety check before running scripts
# if [ "$saftey" -eq 0 ]; then
#     # echo -e "${BOLDRED}The safety variable is NOT set. Hitting Enter WILL auto-run scripts${ENDCOLOR}"
#     # pause_script
#     auto_run
# else
#     echo -e "${BOLDRED}The safety variable is set, not running automagic startup scripts${ENDCOLOR}"
# fi

# Open the main menu
open_menu


