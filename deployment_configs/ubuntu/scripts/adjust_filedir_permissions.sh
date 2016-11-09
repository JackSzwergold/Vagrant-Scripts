#!/bin/bash

##########################################################################################
#
# Adjust FileDir Permissions (adjust_filedir_permissions.sh) (c) by Jack Szwergold
#
# Adjust FileDir Permissions is licensed under a
# Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.
#
# You should have received a copy of the license along with this
# work. If not, see <http://creativecommons.org/licenses/by-nc-sa/4.0/>. 
#
# w: http://www.preworn.com
# e: me@preworn.com
#
# Created: 2014-07-28, js
# Version: 2014-07-28, js: creation
#          2014-09-23, js: development
#
##########################################################################################

# Set the lock file & directory to prevent the script running on top of each other.
LOCK_NAME='ADJUST_FILEDIR_PERMISSIONS'
LOCK_DIR='/tmp/'"${LOCK_NAME}"'.lock'
PID_FILE="${LOCK_DIR}"'/'"${LOCK_NAME}"'.pid'

##########################################################################################
# Load the configuration file.
##########################################################################################

# Set the config file.
CONFIG_FILE="./adjust_filedir_permissions.cfg.sh"

# Checks if the base script directory exists.
if [ -f "${CONFIG_FILE}" ]; then
  source "${CONFIG_FILE}"
else
  echo $(date)" - [ERROR: Configuration file '${CONFIG_FILE}' not found. Script stopping.]" & LOGGER_PID=(`jobs -l | awk '{print $2}'`);
  wait ${LOGGER_PID}
  exit 1;
fi

##########################################################################################
# Here is where the magic begins!
##########################################################################################

if mkdir ${LOCK_DIR} 2>/dev/null; then

  # If the ${LOCK_DIR} doesn't exist, then start working & store the ${PID_FILE}
  echo $$ > ${PID_FILE}

  for DIRECTORY_NAME in "${DIRECTORY_ARRAY[@]}"
  do

    FULL_DIRECTORY_NAME=${DOCUMENT_ROOT}${DIRECTORY_NAME}'/'

    if [ -d ${FULL_DIRECTORY_NAME} ]; then

      # Adjust group ownership for all files & directories.
      find ${FULL_DIRECTORY_NAME} ! -group ${CHGRP_GROUP} -not -iwholename '*.git*' -print0 | xargs --no-run-if-empty -0 chgrp -f ${CHGRP_GROUP} -R ${DOCUMENT_ROOT}${DIRECTORY_NAME}'/' & GROUP_FIX_PID=(`jobs -l | awk '{print $2}'`);
      wait ${GROUP_FIX_PID};

      # Adjust permissions for directories.
      find ${FULL_DIRECTORY_NAME} -type d ! -perm ${CHMOD_DIR} -not -iwholename '*.git*' -print0 | xargs --no-run-if-empty -0 chmod -f ${CHMOD_DIR} >/dev/null & DIR_PERM_FIX_PID=(`jobs -l | awk '{print $2}'`);
      wait ${DIR_PERM_FIX_PID};

      # Adjust permissions for files.
      find ${FULL_DIRECTORY_NAME} -type f ! -perm ${CHMOD_FILE} -not -iwholename '*.git*' -print0 | xargs --no-run-if-empty -0 chmod -f ${CHMOD_FILE} >/dev/null & FILE_PERM_FIX_PID=(`jobs -l | awk '{print $2}'`);
      wait ${FILE_PERM_FIX_PID};

      # Adjust permissions for PERL files.
      find ${DOCUMENT_ROOT}${DIRECTORY_NAME}'/' -type f ! -perm ${CHMOD_EXEC_FILE} -iwholename '*.pl' -print0 | xargs --no-run-if-empty -0 chmod ${CHMOD_EXEC_FILE} >/dev/null & FILE_PERM_FIX_PID=(`jobs -l | awk '{print $2}'`);
      wait ${FILE_PERM_FIX_PID};

      # Adjust permissions for CGI files.
      find ${DOCUMENT_ROOT}${DIRECTORY_NAME}'/' -type f ! -perm ${CHMOD_EXEC_FILE} -iwholename '*.cgi' -print0 | xargs --no-run-if-empty -0 chmod ${CHMOD_EXEC_FILE} >/dev/null & FILE_PERM_FIX_PID=(`jobs -l | awk '{print $2}'`);
      wait ${FILE_PERM_FIX_PID};

      # Adjust permissions for SH (shell script) files.
      find ${DOCUMENT_ROOT}${DIRECTORY_NAME}'/' -type f ! -perm ${CHMOD_EXEC_FILE} -iwholename '*.sh' -print0 | xargs --no-run-if-empty -0 chmod ${CHMOD_EXEC_FILE} >/dev/null & FILE_PERM_FIX_PID=(`jobs -l | awk '{print $2}'`);
      wait ${FILE_PERM_FIX_PID};

      # Adjust permissions for files in directories named 'bin/'.
      # find `find ${DOCUMENT_ROOT}${DIRECTORY_NAME}'/' -type d \( -name "bin" -o -name "cgi-bin" \)` -maxdepth 1 -type f -print0 | xargs --no-run-if-empty -0 ls -la
      # find `find ${DOCUMENT_ROOT}${DIRECTORY_NAME}'/' -type d \( -name "bin" -o -name "cgi-bin" \)` -maxdepth 1 -type f -print0 | xargs --no-run-if-empty -0 chmod -R ${CHMOD_EXEC_FILE} >/dev/null & FILE_PERM_FIX_PID=(`jobs -l | awk '{print $2}'`);
      # wait ${FILE_PERM_FIX_PID};

    fi

  done

  rm -rf ${LOCK_DIR};
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
