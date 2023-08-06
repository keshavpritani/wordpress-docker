#!/bin/bash

# Function to display usage message
display_usage() {
    echo "Usage: $0 <type> [site_name]"
    echo "  type: Specify - setup_env / enable / disable / destroy_setup."
    echo "  site_name: Specify the site name (if first parameter is 'enable')."
}

# Check if the number of arguments is less than 1
if [ $# -lt 1 ]; then
    display_usage
    exit 1
fi

# Set the type
type="$1"

# Set the site name (useful if the parameter is not specified)
site_name=""

if [ "${type}" == "enable" ] && [ $# -ne 2 ]; then 
    echo "site_name is required in case of 'enable' type"
    display_usage
    exit 1
fi

# Check if the site name is provided
if [ $# -eq 2 ]; then
    site_name="$2"
fi

install_docker() {
    docker --version > /dev/null
    if [ $? == 0 ]; then echo "Docker is already installed"; return 0; fi

    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh ./get-docker.sh

    sudo chmod 666 /var/run/docker.sock
    sudo groupadd docker
    sudo usermod -aG docker ${USER}

    rm  get-docker.sh
}

install_docker_compose() {
    docker-compose --version > /dev/null
    if [ $? == 0 ]; then echo "Docker Compose is already installed"; return 0; fi

    sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

    sudo chmod +x /usr/local/bin/docker-compose
}

setup_wordpress(){

    if [ -f site/wp-config.php ]; then echo "Wordpress setup is already done"; return 0; fi

    cd site
    wget https://wordpress.org/latest.tar.gz || exit 1
    tar -xvf latest.tar.gz > /dev/null || exit 1
    mv wordpress/* .
    rm latest.tar.gz
    rmdir wordpress
    cd ..

    echo "define('FORCE_SSL_ADMIN', true);" >> site/wp-config-sample.php

    cp site/wp-config-sample.php site/wp-config.php

    export $(cat .env | xargs)
    host_ip=$(hostname -i)

    sed -i "s/localhost/${host_ip}/g" site/wp-config.php
    sed -i "s/username_here/${MYSQL_USER}/g" site/wp-config.php
    sed -i "s/password_here/${MYSQL_PASSWORD}/g" site/wp-config.php
    sed -i "s/database_name_here/${MYSQL_DATABASE}/g" site/wp-config.php

}

# Switch case to perform different actions based on the value of the type
case "$type" in
    "setup_env")
        echo "Performing action - setup_env:"
        install_docker
        install_docker_compose
        ;;
    "enable")
        echo "Performing action - enable:"
        install_docker
        install_docker_compose
        if [ ! -s .env ]; then echo "Environment file not found"; exit 1; fi
        setup_wordpress
        if [ ! -f docker-compose.yml ]; then echo "Docker Compose file not found"; exit 1; fi
        docker-compose up -d

        # checking for /etc/hosts entry
        if [ -z "$(grep -E "127.0.0.1 ${site_name}^" /etc/hosts )" ]; then
            echo "127.0.0.1 ${site_name}" | sudo tee -a /etc/hosts > /dev/null
        fi

        echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
        echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
        echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
        echo "Wordpress Site is up and working now at - ${site_name}"
        echo "Please open your browser and complete its setup"
        echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
        echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
        echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
        ;;
    "disable")
        echo "Performing action - disable:"
        docker-compose down
        ;;
    "destroy_setup")
        echo "Performing action - destroy_setup:"
        docker-compose down
        docker system prune -a -f
        rm -rf site/* nginx/logs/*
        touch nginx/logs/access.log nginx/logs/error.log
        ;;
    *)
        echo "Invalid type"
        display_usage
        exit 1
        ;;
esac
