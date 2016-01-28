#!/bin/sh

##########################################################################################
#
# GeoIP Updates (geoip_updates.sh) (c) by Jack Szwergold
#
# GeoIP Updates is licensed under a
# Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.
#
# You should have received a copy of the license along with this
# work. If not, see <http://creativecommons.org/licenses/by-nc-sa/4.0/>.
#
# w: http://www.preworn.com
# e: me@preworn.com
#
# Created: 2012-06-15, js
# Version: 2012-06-15, js: creation
#          2012-06-15, js: development
#
##########################################################################################

LOCK_NAME="GEOIP_UPDATES";
LOCK_DIR=/tmp/${LOCK_NAME}.lock;
PID_FILE=${LOCK_DIR}/${LOCK_NAME}.pid;
GEOIP_CITY_URL='http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz';
GEOIP_COUNTRY_URL='http://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz';
GEOIP_ASNUM_URL='http://geolite.maxmind.com/download/geoip/database/asnum/GeoIPASNum.dat.gz';
GEOIP_COUNTRY_CSV_URL='http://geolite.maxmind.com/download/geoip/database/GeoIPCountryCSV.zip';
GEOIP_DIRECTORY='/usr/local/share/GeoIP/';

if mkdir ${LOCK_DIR} 2>/dev/null; then

  ######################################################################################
  # If the ${LOCK_DIR} doesn't exist, then start working & store the ${PID_FILE}
  echo $$ > ${PID_FILE};

  ######################################################################################
  # Get the GeoIP country data.
  wget -N -q ${GEOIP_COUNTRY_URL} -O ${GEOIP_DIRECTORY}GeoLiteCountry.dat.gz >/dev/null & GEOIP_COUNTRY_PID=`jobs -l | awk '{print $2}'`;
  wait ${GEOIP_COUNTRY_PID};

  if [ -s ${GEOIP_DIRECTORY}GeoLiteCountry.dat.gz ]; then
    gzip -df ${GEOIP_DIRECTORY}GeoLiteCountry.dat.gz >/dev/null & GZIP_PID=`jobs -l | awk '{print $2}'`;
    wait ${GZIP_PID};

    mv -f ${GEOIP_DIRECTORY}GeoLiteCountry.dat ${GEOIP_DIRECTORY}GeoIP.dat >/dev/null & MOVE_GEOIP_COUNTRY_PID=`jobs -l | awk '{print $2}'`;
    wait ${MOVE_GEOIP_COUNTRY_PID};
  fi

  ######################################################################################
  # Get the GeoIP city data.
  wget -N -q ${GEOIP_CITY_URL} -O ${GEOIP_DIRECTORY}GeoLiteCity.dat.gz >/dev/null & GEOIP_CITY_PID=`jobs -l | awk '{print $2}'`;
  wait ${GEOIP_CITY_PID};

  if [ -s ${GEOIP_DIRECTORY}GeoLiteCity.dat.gz ]; then
    gzip -df ${GEOIP_DIRECTORY}GeoLiteCity.dat.gz >/dev/null & GZIP_PID=`jobs -l | awk '{print $2}'`;
    wait ${GZIP_PID};

    mv -f ${GEOIP_DIRECTORY}GeoLiteCity.dat ${GEOIP_DIRECTORY}GeoIPCity.dat >/dev/null & MOVE_GEOIP_CITY_PID=`jobs -l | awk '{print $2}'`;
    wait ${MOVE_GEOIP_CITY_PID};
  fi

  ######################################################################################
  # Get the GeoIP ASNum (Autonomous System Numbers) data.
  wget -N -q ${GEOIP_ASNUM_URL} -O ${GEOIP_DIRECTORY}GeoIPASNum.dat.gz >/dev/null & GEOIP_ASNUM_PID=`jobs -l | awk '{print $2}'`;
  wait ${GEOIP_ASNUM_PID};

  if [ -s ${GEOIP_DIRECTORY}GeoIPASNum.dat.gz ]; then
    gzip -df ${GEOIP_DIRECTORY}GeoIPASNum.dat.gz >/dev/null & GZIP_PID=`jobs -l | awk '{print $2}'`;
    wait ${GZIP_PID};
  fi

  ######################################################################################
  # Get the GeoIP Country CSV data.
  wget -N -q ${GEOIP_COUNTRY_CSV_URL} -O ${GEOIP_DIRECTORY}GeoIPCountryCSV.zip >/dev/null & GEOIP_COUNTRY_CSV_PID=`jobs -l | awk '{print $2}'`;
  wait ${GEOIP_COUNTRY_CSV_PID};

  if [ -s ${GEOIP_DIRECTORY}GeoIPCountryCSV.zip ]; then
    unzip -o -q -d ${GEOIP_DIRECTORY} ${GEOIP_DIRECTORY}GeoIPCountryCSV.zip >/dev/null & GZIP_PID=`jobs -l | awk '{print $2}'`;
    wait ${GZIP_PID};

    rm -f ${GEOIP_DIRECTORY}GeoIPCountryCSV.zip
  fi

  ######################################################################################
  # Delete the ${LOCK_DIR} & ${PID_FILE}
  rm -rf ${LOCK_DIR};
  exit;
else
  if [ -f ${PID_FILE} ] && kill -0 $(cat ${PID_FILE}) 2>/dev/null; then

    ##################################################################################
    # Confirm that the process file exists & a process
    # with that PID is truly running.
    # echo "Running [PID "$(cat ${PID_FILE})"]" >&2
    exit;
  else

    ##################################################################################
    # If the process is not running, yet there is a PID file--like in the case
    # of a crash or sudden reboot--then get rid of the ${LOCK_DIR}
    rm -rf ${LOCK_DIR};
    exit;
  fi
fi

