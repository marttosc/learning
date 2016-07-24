FROM ubuntu:16.04

MAINTAINER Gustavo Marttos <marttosc@gmail.com>

RUN apt-get update
RUN apt-get install -y nginx
RUN service nginx start
RUN service nginx status

EXPOSE 80
EXPOSE 443

