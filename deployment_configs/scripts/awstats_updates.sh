#!/bin/bash

##########################################################################################
#
# AWStats Updates (awstats_updates.sh)
#
# Programming: Jack Szwergold
#
# Created: 2011-12-01, js
# Version: 2011-12-01, js: creation
#          2014-01-31, js: development
#
##########################################################################################

LOCK_NAME="AWSTATS_UPDATES"
LOCK_DIR='/tmp/'"${LOCK_NAME}"'.lock'
PID_FILE="${LOCK_DIR}"'/'"${LOCK_NAME}"'.pid'

##########################################################################################
# Load the configuration file.
##########################################################################################

# Set the config file.
CONFIG_FILE="./awstats_updates.cfg.sh"

# Checks if the base secript directory exists.
if [ -f "${CONFIG_FILE}" ]; then
  source "${CONFIG_FILE}"
else
  echo $(date)" - [ERROR: Configuration file '${CONFIG_FILE}' not found. Script stopping.]" & CHECK_PID=(`jobs -l | awk '{print $2}'`);
  wait ${CHECK_PID}
  exit 1; # Exit if fails.
fi

##########################################################################################
# Here is where the magic begins!
##########################################################################################

if mkdir ${LOCK_DIR} 2>/dev/null; then
  # If the ${LOCK_DIR} doesn't exist, then start working & store the ${PID_FILE}
  echo $$ > ${PID_FILE};

  for DOMAIN_NAME in "${DOMAIN_ARRAY[@]}"
  do
    # Process AWStats
    ${AWSTATS_SCRIPT} -config=${DOMAIN_NAME} -update >/dev/null & AWSTATS_PID=`jobs -l | awk '{print $2}'`;
    wait ${AWSTATS_PID};
  done

  # Delete the ${LOCK_DIR} & ${PID_FILE}
  rm -rf ${LOCK_DIR};
  exit;
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

