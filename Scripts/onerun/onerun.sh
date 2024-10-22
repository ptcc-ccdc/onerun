#!/bin/bash
clear
source onerun.env
# source requirements.sh
# source banner.sh
if [ $skip_banner -eq 0 ]; then
    ./banner.sh
else
    echo "Skipping banner"
fi

trap ctl-c SIGINT

ctl-c() {
    clear
    echo -e "${ENDCOLOR}" "Good luck, hopfully something worked"
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

#why not
pause_script() {
    read -r -p "Press Enter to continue..."
    clear
}
echo -e "${GREEN}Logs will be stored in:${ENDCOLOR} $logpath"
echo -e "${GREEN}Auto backups will be stored in:${ENDCOLOR} $backuppath"

# User check
if [ "$EUID" -ne 0 ]; then
    echo -e "${YELLOW}Current user is not root some fuctions will not work. Current user is: ${ENDCOLOR}"$USER
else
    echo -e "${GREEN}Current user is${ENDCOLOR} ${RED}root${ENDCOLOR}"
fi
pause_script
clear

# command logger
log_command() {
    echo -e "At $(date) the user $USER ran: $1" >>"$logpath/ran_commands.txt"

}

mkdir -p $backuppath/backups $logpath/user-logs $logpath/ssh
log_command "mkdir -p $onerun_root/backups $onerun_root/logs/user-logs"

# Function checker
run_function_if_exists() {
    if declare -F "$1" >/dev/null 2>&1; then
        $1
        open_menu
    else
        handle_error "Function '$1' does not exist!"
    fi
}
handle_error() {
    dialog --msgbox "$1" 10 40
}

# if [ $date == "01/25/25" ]; then
#     echo "Good Luck"
#        sleep 2
# fi

saftey_check() {
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
            echo -e "This is a warning that the safty is ${BOLDRED}OFF${ENDCOLOR}" and this ${BOLDRED}WILL${ENDCOLOR}" be a destructive action"
            pause_script
        else
            clear
        fi
    fi
}

testingfunxc() {
    saftey_check
    echo "0:" ${FUNCNAME[0]} "1:" ${FUNCNAME[1]} "2" ${FUNCNAME[2]}
    read -p -e "This is should match what you wanted to do"
}

if [ $saftey -eq 0 ]; then
    echo -e "${BOLDRED}The safty variable is NOT set, hitting enter WILL auto run scripts${ENDCOLOR}"
    pause_script
    auto_run
else
    echo -e "${BOLDRED}The safty variable is set, not running automagic scripts${ENDCOLOR}"
fi

auto_run() {
    saftey_check
    echo -e "${GREEN}Looking for ssh authorized_keys...${ENDCOLOR}"
    find / -type f -name "authorized_keys" 2>/dev/null >$logpath/ssh/found-ssh-keys-"$(date "+%H:%M")".txt
    keys_path=$(find / -type f -name "authorized_keys" 2>/dev/null)
    for path in $keys_path; do
        cp "$path" $logpath/ssh/unalterd_keys-"$(date "+%H:%M")".txt
        echo -e "${RED}Key found:${ENDCOLOR} ${RED}$path${ENDCOLOR}"
        echo "$path:" >>$logpath/ssh/alterd_keys-"$(date "+%H:%M")".txt
        sed -e 's/^.\{10\}//' $logpath/ssh/unalterd_keys-"$(date "+%H:%M")".txt >>$logpath/ssh/alterd_keys-"$(date "+%H:%M")".txt
        rm -rf $logpath/ssh/unalterd_keys-"$(date "+%H:%M")".txt
        rm -rf "$path"
        log_command "mv $path $logpath/ssh/unalterd_keys-$(date "+%H:%M").txt"
        log_command "echo $path: >> $logpath/ssh/alterd_keys-$(date "+%H:%M").txt"
        log_command "sed -e 's/^.\{10\}//' $logpath/ssh/unalterd_keys-$(date "+%H:%M").txt >> $logpath/ssh/alterd_keys-$(date "+%H:%M").txt"
        log_command "rm -rf $logpath/ssh/unalterd_keys-$(date "+%H:%M").txt"
        log_command "rm -rf $path"
    done
    echo -e "${GREEN}If any keys have been found they have been logged to${ENDCOLOR} $logpath/ssh/found_keys-DATE.txt and removed.
    alterd unusable copies have been made in $logpath/ssh/alterd_keys-$(date "+%H:%M").txt"
    pause_script
    rm -rf installed_potentially_malicious.txt installed_services.txt
    if [ -e "./installed_services.txt" ]; then
        rand_users_password
        clear
    fi
    servicectl_check
}

servicectl_check() {
    if command -v systemctl &>/dev/null; then
        # echo "System has systemctl"
        servicectl="systemctl"
    elif command -v service &>/dev/null; then
        # echo "System has service"
        servicectl="service"
    else
        echo "Service control method not found, defaulting to service"
        servicectl="service"
    fi

    if [ -d /etc/init.d ]; then
        echo -e "${YELLOW}Path /etc/init.d exists, take a look to see what there is${ENDCOLOR}"
    fi
}

potentially_malicious_services() {
    for i in ${potentially_malicious[@]}; do
        sleep .2
        command -v $i >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo "$i is installed"
            echo "$i" >>installed_potentially_malicious.txt
        else
            echo "$i is not installed"
        fi
    done
    echo -e "${GREEN}End of malicious services${ENDCOLOR}"
    pause_script
}

common_services_checker() {

    for i in ${service_detection[@]}; do
        sleep .2
        command -v $i >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo "$i is installed"
            echo "$i" >>installed_services.txt

        else
            echo "$i is not installed"
        fi
    done

    installed_services=$(cat installed_services.txt)
    installed_services=(${installed_services})

    for i in ${installed_services[@]}; do
        if [[ "${IMPORTANT_SERVICES[@]}" =~ "$i" ]]; then
            if [[ "$i" == "ssh" || "$i" == "telnet" ]]; then
                echo echo -e "${RED}$i${ENDCOLOR} is still installed remove this immediately."
                FOUND_IMPORTANT+=($i)

            echo -e "${GREEN}$i${ENDCOLOR} was found this is an important service check it out"
            FOUND_IMPORTANT+=($i)
        # else
        #     echo "$i not found"
        fi
    done
    pause_script
}

service_status() {
    installed_services=$(cat installed_services.txt)
    installed_services=(${installed_services})

    for i in ${installed_services[@]}; do

        if [ $servicectl == "systemctl" ]; then
            $servicectl status $i | grep running >/dev/null 2>&1
            if [ $? -eq 0 ]; then
                echo -e "${YELLO}$i${ENDCOLOR} is running"
            else
                echo -e "${GREEN}$i${ENDCOLOR} is not running"
            fi
        elif [ $servicectl == "service" ]; then
            $servicectl $i status | grep running >/dev/null 2>&1
            if [ $? -eq 0 ]; then
                echo -e "${YELLO}$i${ENDCOLOR} is running"
            else
                echo -e "${GREEN}$i${ENDCOLOR} is not running"
            fi
        fi
    done

}

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
        echo -e "${YELLOW}Failed to determain OS going stick boi${ENDCOLOR}"
        man_os
    fi

}

open_menu() {
    if [ "$os_type" = "redhat" ]; then
        clear
        redhat_main_menu
    elif [ "$os_type" = "Debian" ]; then
        clear
        Debian_main_menu

    else
        echo "Uh you shouldn't see this"
        man_os

    fi
}

redhat_main_menu() {
    echo "OS is" "$os"
    echo -e "${GREEN}Services discoverd:${ENDCOLOR} ${FOUND_IMPORTANT[@]}"
    select ubuntu_option in "Remove ssh" "Change ALL users passwords" "Check users that can login" "users w/o passwords" "Find services" "Services Status"; do
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
        "Check Firwall")
            red_firewall_check
            open_menu
            ;;
        "Find services")
            potentially_malicious_services
            common_services_checker
            # echo "Should auto find service but have option to add man"
            open_menu
            ;;
        "Services Status")
            service_status
            open_menu
            ;;             
        "Magicx") learning_the_hard_way ;;
        "users w/o passwords") users_no_pass ;;
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
#             cat /etc/passwd | grep -v -e /bin/false -e /usr/sbin/nologin | cut -f1 -d":" >$logpath/user-logs/users-$(date "+%H:%M").txt
#             cat $logpath/user-logs/users-$(date "+%H:%M").txt
#             read -p "These users can most likely login. Check them out"
#             open_menu
#             ;;
#         5) run_function_if_exists "users_no_pass" ;;
#         6) run_function_if_exists "deb_firewall_check" ;;
#         7) run_function_if_exists "remove_.ssh" ;;
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

Debian_main_menu() {
    clear
    echo "OS is" "$os"
    echo -e "${GREEN}Services discoverd:${ENDCOLOR} ${FOUND_IMPORTANT[@]}"
    select ubuntu_option in "Remove ssh" "Change ALL users passwords" "Check users that can login" "users w/o passwords" "Check Firewall" "Remove .ssh" "Backup dirs" "Magicx" "Log IP Monitor" "Find services" "Services Status"; do
        case $ubuntu_option in
        "Remove ssh") run_function_if_exists "deb_remove_ssh" ;;
        "Change ALL users passwords")
            run_function_if_exists "change_all_pass"
            open_menu
            ;;
        "Check users that can login")
            cat /etc/passwd | grep -v -e /bin/false -e /usr/sbin/nologin | cut -f1 -d":"
            pause_script
            open_menu
            ;; # cat /etc/passwd | grep -v -e /bin/false -e /usr/sbin/nologin | cut -f1 -d":" # awk -F: ' {print $1, $7}' /etc/passwd # notes.sh
        "Check Firewall") run_function_if_exists "deb_firewall_check" ;;
        "Enter services")
            echo "Should auto find service but have option to add man"
            break
            ;;
        "users w/o passwords") run_function_if_exists "users_no_pass" ;;
        "Remove .ssh")
            run_function_if_exists "remove_.ssh"
            open_menu
            ;;
        "Backup dirs")
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
            # echo "Should auto find service but have option to add man"
            open_menu
            ;;
        "Services Status")
            service_status
            open_menu
            ;;        
        "Magicx") run_function_if_exists "learning_the_hard_way" ;;

        "testing") run_function_if_exists "testingfunc" ;;

        *)
            echo "Invalid selection"
            sleep .7
            clear
            Debian_main_menu
            ;;
        esac
    done

}

remove_.ssh() {
    saftey_check
    # look at this i dont think im done test to make sure i think its done jan18 11pm
    for user in $users; do
        echo "Removing $user .ssh dir"
        log_command "rm -rf $user/.ssh)"
        rm -rf /home/"$user"/.ssh
    done
}

deb_remove_ssh() {
    saftey_check
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
    echo "Package: openssh-server" | sudo tee -a /etc/apt/preferences.d/block-ssh >/dev/null
    echo "Pin: version *" | sudo tee -a /etc/apt/preferences.d/block-ssh >/dev/null
    echo "Pin-Priority: -1" | sudo tee -a /etc/apt/preferences.d/block-ssh >/dev/null
    echo "# removed SSH $(date)" >>$logpath/ran_commands.txt
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
    saftey_check
    echo "this will completly remove ssh and prevent future installs"
    echo "This will also most likey remove any ssh keys so run "Check ssh keys" if you havent before"
    echo "Removing openssh-server"
    echo "# removed (REDHAT) SSH $(date)" >>$logpath/ran_commands.txt
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
    if id -u sshd >/dev/null 2>&1; then
        echo "Removing user sshd"
        log_command "userdel sshd"
        userdel sshd
    else
        echo "$(date) The user "sshd" dose not exsit" >>$logpath/ran_commands.txt
    fi
    echo "Touching /etc/yum.conf"
    log_command "touch /etc/yum.conf"
    touch /etc/yum.conf

    echo -e "${RED}Adding 'exclude=openssh*' to /etc/yum.conf${ENDCOLOR}"
    log_command "echo 'exclude=openssh*' >> /etc/yum.conf"
    echo 'exclude=openssh*' >>/etc/yum.conf
    clear
    open_menu
}

users_no_pass() {
    nopass=$(passwd -S -a | grep NP | cut -f1 -d" ")
    if [ -z $nopass ]; then
        echo -e "${GREEN}There are no users without passwords${ENDCOLOR}"
        pause_script
        open_menu
    fi

    echo "$nopass" >$logpath/user-logs/users_with_no_pass-"$(date "+%H:%M")".txt
    for user in $nopass; do
        clear
        echo -e "user ${RED}$user${ENDCOLOR} has no password enter one now?"
        echo -e "enter ${RED}1${ENDCOLOR} to set ${RED}$user's${ENDCOLOR} password, ${RED}2${ENDCOLOR} to skip ${RED}$user${ENDCOLOR} or ${RED}hit anything else${ENDCOLOR} to log the rest of the users and exit"
        read -r setpass
        if [ "$setpass" = "1" ]; then
            passwd "$user"
            log_command "passwd $user"
            pause .3

        elif [ "$setpass" = "2" ]; then
            echo -e "Skipping $user"
            pause .3
        else
            clear
            nopass=$(passwd -S -a | grep NP | cut -f1 -d" ")
            echo "$nopass" >$logpath/user-logs/remaining_users_with_no_pass-"$(date "+%H:%M")".txt
            echo "Ok loged the remaing users that had no password in $logpath/user-logs/remaining_users_with_no_pass-"$(date "+%H:%M")".txt"
            echo "going to main menu"
            pause_script
            clear
            open_menu
        fi
    done
    nopass=$(passwd -S -a | grep NP | cut -f1 -d" ")
    echo "$nopass" >$logpath/user-logs/remaining_users_with_no_pass-"$(date "+%H:%M")".txt
    open_menu

}

change_all_pass() {
    clear
    echo "This will prompt you to change ALL users passwords.
    enter 1 to continue or enter to go back to main menu"
    read -r ask_cap
    clear
    if [ "$ask_cap" = "1" ]; then
        for user in $users; do
            echo "enter new password for $user"
            passwd "$user"
            log_command "passwd $user"
        done
        open_menu
    else
        clear
        open_menu
    fi
}

rand_users_password() {
    saftey_check
    clear
    echo -e "${RED}This will change ALL users passwords make sure you change any account password before you log out.${ENDCOLOR}"
    echo -e "${RED}Should proably make sure this accounts aren't tied to a email account"
    echo -e "${YELLOW}Press enter to go back or 1 to start${ENDCOLOR}"
    read -r ask_rand
    clear
    if [ "$ask_rand" = "1" ]; then
        for user in $users; do
            new_password=$(
                tr -dc A-Za-z0-9 </dev/urandom | head -c 13
                echo
            )
            echo "$user:$new_password" | sudo chpasswd
            if [ $? -eq 1 ]; then
                echo -e "${RED}Failed to change $user's password${ENDCOLOR}"

            else
                echo -e "${GREEN}Changed $user's password${ENDCOLOR}"
            fi
        done
        echo -e "${GREEN}Change your current password${ENDCOLOR}"
        passwd
        pause_script
        open_menu
    else
        echo -e "${YELLOW}NOT changing any passwords${ENDCOLOR}"
        slee .3
        clear
        open_menu
    fi
}

setup_newtty() {
    clear
    sec=10
    echo -e "${YELLOW}This will walk you through setting up another TTY for the funtion ${FUNCNAME[1]}.${ENDCOLOR}"
    echo -e "${YELLOW}After you enter the TTY number you want it will bring you to that TTY ${BOLDRED}you will have to login.${ENDCOLOR}"
    echo -e "${YELLOW}If you cant switch back to your orginal TTY the script will attempt to bring you back after a timeout but you many have to use ctl+alt+fn#${ENDCOLOR}"
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
    read -p "Enter the just the TTY number you want not /dev..$base_tty" TTYnum
    read -p "Enter the timeout in seconds ($sec) before you are brought back to this tty ($base_tty$cur_tty_num): " sec
    chvt $TTYnum
    sleep "$sec"
    chvt $cur_tty_num

}

ip_mon() {
    echo -e "This will guide you through setting up a logger for red team IPs."
    echo -e "Enter the IP range of the red team"
    read -p "Enter base IP address don't put the second dot (192.168): " base_range
    base_range_formated=$(echo $base_range | sed 's/\./ /g')
    echo "Formatted base IP address: $base_range_formated"
    range='([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])'
    base_range_formated=(${base_range_formated})
    full_pattern="${base_range_formated[0]}\.${base_range_formated[1]}\.${range}\.${range}"
    echo -e "Full regex pattern: '$full_pattern'"
    read -p "Do you want atempt to log in another tty while keeping this one free untill quit? y/N: " new_tty
    if [ $new_tty == "y" ]; then
        setup_newtty
    else
        echo "Not setting up new TTY"
    fi
    {
        tail -n0 -f /var/log/*.log | grep -E --line-buffered "$full_pattern" | while read -r line; do
            wall "Red Team IP Found: $line $0"
            # echo "$line" >> ./logs/ip_detections.log
        done
    } >"$base_tty$TTYnum" 2>&1 & # Run in the background "$base_tty$TTYnum"

    echo "Logging started in TTY $base_tty$TTYnum"
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
    saftey_check
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
    echo -e "Do you want to spawn a log monitor on another TTY? Y/N: "
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
    saftey_check
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
            echo "Backing up firewall config ""/etc/firewalld/zones"" "
            mkdir $backuppath/zonebackup/zonebackup-"$(date "+%H:%M")"
            log_command "mkdir $backuppath/zonebackup/zonebackup-$(date "+%H:%M")"
            cp /etc/firewalld/zones/* $backuppath/zonebackup/zonebackup-"$(date "+%H:%M")"
            log_command "cp /etc/firewalld/zones/* $backuppath/zonebackup/zonebackup-$(date "+%H:%M")"
            sudo rm -rf /etc/firewalld/zones/*
            sudo firewall-cmd --complete-reload
            sudo iptables -X
            sudo iptables -F
            sudo iptables -Z
            sudo systemctl restart firewalld
            log_command "rm -rf /etc/firewalld/zones/*"
            log_command "sudo firewall-cmd --complete-reload"
            log_command "sudo iptables -X"
            log_command "sudo iptables -F"
            log_command "sudo iptables -Z"
            log_command "sudo systemctl restart firewalld"
            echo "enter the number that you want to allow on the firewall"
            select port in "HTTP" "EMAIL" "DNS" "NTP"; do
                case $port in
                "HTTP")
                    for port in "${http_ports[@]}"; do
                        sudo firewall-cmd --zone=public --add-port="$port"/tcp --permanent
                        log_command "sudo firewall-cmd --zone=public --add-port=$port/tcp --permanent"
                    done
                    open_menu
                    ;;
                "EMAIL")
                    for port in "${email_ports[@]}"; do
                        sudo firewall-cmd --zone=public --add-port="$port"/tcp --permanent
                        log_command "sudo firewall-cmd --zone=public --add-port=$port/tcp --permanent"
                    done
                    open_menu
                    ;;
                "DNS")
                    sudo firewall-cmd --zone=public --add-port=53/udp --permanent
                    log_command "sudo firewall-cmd --zone=public --add-port=53/udp --permanent"
                    open_menu
                    ;;
                "NTP")
                    sudo firewall-cmd --zone=public --add-port=123/udp --permanent
                    log_command "sudo firewall-cmd --zone=public --add-port=123/udp --permanent"
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
    echo -e "${GREEN}Please enter from the list of predesited dir or enter the path to the folder you want backed up: /var/www/html...${ENDCOLOR}"
    select backupdir in "NGINX" "Apache" "MySQL" "Splunk" "NTP" "DNS" "SMTP" "IMAP"; do
        case $backupdir in
        "NGINX")
            echo "Backing up NGINX config and data dir ""/usr/share/nginx/html /etc/nginx"" "
            mkdir -p $backuppath/nginx/ngix-backup-"$(date "+%H:%M")"
            cp -r /usr/share/nginx/html /etc/nginx $backuppath/nginx/ngix-backup-"$(date "+%H:%M")"
            echo "This is what was ran: cp -r /usr/share/nginx/html /etc/nginx $backuppath/nginx/ngix-backup-$(date "+%H:%M")" >>$backuppath/nginx/ngix-backup-"$(date "+%H:%M")"/nginx-backup-log.txt
            log_command "mkdir -p $backuppath/nginx/ngix-backup-$(date "+%H:%M")"
            log_command "cp -r /usr/share/nginx/html /etc/nginx $backuppath/nginx/ngix-backup-$(date "+%H:%M")"
            open_menu
            ;;
        "Apache")
            os="Apache"
            os_type="web server"
            break
            ;;
        "MySQL")
            os="MySQL"
            os_type="database server"
            break
            ;;
        "Splunk")
            os="Splunk"
            os_type="log management"
            break
            ;;
        "NTP")
            os="NTP"
            os_type="network protocol"
            break
            ;;
        "DNS")
            os="DNS"
            os_type="network protocol"
            break
            ;;
        "SMTP")
            os="SMTP"
            os_type="mail protocol"
            break
            ;;
        "IMAP")
            os="IMAP"
            os_type="mail protocol"
            break
            ;;
        *)
            echo "Invalid selection"
            ;;
        esac
    done
}
# Start
auto_os
echo -e "${BLUE}OS detected:${ENDCOLOR}${RED} $os${ENDCOLOR}
${BLUE}Enter 1 to switch OS's or enter to continue${ENDCOLOR}"
read -r ask_man
clear
if [ "$ask_man" = "1" ]; then
    clear
    man_os
fi
clear
open_menu
