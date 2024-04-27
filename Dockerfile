FROM ubuntu:18.04

LABEL maintainer="krutpong <krutpong@gmail.com>"

ENV DEBIAN_FRONTEND noninteractive
ENV LANG en_US.UTF-8

# Update package lists
RUN apt-get update

# Install software-properties-common
RUN apt-get install -y software-properties-common

# Install timezone data
RUN apt-get install -y tzdata

# Install Supervisor
RUN apt-get install -y supervisor

# Install Apache2
RUN apt-get install -y apache2

# Install Apache modules
RUN apt-get install -y libapache2-mod-fcgid

# Install PHP5 and its extensions
RUN apt-get install -y php5 \
    php5-fpm \
    php5-mysql \
    php5-curl \
    php5-gd \
    php5-memcached \
    php5-redis \
    php5-mcrypt \
    php5-mbstring \
    php5-cli \
    php-pear \
    php5-dev

# Install Git
RUN apt-get install -y git

# Install Nano
RUN apt-get install -y nano

# Install ImageMagick
RUN apt-get install -y imagemagick

# Install PHP5-imagick extension
RUN apt-get install -y php5-imagick

# Install curl
RUN apt-get install -y curl

# Install zip
RUN apt-get install -y zip

# Setup timezone
RUN ln -fs /usr/share/zoneinfo/Asia/Bangkok /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata

# Enable Apache modules
RUN a2enmod rewrite ssl headers proxy_fcgi

# SSL certificate generation
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/ssl-cert-snakeoil.key -out /etc/ssl/certs/ssl-cert-snakeoil.pem -subj "/C=AT/ST=Vienna/L=Vienna/O=Security/OU=Development/CN=example.com"

# Configure Apache and PHP5-FPM
COPY config/php5-fpm.conf /etc/apache2/conf-available/php5-fpm.conf
RUN a2enconf php5-fpm

COPY sites-available /etc/apache2/sites-available/
RUN sed -i 's/CustomLog/#CustomLog/' /etc/apache2/conf-available/other-vhosts-access-log.conf
RUN sed -i 's/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf
RUN sed -i 's/KeepAlive On/KeepAlive Off/' /etc/apache2/apache2.conf
RUN sed -i 's/MaxKeepAliveRequests 100/MaxKeepAliveRequests 1024/' /etc/apache2/apache2.conf

# Expose ports
EXPOSE 80
EXPOSE 443

# Copy website files
COPY config/index.html /var/www/html/index.html
COPY config/index.php /var/www/html/index.php

# Set permissions for startup script
COPY config/apache_enable.sh /usr/local/bin/apache_enable.sh
RUN chmod +x /usr/local/bin/apache_enable.sh

# Copy Supervisor configuration
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Start Supervisor
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
