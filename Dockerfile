# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Dockerfile                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: vping <marvin@42.fr>                       +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2021/02/11 22:07:23 by vping             #+#    #+#              #
#    Updated: 2021/02/12 19:31:15 by vping            ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

FROM debian:buster

#update & upgrade
RUN apt -y update
RUN apt -y upgrade

#install nginx
RUN apt -y install nginx

#install mySQL
RUN apt -y install mariadb-server

#install php
RUN apt -y install php-fpm php-mysql php-curl php-gd php-intl php-mbstring php-soap php-xml php-xmlrpc php-zip

#install wget
RUN apt -y install wget

#install & tar & config phpmyadmin
RUN wget https://files.phpmyadmin.net/phpMyAdmin/5.0.4/phpMyAdmin-5.0.4-english.tar.gz
RUN tar xvf phpMyAdmin-5.0.4-english.tar.gz && rm -rf phpMyAdmin-5.0.4-english.tar.gz
RUN mv phpMyAdmin-5.0.4-english/ /var/www/phpmyadmin
COPY /srcs/config.inc.php /var/www/phpmyadmin/

#config nginx
RUN rm -rf /etc/nginx/sites-available/default
COPY /srcs/nginx_ai_on.conf /etc/nginx/sites-available/
RUN unlink /etc/nginx/sites-enabled/default
RUN ln -s /etc/nginx/sites-available/nginx_ai_on.conf /etc/nginx/sites-enabled/

#enable autoindex
RUN mkdir /var/www/autoindex
COPY /srcs/ai_off.sh .
COPY /srcs/ai_on.sh .
COPY /srcs/start.sh .
COPY /srcs/nginx_ai_on.conf /var/www/autoindex/
COPY /srcs/nginx_ai_off.conf /var/www/autoindex/

#install & config wordpress
RUN wget https://wordpress.org/latest.tar.gz
RUN tar xzvf latest.tar.gz && rm -rf latest.tar.gz
RUN mv wordpress/ /var/www/wordpress
COPY /srcs/wp-config.php var/www/wordpress/wp-config.php

#assign ownership
RUN chmod -R 755 /var/www/
RUN chown -R www-data:www-data /var/www/

#create self-signed ssl certificate
RUN openssl req -x509 -sha256 -nodes -newkey rsa:2048 \
    -keyout /etc/ssl/private/key.key -out /etc/ssl/certs/cert.crt \
    -subj "/C=RU/ST=TATARSTAN/L=Kazan/O=no/OU=no/CN=localhost"

#create database
RUN service mysql start \
    && mysql -u root \
    && mysql --execute="CREATE DATABASE vpingdb DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci; \
    GRANT ALL PRIVILEGES ON vpingdb.* TO 'vping'@'localhost' IDENTIFIED BY 'vping'; \
    FLUSH PRIVILEGES;"

EXPOSE 80 443

CMD bash start.sh
