FROM debian:jessie
LABEL maintainer sticilface <amelvin@gmail.com>
LABEL org.freenas.interactive="false" 		\
      org.freenas.version="3.8.005"		\
      org.freenas.upgradeable="true"		\
      org.freenas.expose-ports-at-host="true"	\
      org.freenas.autostart="true"		\
      org.freenas.capabilities-add="NET_BROADCAST" \
      org.freenas.web-ui-protocol="http"	\
      org.freenas.web-ui-port=8083		\
      org.freenas.web-ui-path="fhem"		\
      org.freenas.port-mappings="8083:8083/tcp,8084:8084/tcp,8085:8085/tcp"			\
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
              \"descr\": \"Timezone\",	\
              \"optional\": true						\
          },											\
          {												\
              \"env\": \"ADVERTISE_IP\",				\
              \"descr\": \"http://<hostIPAddress>:8083/fhem\",	\
              \"optional\": true						\
          },											\
          {												\
              \"env\": \"ALLOWED_NETWORKS\",			\
              \"descr\": \"IP/mask[,IP/mask]\",			\
              \"optional\": true						\
          },											\
          {												\
              \"env\": \"FHEM_UID\",					\
              \"descr\": \"Fhem User ID\",				\
              \"optional\": true						\
          },											\
          {												\
              \"env\": \"FHEM_GID\",					\
              \"descr\": \"Fhem Group ID\",				\
              \"optional\": true						\
          }  											\
       ]"

ENV DEBIAN_FRONTEND noninteractive
ENV TERM xterm
ENV TZ Europe/London
ENV FHEM_UID 1000


# FHEM is ran with user `fhem`, uid = 1000
# If you bind mount a volume from host/volume from a data container, 
# ensure you use same uid
RUN useradd -d /opt/fhem -u 1000 -m -s /bin/bash fhem

# Main pacakges 
RUN apt-get update && apt-get -y --force-yes install \
	wget  						\
    apt-transport-https 		\
    nano build-essential 		\
    supervisor 					\
    telnet  					\
# Install perl packages
	libalgorithm-merge-perl 	\
	libclass-isa-perl 			\
	libcommon-sense-perl 		\
	libdpkg-perl 				\
	liberror-perl 				\
	libfile-copy-recursive-perl \
	libfile-fcntllock-perl 		\
	libio-socket-ip-perl 		\
	libio-socket-multicast-perl \
	libjson-perl 				\
	libjson-xs-perl 			\
	libmail-sendmail-perl 		\
	libsocket-perl 				\
	libswitch-perl 				\
	libsys-hostname-long-perl 	\
	libterm-readkey-perl 		\
	libterm-readline-perl-perl 	\
	libxml-simple-perl 			\
	cpanminus					\
	&& apt-get clean && apt-get autoremove

RUN cpanm Net::MQTT::Simple
RUN cpanm Net::MQTT::Constants

# Install and configure fhem.  Avoid .deb file as it creates and screws user setup.
# ADD http://www.dhs-computertechnik.de/downloads/fhem-cvs.tgz /usr/local/lib/fhem.tgz
# RUN cd /opt && tar xvzf /usr/local/lib/fhem.tgz    \
#     && chown -R fhem:fhem /opt/fhem    

# Copy init scripts for fhem.  
COPY ./etc/fhem-init.sh /etc/init.d/fhem     
RUN chmod ugo+x /etc/init.d/fhem   	\
	&& update-rc.d fhem defaults		

# supervisor
RUN mkdir -p /var/log/supervisor
COPY ./etc/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

COPY ./etc/entrypoint.sh /etc/entrypoint.sh
RUN chmod +x /etc/entrypoint.sh

VOLUME ["/opt/fhem"]
EXPOSE 8083 8084 8085 

ENTRYPOINT ["/bin/bash", "/etc/entrypoint.sh"]

