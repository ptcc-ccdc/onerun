#!/bin/bash -i

# Simple setup https://docs.k3s.io/quick-start

# Cool setup https://docs.k3s.io/datastore/ha-embedded 


# You can install k3s and auto apply all the manifests needed per node based on the hostname

set -e


if [ "$(hostname)" = "node1.cluster" ]; then
    curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=v1.30.0+k3s1 sh -s - server \
        --token= \
        --tls-san 192.168.1.250 --tls-san 192.168.40.10 \
        --tls-san 192.168.40.20 --tls-san 192.168.40.30 --server https://192.168.40.20:6443 \
        --flannel-iface enp7s0 --node-ip 192.168.40.10 --data-dir=/giga/k3s/ --disable=traefik || echo "Error while installing k3s"

    # More commands here
    echo "Hello"
    kubectl apply -f Scripts/k3s/manifests/Debian/server.yaml

elif [ "$(hostname)" = "node2.cluster" ]; then
    curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=v1.30.0+k3s1  sh -s - server \
        --token= \
        --tls-san 192.168.1.250 --tls-san 192.168.40.10 \
        --tls-san 192.168.40.20 --tls-san 192.168.40.30 --server https://192.168.40.10:6443 \
        --flannel-iface enp2s0 --node-ip 192.168.40.20 --disable=traefik || echo "Error while installing k3s"

    # More commands here
    echo "Hello"

elif [ "$(hostname)" = "node3.cluster" ]; then
    curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=v1.30.0+k3s1  sh -s - server \
        --token= \
        --tls-san 192.168.1.250 --tls-san 192.168.40.10 \
        --tls-san 192.168.40.20 --tls-san 192.168.40.30 --server https://192.168.40.10:6443 \
        --flannel-iface enp2s0 --node-ip 192.168.40.30 --disable=traefik || echo "Error while installing k3s"
    # More commands here
    echo "Hello"

else 
    echo "Hostname invaild"
fi