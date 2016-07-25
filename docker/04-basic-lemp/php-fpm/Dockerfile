FROM php:7.0-fpm

MAINTAINER Gustavo Marttos <marttosc@gmail.com>

ADD ./php-custom.ini /usr/local/etc/php/conf.d

RUN apt-get update
RUN apt-get install -y libpq-dev \
    curl \
    libjpeg-dev \
    libpng12-dev \
    libfreetype6-dev \
    libssl-dev \
    libmcrypt-dev \
    --no-install-recommends
RUN rm -r /var/lib/apt/lists/*

# Install mcrypt library
RUN docker-php-ext-install mcrypt

# Configure GD library
RUN docker-php-ext-configure gd \
    --enable-gd-native-ttf \
    --with-jpeg-dir=/usr/lib \
    --with-freetype-dir=/usr/include/freetype2

# Install MySQQL extension
RUN docker-php-ext-install \
    pdo_mysql \
    gd

# Install xdebug
RUN pecl install xdebug
RUN docker-php-ext-enable xdebug

RUN usermod -u 1000 www-data

WORKDIR /var/www/html

CMD ["php-fpm"]

EXPOSE 9000

