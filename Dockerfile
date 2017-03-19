FROM debian:jessie
MAINTAINER sticilface <amelvin@gmail.com>
LABEL org.freenas.interactive="false" 		\
      org.freenas.version="3.8"		\
      org.freenas.upgradeable="true"		\
      org.freenas.expose-ports-at-host="true"	\
      org.freenas.autostart="true"		\
      org.freenas.capabilities-add="NET_BROADCAST" \
      org.freenas.web-ui-protocol="http"	\
      org.freenas.web-ui-port=8083		\
      org.freenas.web-ui-path="web"		\
      org.freenas.port-mappings="8083:8083/tcp"			\
      org.freenas.volumes="[					\
          {							\
              \"name\": \"/opt/fhem\",				\
              \"descr\": \"Storage space\"		\
          }							\
      ]"							\
      org.freenas.settings="[ 					\
          {							\
              \"env\": \"TZ\",					\
              \"descr\": \"Fhem container Timezone\",		\
              \"optional\": true				\
          },							\
          {							\
              \"env\": \"ADVERTISE_IP\",			\
              \"descr\": \"http://<hostIPAddress>:8083/fhem\",	\
              \"optional\": true				\
          },							\
          {							\
              \"env\": \"ALLOWED_NETWORKS\",			\
              \"descr\": \"IP/mask[,IP/mask]\",			\
              \"optional\": true				\
          },							\
          {							\
              \"env\": \"FHEM_UID\",				\
              \"descr\": \"Fhem User ID\",			\
              \"optional\": true				\
          },							\
          {							\
              \"env\": \"FHEM_GID\",				\
              \"descr\": \"Fhem Group ID\",			\
              \"optional\": true				\
          }  \
       ]"

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
