#!/bin/bash




servicectl_check() {
    if command -v systemctl &>/dev/null; then
        echo "System has systemctl"
        servicectl="systemctl"
    elif command -v service &>/dev/null; then
        echo "System has service"
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
        command -v $i >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo "$i is installed"
            echo "$i" >>installed_potentially_malicious.txt
        else
            echo "$i is not installed"
        fi
    done
    echo -e "${GREEN}End of malicious services${ENDCOLOR}"
}

run_function_if_exists() {
    if declare -F "$1" >/dev/null 2>&1; then
        $1
    else
        echo "Function '$1' does not exist!"
    fi
}
list_functions() {
    echo "Defined functions:"
    declare -F |  cut -d' ' -f3
}

run_function_if_exists $1