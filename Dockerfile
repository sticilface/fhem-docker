FROM debian:jessie
MAINTAINER sticilface <amelvin@gmail.com>
LABEL org.freenas.interactive="false" 		\
      org.freenas.version="3.8.0002"		\
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
ENV FHEM_HOME /opt/fhem

# FHEM is ran with user `fhem`, uid = 1000
# If you bind mount a volume from host/volume from a data container, 
# ensure you use same uid
RUN useradd -d "$FHEM_HOME" -u 1000 -m -s /bin/bash fhem

# Main pacakges 
RUN apt-get update && apt-get -y --force-yes install \ 
    wget  						\
    apt-transport-https 		\
    nano build-essential 		\
#    openssh-server 				\
#    supervisor 					\
    telnet  					\
    && apt-get clean && apt-get autoremove

# Install perl packages
RUN apt-get -y --force-yes install \
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
ADD http://www.dhs-computertechnik.de/downloads/fhem-cvs.tgz /usr/local/lib/fhem.tgz
RUN cd /opt && tar xvzf /usr/local/lib/fhem.tgz    \
    && mv fhem fhem-svn 				\
    && mkdir /opt/fhem 					\
    && chown fhem:fhem /opt/fhem        
# Copy init scripts.  
COPY ./etc/fhem-init.sh /etc/init.d/fhem     
#RUN cp /opt/fhem-svn/contrib/init-scripts/fhem.3 /etc/init.d/fhem    \
RUN chmod ugo+x /etc/init.d/fhem   							 \
	&& update-rc.d fhem defaults		

# Add Tini
ENV TINI_VERSION v0.8.3
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /bin/tini
RUN chmod +x /bin/tini

# supervisor
#RUN mkdir -p /var/log/supervisor
#COPY ./etc/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
#COPY ./etc/copyfhem.sh /etc/copyfhem.sh
#RUN chmod +x /etc/copyfhem.sh

# sshd on port 2222 and allow root login / password = fhem!
#RUN mkdir /var/run/sshd
#RUN sed -i 's/Port 22/Port 2222/g' /etc/ssh/sshd_config
#RUN sed -i 's/PermitRootLogin no/PermitRootLogin yes/g' /etc/ssh/sshd_config
#RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
#RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
#RUN echo "root:fhem!" | chpasswd

#cleanup  
RUN echo Europe/London > /etc/timezone && dpkg-reconfigure tzdata

COPY ./etc/start.sh /etc/start.sh
RUN chmod +x /etc/start.sh

VOLUME ["/opt/fhem"]
EXPOSE 8083 8084 8085 

USER fhem

ENTRYPOINT ["/bin/tini", "--", "/etc/start.sh"]


