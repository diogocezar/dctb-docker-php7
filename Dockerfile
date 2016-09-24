FROM ubuntu:14.04

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

# SSH #
RUN apt-get install -y openssh-server

# NANO #
RUN apt-get install -y nano

# UNZIP #
RUN apt-get install -y unzip

# BASH-COMPLETION #
RUN apt-get install -y bash-completion

# SUPERVISOR #
RUN apt-get install -y nano supervisor

# CURL #
RUN apt-get install -y curl

# COMMON #
RUN apt-get -y install software-properties-common

# PHP 7 #
RUN add-apt-repository ppa:ondrej/php -y && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C && apt-get update
RUN apt-get install -y --allow-unauthenticated \
    php7.0 \
    php-gettext \
    php7.0-curl \
    php7.0-gd \
    php7.0-dev \
    php7.0-xmlrpc \
    php7.0-intl \
    php7.0-mcrypt \
    php7.0-mysql \
    php7.0-cli \
    libapache2-mod-php7.0 \
    && apt-get clean

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
RUN a2ensite 000-default.conf && a2enmod rewrite && a2enmod php7.0

ENV APACHE_RUN_USER    www-data
ENV APACHE_RUN_GROUP   www-data
ENV APACHE_PID_FILE    /var/run/apache2.pid
ENV APACHE_RUN_DIR     /var/run/apache2
ENV APACHE_LOCK_DIR    /var/lock/apache2
ENV APACHE_LOG_DIR     /var/log/apache2

#######
# PHP #
#######

COPY php.ini /etc/php/7.0/apache2/php.ini

#######
# SSH #
#######

RUN mkdir /var/run/sshd
RUN echo 'root:root' | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

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