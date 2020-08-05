FROM debian

LABEL maintainer="me@kevinthomas.dev"

RUN echo "deb http://deb.debian.org/debian buster-backports main contrib non-free" >>/etc/apt/sources.list

RUN apt-get update

RUN apt-get -y -t buster-backports install shellcheck

COPY . /debian-gaming-setup

WORKDIR /debian-gaming-setup

RUN shellcheck debian-gaming-setup

RUN ./test/debian-gaming-setup.bats
