#!/bin/bash

##########################################################################################
#
# Block IP addresses (block_ip_addresses.sh) (c) by Jack Szwergold
#
# Block IP addresses is licensed under a
# Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.
#
# You should have received a copy of the license along with this
# work. If not, see <http://creativecommons.org/licenses/by-nc-sa/4.0/>.
#
# w: http://www.preworn.com
# e: me@preworn.com
#
# Created: 2012-04-30, js: Creation.
# Version: 2012-04-30, js: Tweaked & debugged.
#          2012-05-01, js: More cleanup.
#          2012-05-24, js: Added line-space between CATting of the TOR_80'.tmp' & TOR_9998'.tmp' files.
#          2015-10-28, js: Changing the action from DROP to REJECT.
#          2015-10-28, js: Switching to IPSet; IPTables method is an expensive process.
#          2015-10-29, js: Cleaning up this mess.
#          2015-11-03, js: Some restructuring.
#          2016-01-17, js: Major refactoring with arrays and loops.
#
##########################################################################################

LOCK_NAME="BLOCK_IP_ADDRESS_PROCESS"
LOCK_DIR='/tmp/'"${LOCK_NAME}"'.lock'
PID_FILE="${LOCK_DIR}"'/'"${LOCK_NAME}"'.pid'

##########################################################################################
# Load the configuration file.
##########################################################################################

# Set the config file.
CONFIG_FILE="./block_ip_addresses.cfg.sh"

# Checks if the base script directory exists.
if [ -f "${CONFIG_FILE}" ]; then
  source "${CONFIG_FILE}"
else
  echo $(date)" - [ERROR: Configuration file '${CONFIG_FILE}' not found. Script stopping.]" & CHECK_PID=(`jobs -l | awk '{print $2}'`);
  wait ${CHECK_PID}
  exit 1; # Exit if fails.
fi

##########################################################################################
# Checks to make sure our working environment works.
##########################################################################################

if mkdir ${LOCK_DIR} 2>/dev/null; then
  # If the ${LOCK_DIR} doesn't exist, then start working & store the ${PID_FILE}
  echo $$ > ${PID_FILE}

  ########################################################################################
  # Before anything, go into working directory.
  ########################################################################################

  cd ${DIR}

  ########################################################################################
  # Create the IPSet TOR_IPS config file.
  ########################################################################################

  # RAW: Get the data from each TOR port.
  for TOR_PORT in "${TOR_PORT_ARRAY[@]}"
  do

    # Init temp files.
    :> "${DIR}${SET_TOR_IPS}_${TOR_PORT}.tmp"

    # Get the list of exit nodes from TOR.
    curl -L --connect-timeout "${CURL_TIMEOUT}" -o "${DIR}${SET_TOR_IPS}_${TOR_PORT}.tmp" "${TOR_URL}${TOR_PORT}" >/dev/null 2>&1

    # Combine the list of TOR exit nodes.
    awk 'FNR==1 { print "" } 1' "${DIR}${SET_TOR_IPS}_${TOR_PORT}.tmp" >> "${DIR}${SET_TOR_IPS}_RAW.tmp"

  done

  # CLEANED: Check if the raw list of TOR exit nodes exists and is not empty before doing anything else.
  if [ -f "${DIR}${SET_TOR_IPS}_RAW.tmp" ]; then
    if [ -s "${DIR}${SET_TOR_IPS}_RAW.tmp" ]; then

      # Clean empty lines and comments out of the list of TOR exit nodes.
      grep '^[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}$' "${DIR}${SET_TOR_IPS}_RAW.tmp" | awk 'NF { print }' > "${DIR}${SET_TOR_IPS}_CLEANED.tmp"

    fi
  fi

  # SORTED: Check if the cleaned up list of TOR exit nodes exists and is not empty before doing anything else.
  if [ -f "${DIR}${SET_TOR_IPS}_CLEANED.tmp" ]; then
    if [ -s "${DIR}${SET_TOR_IPS}_CLEANED.tmp" ]; then

      # Sort the list of TOR exit nodes.
      cat "${DIR}${SET_TOR_IPS}_CLEANED.tmp" | sort | uniq > "${DIR}${SET_TOR_IPS}_SORTED.tmp"

      # Init a new TOR_IPS file.
      :> "${DIR}ipset.${SET_TOR_IPS}.conf"

      if [ -f "${DIR}ipset.${SET_TOR_IPS}.conf" ]; then

        # Use AWK to create the TOR IPSet config file.
        awk 'NF {print "add TOR_IPS " $0}' "${DIR}${SET_TOR_IPS}_SORTED.tmp" > "${DIR}ipset.${SET_TOR_IPS}.conf"

      fi

    fi
  fi

  ########################################################################################
  # Create the IPSet SET_BANNED_RANGES config file.
  ########################################################################################

  # Check if the GeoIP country CSV exists and is not empty before doing anything else.
  if [ -f "${GEOIP_COUNTRY_CSV}" ]; then
    if [ -s "${GEOIP_COUNTRY_CSV}" ]; then

      # Init a new SET_BANNED_RANGES file.
      :> "${DIR}ipset.${SET_BANNED_RANGES}.conf"

      if [ -f "${DIR}ipset.${SET_BANNED_RANGES}.conf" ]; then

        # Roll through the array of country codes and use AWK to create the BANNED IPSet config file.
        for COUNTRY_CODE in "${COUNTRY_ARRAY[@]}"
        do
          awk -F "," -v COUNTRY_CODE="${COUNTRY_CODE}" -v IPSET_TABLE="${SET_BANNED_RANGES}" '$5 ~ COUNTRY_CODE { gsub(/"/, "", $1); gsub(/"/, "", $2); print "add " IPSET_TABLE " " $1 "-" $2; }' "${GEOIP_COUNTRY_CSV}" >> "${DIR}ipset.${SET_BANNED_RANGES}.conf"
        done

      fi

    fi
  fi

  ########################################################################################
  # Roll through each set name, and set the values into the IPSet stuff.
  ########################################################################################

  for SETNAME in "${SETNAME_ARRAY[@]}"
  do
    if [ -f "${DIR}ipset.${SETNAME}.conf" ]; then
	  if [ -s "${DIR}ipset.${SETNAME}.conf" ]; then

	    # If the set doesn't exist create it.
	    if ! "$IPSET_BIN -L -q ${SETNAME}" >/dev/null 2>&1 ; then
		  "$IPSET_BIN create -q ${SETNAME} hash:net" >/dev/null 2>&1
	    fi

	    # Flush the currently set values from the TOR chain and restore the chain with the new values.
	    # echo "$IPSET_BIN restore -! -q < ${DIR}ipset.${SETNAME}.conf"
	    $IPSET_BIN restore -! -q < "${DIR}ipset.${SETNAME}.conf"

	  fi
    fi
  done

  ########################################################################################
  # Delete the temp files.
  ########################################################################################

  # rm *.{tmp,conf}
  rm *.tmp

  rm -rf ${LOCK_DIR}
  exit
else
  if [ -f ${PID_FILE} ] && kill -0 $(cat ${PID_FILE}) 2>/dev/null; then
    # Confirm that the process file exists & a process
    # with that PID is truly running.
    # echo "Running [PID "$(cat ${PID_FILE})"]" >&2
    exit
  else
    # If the process is not running, yet there is a PID file--like in the case
    # of a crash or sudden reboot--then get rid of the ${LOCK_DIR}
    rm -rf ${LOCK_DIR}
    exit
  fi
fi

