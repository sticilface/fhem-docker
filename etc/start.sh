#! /bin/bash

set -x

# Copy default files if target does not yet exists

if [[ ! -e /opt/fhem/.template_copied_DO_NOT_REMOVE ]]; then
  cd /opt/fhem-svn && cp -r . /opt/fhem
  cp /opt/fhem/fhem.cfg.demo /opt/fhem/fhem.cfg
  touch /opt/fhem/.template_copied_DO_NOT_REMOVE
  chown -R fhem:fhem /opt/fhem
fi

# set timezone
TZ='Europe/London'; export TZ

# if `docker run` first argument start with `--` the user is passing fhem launcher arguments
if [[ $# -lt 1 ]] || [[ "$1" == "--"* ]]; then
   service fhem start
fi

# As argument is not fhem, assume user want to run his own process, for sample a `bash` shell to explore this image
exec "$@"