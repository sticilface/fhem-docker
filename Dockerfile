FROM debian:jessie

MAINTAINER michaelatdocker <michael.kunzmann@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get -y --force-yes install wget apt-transport-https

# Install perl packages
RUN apt-get -y --force-yes install libalgorithm-merge-perl \
libclass-isa-perl \
libcommon-sense-perl \
libdpkg-perl \
liberror-perl \
libfile-copy-recursive-perl \
libfile-fcntllock-perl \
libio-socket-ip-perl \
libio-socket-multicast-perl \
libjson-perl \
libjson-xs-perl \
libmail-sendmail-perl \
libsocket-perl \
libswitch-perl \
libsys-hostname-long-perl \
libterm-readkey-perl \
libterm-readline-perl-perl \
libxml-simple-perl

RUN wget -qO - http://debian.fhem.de/archive.key | apt-key add -
RUN echo "deb http://debian.fhem.de/nightly/ /" | tee -a /etc/apt/sources.list.d/fhem.list
RUN apt-get update
RUN apt-get -y --force-yes install supervisor fhem telnet
RUN mkdir -p /var/log/supervisor

COPY ./etc/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

VOLUME ["/opt/fhem"]
EXPOSE 8083

CMD ["/usr/bin/supervisord"]
