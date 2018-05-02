FROM ubuntu:18.04

ARG DEBIAN_FRONTEND=noninteractive

MAINTAINER diogocezar/php7 Diogo Cezar <diogo@diogocezar.com>

######################
# UPDATE AND UPGRADE #
######################

RUN apt-get clean all
RUN apt-get update && apt-get -y upgrade

###########
# INSTALL #
###########

# APACHE #
RUN apt-get install -y apache2

# GIT #
RUN apt-get install -y git

# SUPERVISOR #
RUN apt-get install -y nano supervisor

# DIALOG APT-UTILS #
RUN apt-get install dialog apt-utils -y

# PHP #
RUN apt-get install -y --allow-unauthenticated \
    php \
    php-gettext \
    libapache2-mod-php \
    php-common \
    php-pear \
    php-mbstring \
    php-curl \
    php-gd \
    php-dev \
    php-xmlrpc \
    php-intl \
    php-mysql \
    php-cli \
    && apt-get clean 

# TIMEZONE #
RUN echo "America/Sao_Paulo" > /etc/timezone && dpkg-reconfigure -f noninteractive tzdata

# COMPOSER #
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer \
    && chmod a+x /usr/local/bin/composer

##################
# CONFIGURATIONS #
##################

ENV TERM xterm

##########
# APACHE #
##########

RUN rm -Rf /var/www/html
RUN mkdir -p /var/lock/apache2 /var/run/apache2
RUN echo "ServerName 127.0.0.1" >> /etc/apache2/apache2.conf
COPY 000-default.conf /etc/apache2/sites-available/000-default.conf
RUN a2ensite 000-default.conf && a2enmod rewrite && a2enmod php7.2

ENV APACHE_RUN_USER    www-data
ENV APACHE_RUN_GROUP   www-data
ENV APACHE_PID_FILE    /var/run/apache2.pid
ENV APACHE_RUN_DIR     /var/run/apache2
ENV APACHE_LOCK_DIR    /var/lock/apache2
ENV APACHE_LOG_DIR     /var/log/apache2

#######
# PHP #
#######

COPY php.ini /etc/php/7.2/apache2/php.ini

##############
# SUPERVISOR #
##############

RUN mkdir -p /var/lock/apache2 /var/run/apache2 /var/run/sshd /var/log/supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

#########
# PORTS #
#########
EXPOSE 22 80

##########
# VOLUME #
##########
VOLUME ["/var/www"]

########
# EXEC #
########
CMD ["/usr/bin/supervisord"]