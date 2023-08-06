# LEMP Stack Project with WordPress in Docker
LEMP Stack with WordPress

Overview
This project sets up a complete LEMP (Linux, Nginx, MySQL, PHP) stack along with WordPress using Docker, allowing you to easily deploy a powerful and customizable content management system for your website. The stack provides high performance, scalability, and security, making it ideal for hosting your WordPress site. Additionally, it includes an automated script to add site entries in the /etc/hosts file, making local development and testing easier.

## Features: 
* LEMP stack setup for hosting WordPress websites using Docker.
* Easy installation and configuration process.
* Scalable and secure architecture.
* Optimized Nginx configuration for better performance.
* Automated script to add site entries in the /etc/hosts file for local development.


## Installation
Clone this repository to your local machine:
```sh
git clone https://github.com/keshavpritani/wordpress-docker.git
cd wordpress-docker/
```

Run the automated script:

1. To Install the Prerequisites (`docker` and `docker-compose`):
```sh
bash script.sh setup_env
```

2. To start the _Wordpress_ site:
```sh
bash script.sh enable <SITE_NAME>
```
**Note**:
* In this, second parameter is required (i.e. Site Name) at which wordpress site be running. (this will make entry in `/etc/hosts` file)
* Before running this command, make sure your `.env` is ready:
    * ```sh
      cp .env.example .env
      ```
    * Update its value

3. To stop the _Wordpress_ site:
```sh
bash script.sh disable
```

3. To destory _Wordpress_ site:
```sh
bash script.sh destory_setup
```
This will remove all the local file (i.e. database folder, .env, etc.)

## References:
https://www.howtoforge.com/tutorial/dockerizing-lemp-stack-with-docker-compose-on-ubuntu/
https://stackoverflow.com/questions/29905953/how-to-correctly-link-php-fpm-and-nginx-docker-containers
https://tech.osteel.me/posts/docker-for-local-web-development-part-1-a-basic-lemp-stack
https://www.wpbeginner.com/wp-tutorials/how-to-add-ssl-and-https-in-wordpress/
