#!/bin/bash
potentially_malicious=$(cat potentially_malicious.txt)
potentially_malicious=(${potentially_malicious})

# for i in ${potentially_malicious[@]}; do
#     echo $i
#     done

# service_dicovery(){
#     sleep .3
#     $1 -v >/dev/null 2>&1
#     if [ $? -eq 0 ]; then
#         echo "$i is installed"
#     else 
#         echo "$i is not installed"
#     fi
# }

# for i in ${potentially_malicious[@]}; do
#     service_dicovery $i
#     done

for i in  ${potentially_malicious[@]}; do
    sleep .2
    $i -v >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "$i is installed"
    else
        echo "$i is not installed"      
    fi 
done  