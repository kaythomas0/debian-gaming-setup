FROM debian

LABEL maintainer="kevin.t0517@gmail.com"

RUN apt-get update

COPY . /debian-gaming-setup

WORKDIR /debian-gaming-setup

RUN ./test/debian-gaming-setup.bats
