FROM nginx:latest

MAINTAINER Gustavo Marttos <marttosc@gmail.com>

ADD nginx.conf /etc/nginx/

ARG PHP_UPSTREAM

RUN echo "upstream php-upstream { server ${PHP_UPSTREAM}:9000; }" > /etc/nginx/conf.d/upstream.conf

RUN usermod -u 1000 www-data

CMD ["nginx"]

EXPOSE 80
EXPOSE 443

