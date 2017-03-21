docker # Docker Container for FHEM on Freenas Corral. 

Docker image for FHEM based on Debian Jessie
Inspiration from a variety of fhem docker images.  None of which quite worked as I wanted.  

MQTT perl libs installed + `Net::MQTT::Simple` and `Net::MQTT::Constants` 

FHEM user created manually as 1000, gid 1000. Your FHEM folder on freenas must have the same uid/gid or 777 permissions. 

Mount your existing fhem installations at `/opt/fhem` or leave blank to use fresh install, which will then download on starting of the container. 

