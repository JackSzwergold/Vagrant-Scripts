#!/bin/bash

##########################################################################################
#
# Provision NodeJS Regular (provision_nodejs_regular.sh) (c) by Jack Szwergold
#
# Provision NodeJS Regular is licensed under a
# Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.
#
# You should have received a copy of the license along with this
# work. If not, see <http://creativecommons.org/licenses/by-nc-sa/4.0/>.
#
# w: http://www.preworn.com
# e: me@preworn.com
#
# Created: 2016-01-27, js
# Version: 2016-01-27, js: creation
#          2016-01-30, js: development
#          2016-08-01, js: setting an extremely basic setup
#          2016-08-02, js: refining
#          2016-09-13, js: refining
#          2016-09-26, js: refining
#          2016-12-24, js: development
#
##########################################################################################

##########################################################################################
#  ____       _   _   _
# / ___|  ___| |_| |_(_)_ __   __ _ ___
# \___ \ / _ \ __| __| | '_ \ / _` / __|
#  ___) |  __/ |_| |_| | | | | (_| \__ \
# |____/ \___|\__|\__|_|_| |_|\__, |___/
#                             |___/
##########################################################################################

BASE_DIR=$(pwd);
# Output a provisioning message.
echo -e "\033[33;1mPROVISIONING: Base directory is: '${BASE_DIR}'.\033[0m";

BINS_DIR="deploy_items/bins";
CONFS_DIR="deploy_items/confs";
DBS_DIR="deploy_items/dbs";
if [ -n "${PROV_OS}" ]; then
  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: OS is: '${PROV_OS}'.\033[0m";
  BINS_DIR="deploy_items/bins/${PROV_OS}";
  CONFS_DIR="deploy_items/confs/${PROV_OS}";
  # DBS_DIR="deploy_items/dbs/${1}";
fi
# Output a provisioning message.
echo -e "\033[33;1mPROVISIONING: Binaries directory is: '${BINS_DIR}'.\033[0m";
echo -e "\033[33;1mPROVISIONING: Config directory is: '${CONFS_DIR}'.\033[0m";
echo -e "\033[33;1mPROVISIONING: DB directory is: '${DBS_DIR}'.\033[0m";

##########################################################################################
# Go into the config directory.
##########################################################################################

cd "${BASE_DIR}/${CONFS_DIR}";

##########################################################################################
#  _____                 _   _
# |  ___|   _ _ __   ___| |_(_) ___  _ __  ___
# | |_ | | | | '_ \ / __| __| |/ _ \| '_ \/ __|
# |  _|| |_| | | | | (__| |_| | (_) | | | \__ \
# |_|   \__,_|_| |_|\___|\__|_|\___/|_| |_|___/
#
##########################################################################################

##########################################################################################
# Configure repository stuff.
##########################################################################################
function configure_repository_stuff () {

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Setting the Debian frontend to non-interactive mode.\033[0m";

  # Adjusting the Debian frontend setting to non-interactive mode.
  export DEBIAN_FRONTEND=noninteractive;

} # configure_repository_stuff

##########################################################################################
# MeteorJS
##########################################################################################
function install_meteorjs () {

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Installing MeteorJS.\033[0m";

  # Go into the base directory.
  cd "${BASE_DIR}";

  # Install MeteorJS.
  # curl -sL https://install.meteor.com/?release=1.3.5.1 | sh >/dev/null 2>&1;
  curl -sL https://install.meteor.com/ | sh >/dev/null 2>&1;

} # install_meteorjs

##########################################################################################
#   ____                  ____          _
#  / ___|___  _ __ ___   / ___|___   __| | ___
# | |   / _ \| '__/ _ \ | |   / _ \ / _` |/ _ \
# | |__| (_) | | |  __/ | |__| (_) | (_| |  __/
#  \____\___/|_|  \___|  \____\___/ \__,_|\___|
#
##########################################################################################

# Install stuff.
configure_repository_stuff;

# Install MeteorJS.
hash meteor 2>/dev/null || { install_meteorjs; }
