#! /bin/bash

set -x

# Copy default files if target does not yet exists

if [[ ! -e /opt/fhem/.template_copied_DO_NOT_REMOVE ]]; then
  cd /opt/fhem-svn && cp -r . /opt/fhem
  cp /opt/fhem/fhem.cfg.demo /opt/fhem/fhem.cfg
  touch /opt/fhem/.template_copied_DO_NOT_REMOVE
  chown -R fhem:fhem /opt/fhem
fi