#!/bin/bash
source onerun.env

rm -rf installed_potentially_malicious.txt installed_services.txt

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
}

common_services_checker() {

    for i in ${service_detection[@]}; do
        # sleep .2
        command -v $i >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo "$i is installed"
            echo "$i" >>installed_services.txt

        else
            echo "$i is not installed"
        fi
    done
    echo -e "${GREEN}End of common services${ENDCOLOR}"
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
servicectl_check
common_services_checker
clear
service_status
for i in ${IMPORTANT_SERVICES[@]}; do
    if [[ "${installed_services[@]}" =~ "$i" ]]; then
        echo "$i found"
    else
        echo "$i not found"
    fi
done



