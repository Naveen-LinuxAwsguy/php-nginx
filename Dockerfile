FROM nginx:1.18

RUN ca-certificates apt-transport-https software-properties-common wget curl lsb-release -y \
    curl -sSL https://packages.sury.org/php/README.txt |  bash -x

RUN apt update && apt install  -y \
    wget \
    curl \
    supervisor \
    php -y \
    php-bcmath \
    php-common \
    php-curl \
    php-gd \
    php-intl \
    php-mbstring \
    php-mysql \
    php-soap \
    php-xml  \
    php-zip \
    php-cli \
    php-fpm

COPY config/php.ini /etc/php.ini
COPY config/www.conf /etc/php-fpm.d/www.conf
COPY config/nginx.conf /etc/nginx/nginx.conf
COPY config/default.conf /etc/nginx/conf.d/default.conf


RUN mkdir -p /var/lib/php/session 
RUN chown -R  www-data:www-data /var/lib/php 
RUN  mkdir  -p /run/php 
RUN chown -R  www-data:www-data /run/php

#RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
#RUN php -r "if (hash_file('sha384', 'composer-setup.php') === '55ce33d7678c5a611085589f1f3ddf8b3c52d662cd01d4ba75c0ee0459970c2200a51f492d557530c71c15d8dba01eae') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
#RUN php composer-setup.php
#RUN php -r "unlink('composer-setup.php');"
#RUN mv composer.phar /usr/local/bin/composer

COPY --from=composer:2.1 /usr/bin/composer /usr/local/bin/composer
COPY config/auth /root/.config/composer/auth.json
RUN composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition:2.4.4  /var/www/html/magento

RUN chmod -R  777 /var/www/html/magento
RUN chown -R www-data:www-data  /var/www/html/magento
RUN chmod -R 777 /var/www/html/magento

COPY config/supervisord.conf /etc/supervisor/supervisord.conf

COPY commands.sh /scripts/commands.sh
RUN ["chmod", "+x", "/scripts/commands.sh"]


RUN chmod -R 777 /var/www/html/magento
RUN chown -R www-data:www-data /var/www/html/magento

EXPOSE 9000
EXPOSE 80

CMD [ "/scripts/commands.sh"]
