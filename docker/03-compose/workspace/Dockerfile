FROM phusion/baseimage:latest

MAINTAINER Gustavo Marttos <marttosc@gmail.com>

RUN DEBIAN_FRONTEND=noninteractive
RUN locale-gen pt_BR.UTF-8

ENV LANGUAGE=pt_BR.UTF-8
ENV LC_ALL=pt_BR.UTF-8
ENV LC_CTYPE=pt_BR.UTF-8
ENV LANG=pt_BR.UTF-8
ENV TERM xterm

RUN apt-get update
RUN apt-get install -y software-properties-common

RUN add-apt-repository -y ppa:ondrej/php
RUN apt-get update

RUN apt-get install -y --force-yes \
    php7.0-cli \
    php7.0-common \
    php7.0-curl \
    php7.0-json \
    php7.0-xml \
    php7.0-mbstring \
    php7.0-mcrypt \
    php7.0-mysql \
    php7.0-pgsql \
    php7.0-sqlite \
    php7.0-sqlite3 \
    php7.0-zip \
    php7.0-memcached \
    php7.0-gd \
    php7.0-xdebug \
    php-dev \
    libcurl4-openssl-dev \
    libedit-dev \
    libssl-dev \
    libxml2-dev \
    xz-utils \
    sqlite3 \
    libsqlite3-dev \
    git \
    curl \
    vim \
    nano \
    pkg-config

RUN apt-get clean

RUN sed -i 's/^/;/g' /etc/php/7.0/cli/conf.d/20-xdebug.ini

RUN curl -s http://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer

RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /var/www/html

