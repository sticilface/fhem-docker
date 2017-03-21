#¡/bin/bash


set -x

# Change the timezone

echo $TZ > /etc/timezone && dpkg-reconfigure tzdata

# Start up scripts here.  Download FHEM if it is not there already.  
# Most folk will just have it there, as mounted volume. 
if [ ! -e /opt/fhem/fhem.cfg ]; then
  echo "Downloading FHEM..."
  wget -O /usr/local/lib/fhem.tgz http://www.dhs-computertechnik.de/downloads/fhem-cvs.tgz 
  cd /opt 
  tar xvzf /usr/local/lib/fhem.tgz
  cd /opt/fhem
  mv /opt/fhem/fhem.cfg /opt/fhem/fhem.cfg.orig
  mv /opt/fhem/fhem.cfg.demo /opt/fhem/fhem.cfg
  chown -R fhem:fhem /opt/fhem
  echo "done"
fi

#start the daemon
/usr/bin/supervisord