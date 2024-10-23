# #!/bin/bash

# # Example functions (you might have more)
# deb_remove_ssh() {
#     echo "Removing SSH..."
#     sleep 5 &
#     echo "pep"
# }

# # Error handling function
# handle_error() {
#     dialog --msgbox "$1" 10 40
# }

# # Function to check if the called function exists
# run_function_if_exists() {
#     if declare -F "$1" > /dev/null 2>&1; then
#         $1 | tee gen-log.txt
#     else
#         handle_error "Function '$1' does not exist!"
#     fi
# }

# # Main menu function using dialog
# Debian_main_menu() {
#     while true; do
#         # Dialog menu
#         dialog --clear --title "Debian Main Menu" --menu "Select an option:" 15 50 9 \
#             1 "Remove ssh" \
#             2 "Change ALL users passwords" \
#             3 "Check users that can login" \
#             4 "users w/o passwords" \
#             5 "Check Firewall" \
#             6 "Remove .ssh" \
#             7 "Backup dirs" \
#             8 "Magicx" \
#             9 "testing" \
#             0 "Exit" 2>menu_choice.txt

#         # Read the user's choice
#         CHOICE=$(<menu_choice.txt)
#         clear
        
#         case $CHOICE in
#             1) run_function_if_exists "deb_remove_ssh" ;;
#             2) run_function_if_exists "change_all_pass" ;;
#             3) run_function_if_exists "check_users_can_login" ;;
#             4) run_function_if_exists "users_no_pass" ;;
#             5) run_function_if_exists "deb_firewall_check" ;;
#             6) run_function_if_exists "remove_ssh" ;;
#             7) run_function_if_exists "backup" ;;
#             8) run_function_if_exists "learning_the_hard_way" ;;
#             9) run_function_if_exists "testingfunc" ;;
#             0) exit ;;
#             *) handle_error "Invalid selection";;
#         esac
#     done
# }

# # Start the menu
# Debian_main_menu
