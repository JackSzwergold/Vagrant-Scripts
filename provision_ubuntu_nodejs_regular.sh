#!/bin/bash

##########################################################################################
#
# Provision Ubuntu NodeJS Regular (provision_ubuntu_nodejs_regular.sh) (c) by Jack Szwergold
#
# Provision Ubuntu NodeJS Regular is licensed under a
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
echo -e "PROVISIONING: Base directory is: '${BASE_DIR}'.\n";

CONFIG_DIR="deployment_configs";
if [ -n "$1" ]; then CONFIG_DIR="${1}"; fi
echo -e "PROVISIONING: Config directory is: '${CONFIG_DIR}'.\n";

DB_DIR="deployment_dbs";
if [ -n "$2" ]; then DB_DIR="${2}"; fi
echo -e "PROVISIONING: DB directory is: '${DB_DIR}'.\n";

USER_NAME="vagrant";
if [ -n "$3" ]; then USER_NAME="${3}"; fi
echo -e "PROVISIONING: User name is: '${USER_NAME}'.\n";

MACHINE_NAME="vagrant";
if [ -n "$4" ]; then MACHINE_NAME="${4}"; fi
echo -e "PROVISIONING: Machine name is: '${MACHINE_NAME}'.\n";

HOST_NAME="vagrant.local";
if [ -n "$5" ]; then HOST_NAME="${5}"; fi
echo -e "PROVISIONING: Host name is: '${HOST_NAME}'.\n";

# Go into the config directory.
cd "${BASE_DIR}/${CONFIG_DIR}";

##########################################################################################
# Optional items.
##########################################################################################

# PROVISION_MYSQL=false;
# if [ -n "$5" ]; then PROVISION_MYSQL="${5}"; fi
# echo -e "PROVISIONING: MySQL provisioning: '${PROVISION_MYSQL}'.\n";

##########################################################################################
# Adjusting the Debian frontend setting to non-interactive mode.
##########################################################################################

echo -e "PROVISIONING: Setting the Debian frontend to non-interactive mode.\n"
export DEBIAN_FRONTEND=noninteractive;

##########################################################################################
#  _____                 _   _
# |  ___|   _ _ __   ___| |_(_) ___  _ __  ___
# | |_ | | | | '_ \ / __| __| |/ _ \| '_ \/ __|
# |  _|| |_| | | | | (__| |_| | (_) | | | \__ \
# |_|   \__,_|_| |_|\___|\__|_|\___/|_| |_|___/
#
##########################################################################################

##########################################################################################
# MeteorJS
##########################################################################################
function install_meteorjs () {

  echo -e "PROVISIONING: Installing MeteorJS.\n";

  # Go into the base directory.
  cd "${BASE_DIR}";

  # Install MeteorJS.
  # curl -sL https://install.meteor.com/ | sh;
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

# Install MeteorJS.
hash meteor 2>/dev/null || { install_meteorjs; }
