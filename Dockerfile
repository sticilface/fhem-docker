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
      org.freenas.web-ui-path="fhem"		\
      org.freenas.port-mappings="8083:8083/tcp,8084:8084/tcp,8085:8085/tcp,8022:8022/tcp"			\
      org.freenas.volumes="[							\
          {												\
              \"name\": \"/opt/fhem\",					\
              \"descr\": \"Storage space\",				\
              \"optional\": true						\
          }												\
      ]"												\
      org.freenas.settings="[ 							\
          {												\
              \"env\": \"TZ\",							\
              \"descr\": \"Fhem container Timezone\",	\
              \"optional\": true						\
          },											\
          {												\
              \"env\": \"ADVERTISE_IP\",				\
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
ENV TERM xterm

RUN apt-get update
RUN apt-get -y --force-yes install wget apt-transport-https nano build-essential

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
libxml-simple-perl \
cpanminus

RUN cpanm Net::MQTT::Simple
RUN cpanm Net::MQTT::Constants

RUN wget -qO - http://debian.fhem.de/archive.key | apt-key add -
RUN echo "deb http://debian.fhem.de/nightly/ /" | tee -a /etc/apt/sources.list.d/fhem.list
RUN apt-get update
RUN apt-get -y --force-yes install supervisor fhem telnet
RUN mkdir -p /var/log/supervisor

# sshd on port 2222 and allow root login / password = fhem!
RUN apt-get -y --force-yes install openssh-server && apt-get clean
RUN mkdir /var/run/sshd
RUN sed -i 's/Port 22/Port 2222/g' /etc/ssh/sshd_config
RUN sed -i 's/PermitRootLogin no/PermitRootLogin yes/g' /etc/ssh/sshd_config
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
RUN echo "root:fhem!" | chpasswd
#RUN /bin/rm  /etc/ssh/ssh_host_*
#RUN dpkg-reconfigure openssh-server

RUN apt-get clean && apt-get autoremove

COPY ./etc/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

VOLUME ["/opt/fhem"]
EXPOSE 8083 8084 8085 2222 

#ENTRYPOINT ["/bin/bash"]

CMD ["/usr/bin/supervisord"]
