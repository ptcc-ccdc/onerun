
logpath=./logs
log_command() {
    echo "At $(date) the user $USER ran: $1" >> $logpath/ran_commands.txt
}
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

findrm_keys() {

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
        done

}

