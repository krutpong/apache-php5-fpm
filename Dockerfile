FROM ubuntu:14.04
MAINTAINER krutpong "krutpong@gmail.com"

ENV DEBIAN_FRONTEND noninteractive
ENV INITRD No
ENV LANG en_US.UTF-8

#add Thailand repo
RUN apt-get update
RUN apt-get install -y software-properties-common
RUN apt-get install -y python-software-properties
RUN LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php
RUN apt-get update

#setup timezone
RUN apt-get install -y tzdata
RUN echo "Asia/Bangkok" > /etc/timezone \
    rm /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata

#setup supervisor
RUN apt-get install -y supervisor
RUN mkdir -p /var/log/supervisor

#setup apache
RUN apt-get install -y php5-fpm apache2 libapache2-mod-fastcgi
RUN a2enmod actions
RUN apache2ctl -M | grep mpm
RUN a2dismod mpm_prefork
RUN a2dismod mpm_worker
RUN a2enmod mpm_event
RUN a2enmod rewrite
RUN mkdir -p /var/lock/apache2 /var/run/apache2
RUN a2enmod ssl
RUN a2enmod headers
RUN a2enmod fastcgi proxy_fcgi

COPY config/php5-fpm.conf /etc/apache2/conf-available/php.conf
RUN a2enconf php.conf

COPY sites-available /etc/apache2/sites-available/
RUN sed -i 's/CustomLog/#CustomLog/' /etc/apache2/conf-available/other-vhosts-access-log.conf
RUN sed -i 's/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf
RUN sed -i 's/KeepAlive On/KeepAlive Off/' /etc/apache2/apache2.conf
RUN sed -i 's/MaxKeepAliveRequests 100/MaxKeepAliveRequests 1024/' /etc/apache2/apache2.conf

#setup git
RUN apt-get install -y git

#setup nano
RUN apt-get install -y nano

#setup php-extention
RUN apt-get install -y libpcre3-dev
RUN apt-get install -y php5-mysql
RUN apt-get install -y php5-mcrypt
RUN apt-get install -y pwgen
RUN apt-get install -y php5-cli
RUN apt-get install -y php5-curl
RUN apt-get install -y php5-sqlite
RUN apt-get install -y php5-apcu
RUN apt-get install -y php5-memcached
RUN apt-get install -y php5-redis
RUN apt-get install -y php5-dev
RUN apt-get install -y php5-gd
RUN apt-get install -y php-pear
RUN apt-get install -y php5-mongo
RUN apt-get install -y imagemagick
RUN apt-get install -y php5-imagick
RUN apt-get install -y libreadline-dev
RUN apt-get install -y phpunit
RUN echo 'short_open_tag=On' > /etc/php5/fpm/php.ini
RUN echo 'display_errors=On' > /etc/php5/fpm/php.ini

#Pointing to php7.1-mcrypt with php7.2 will solve the issue here.
#Below are the steps to configure 7.1 version mcrypt with php7.2
RUN apt-get install -y php5-mcrypt
RUN php5enmod mcrypt

RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/ssl-cert-snakeoil.key -out /etc/ssl/certs/ssl-cert-snakeoil.pem -subj "/C=AT/ST=Vienna/L=Vienna/O=Security/OU=Development/CN=example.com"

# Install composer
RUN apt-get install -y zip
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN apt-get clean

EXPOSE 80
EXPOSE 443
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

ADD config/index.html /var/www/index.html
ADD config/index.php /var/www/index.php

COPY config/apache_enable.sh apache_enable.sh
RUN chmod 744 apache_enable.sh


#VOLUME ["/var/lib/mysql"]
VOLUME ["/var/www","/var/www"]
RUN service php5-fpm start
CMD ["/usr/bin/supervisord"]
