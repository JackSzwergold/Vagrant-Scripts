#!/bin/bash

##########################################################################################
#
# Provision MongoDB (provision_mongo.sh) (c) by Jack Szwergold
#
# Provision MongoDB is licensed under a
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
# Output a provisioning message.
echo -e "\033[33;1mPROVISIONING: Base directory is: '${BASE_DIR}'.\033[0m";

BINS_DIR="deploy_items/bins";
if [ -n "$1" ]; then BINS_DIR="${1}"; fi
# Output a provisioning message.
echo -e "\033[33;1mPROVISIONING: Binaries directory is: '${BINS_DIR}'.\033[0m";

CONFS_DIR="deploy_items/confs";
if [ -n "$2" ]; then CONFS_DIR="${2}"; fi
# Output a provisioning message.
echo -e "\033[33;1mPROVISIONING: Config directory is: '${CONFS_DIR}'.\033[0m";

DBS_DIR="deploy_items/dbs";
if [ -n "$3" ]; then DBS_DIR="${3}"; fi
# Output a provisioning message.
echo -e "\033[33;1mPROVISIONING: DB directory is: '${DBS_DIR}'.\033[0m";

USER_NAME="vagrant";
if [ -n "$4" ]; then USER_NAME="${4}"; fi
# Output a provisioning message.
echo -e "\033[33;1mPROVISIONING: User name is: '${USER_NAME}'.\033[0m";

PASSWORD="vagrant";
if [ -n "$5" ]; then PASSWORD="${5}"; fi
# Output a provisioning message.
echo -e "\033[33;1mPROVISIONING: User password is: '${PASSWORD}'.\033[0m";

MACHINE_NAME="vagrant";
if [ -n "$6" ]; then MACHINE_NAME="${6}"; fi
# Output a provisioning message.
echo -e "\033[33;1mPROVISIONING: Machine name is: '${MACHINE_NAME}'.\033[0m";

HOST_NAME="vagrant.local";
if [ -n "$7" ]; then HOST_NAME="${7}"; fi
# Output a provisioning message.
echo -e "\033[33;1mPROVISIONING: Host name is: '${HOST_NAME}'.\033[0m";

##########################################################################################
# Optional items.
##########################################################################################

PROVISION_BASICS=false;
if [ -n "$8" ]; then PROVISION_BASICS="${8}"; fi
# Output a provisioning message.
echo -e "\033[33;1mPROVISIONING: Basics provisioning: '${PROVISION_BASICS}'.\033[0m";

##########################################################################################
# Go into the config directory.
##########################################################################################

cd "${BASE_DIR}/${CONFS_DIR}";

##########################################################################################
# Adjusting the Debian frontend setting to non-interactive mode.
##########################################################################################

# Output a provisioning message.
echo -e "\033[33;1mPROVISIONING: Setting the Debian frontend to non-interactive mode.\033[0m";
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
# User and Group
##########################################################################################
function configure_user_and_group () {

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Adjusting user and group related items.\033[0m";

  # Create the 'www-readwrite' group.
  sudo -E groupadd -f www-readwrite;

  # Set the user’s main group to be the 'www-readwrite' group.
  sudo -E usermod -g www-readwrite "${USER_NAME}";

  # Add the user to the 'www-readwrite' group:
  sudo -E adduser --quiet "${USER_NAME}" www-readwrite;

  # Changing the username/password combination.
  echo "${USER_NAME}:${PASSWORD}" | sudo -E sudo chpasswd;

} # configure_user_and_group

##########################################################################################
# Aptitude
##########################################################################################
function install_aptitude () {

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Install Aptitude.\033[0m";

  # Install Aptitude.
  sudo -E apt-get -y -q=2 install aptitude aptitude-common;

  # Update Aptitude.
  sudo -E aptitude -y -q=2 update;

} # install_aptitude

##########################################################################################
# Environment
##########################################################################################
function set_environment () {

  # Go into the config directory.
  cd "${BASE_DIR}/${CONFS_DIR}";

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Setting the selected editor.\033[0m";

  # Set the selected editor to be Nano.
  if [ ! -f "${BASE_DIR}/.selected_editor" ]; then
    echo 'SELECTED_EDITOR="/bin/nano"' > "${BASE_DIR}/.selected_editor";
    sudo -E chown -f "${USER_NAME}":www-readwrite "${BASE_DIR}/.selected_editor";
  fi

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Importing the crontab.\033[0m";

  # Importing the crontab.
  sudo -E crontab < "crontab.conf";

} # set_environment

##########################################################################################
# Timezone
##########################################################################################
function set_timezone () {

  if ! hash timedatectl 2>/dev/null; then

    # Set the timezone variables.
    TIMEZONE="America/New_York";
    TIMEZONE_PATH="/usr/share/zoneinfo";

    # Output a provisioning message.
    echo -e "\033[33;1mPROVISIONING: Setting timezone data manually.\033[0m";

    # Set the actual timezone via a symbolic link.
    sudo -E ln -f -s "${TIMEZONE_PATH}/${TIMEZONE}" "/etc/localtime";

  else

    # Set the timezone variables.
    TIMEZONE="America/New_York";

    # Output a provisioning message.
    echo -e "\033[33;1mPROVISIONING: Setting timezone data via 'timedatectl'.\033[0m";

    # Set the timezone.
    sudo -E timedatectl set-timezone "${TIMEZONE}";

    # Do this stuff to get NTP setup.
    sudo -E service ntp stop;
    sudo -E ntpd -gq;
    sudo service ntp start;
    # sudo -E update-rc.d -f ntp defaults;
    sudo -E update-rc.d -f ntp enable;

    # Set the NTP synchronized value to 'true'.
    sudo -E timedatectl set-ntp true;

  fi

} # set_timezone

##########################################################################################
# Sources List.
##########################################################################################
function configure_sources_list () {

  SOURCES_LIST="/etc/apt/sources.list";
  DEB_URL_PATTERN="^#.*deb.*partner$";
  if [ -f "${SOURCES_LIST}" ] && grep -E -q "${DEB_URL_PATTERN}" "/etc/apt/sources.list"; then

    # Output a provisioning message.
    echo -e "\033[33;1mPROVISIONING: Adjusting the sources list.\033[0m";

    # Adjust the sources list.
    sudo -E sed -i "/${DEB_URL_PATTERN}/s/^# //g" "/etc/apt/sources.list";

  fi

} # configure_sources_list

##########################################################################################
# Avahi
##########################################################################################
function install_avahi () {

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Avahi related stuff.\033[0m";

  # Install Avahi.
  sudo -E aptitude -y -q=2 install avahi-daemon avahi-utils;

} # install_avahi

##########################################################################################
# Sysstat
##########################################################################################
function install_sysstat () {

  # Go into the config directory.
  cd "${BASE_DIR}/${CONFS_DIR}";

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Sysstat related stuff.\033[0m";

  # Install Sysstat.
  sudo -E aptitude -y -q=2 install sysstat;

  # Copy the Sysstat config file in place and restart sysstat.
  if [ -f "sysstat/sysstat" ]; then
    sudo -E cp -f "sysstat/sysstat" "/etc/default/sysstat";
    sudo -E service sysstat restart;
  fi

} # install_sysstat

##########################################################################################
# Basic Tools
##########################################################################################
function install_basic_tools () {

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Installing a set of generic tools.\033[0m";

  # Install generic tools.
  sudo -E aptitude -y -q=2 install \
    dnsutils traceroute nmap bc htop finger curl whois rsync lsof \
    iftop figlet lynx mtr-tiny iperf nload zip unzip attr sshpass \
    dkms mc elinks dos2unix p7zip-full nfs-common \
    slurm sharutils uuid-runtime quota pv trickle ntp \
    virtualbox-dkms;

} # install_basic_tools

##########################################################################################
# Locate
##########################################################################################
function install_locate () {

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Installing the locate tool and updating the database.\033[0m";

  # Install Locate.
  sudo -E aptitude -y -q=2 install mlocate;

  # Update Locate.
  sudo -E updatedb;

} # install_locate

##########################################################################################
# Compiler
##########################################################################################
function install_compiler () {

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Installing the core compiler tools.\033[0m";

  # Install the core compiler and build tools.
  sudo -E aptitude -y -q=2 install build-essential libtool automake m4;

} # install_compiler

##########################################################################################
# Git
##########################################################################################
function install_git () {

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Installing Git and related stuff.\033[0m";

  # Purge any already installed version of Git.
  sudo -E aptitude -y -q=2 purge git git-core subversion git-svn;

  # Now install Git via PPA.
  sudo -E aptitude -y -q=2 install python-software-properties;
  sudo -E add-apt-repository -y ppa:git-core/ppa;
  sudo -E aptitude -y -q=2 update;
  sudo -E aptitude -y -q=2 install git git-core subversion git-svn;

} # install_git

##########################################################################################
# Postfix and Mail
##########################################################################################
function install_postfix () {

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Installing Postfix and related mail stuff.\033[0m";

  # Install postfix and general mail stuff.
  sudo -E debconf-set-selections <<< "postfix postfix/mailname string ${HOST_NAME}";
  sudo -E debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'";
  sudo -E aptitude -y -q=2 install postfix mailutils >/dev/null 2>&1;

} # install_postfix

##########################################################################################
# Setting the 'login.defs' config file.
##########################################################################################
function configure_login_defs () {

  # Go into the config directory.
  cd "${BASE_DIR}/${CONFS_DIR}";

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Setting the 'login.defs' config file.\033[0m";

  # Copy the 'login.defs' file in place.
  sudo -E cp -f "system/login.defs" "/etc/login.defs";

} # configure_login_defs

##########################################################################################
# Setting the 'common-session' config file.
##########################################################################################
function configure_common_session () {

  # Go into the config directory.
  cd "${BASE_DIR}/${CONFS_DIR}";

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Setting the 'common-session' config file.\033[0m";

  # Copy the 'login.defs' file in place.
  sudo -E cp -f "system/common-session" "/etc/pam.d/common-session";

} # configure_common_session

##########################################################################################
# SSH configure.
##########################################################################################
function configure_ssh () {

  # Go into the config directory.
  cd "${BASE_DIR}/${CONFS_DIR}";

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Setting the SSH config file.\033[0m";

  # Copy the 'login.defs' file in place.
  sudo -E cp -f "ssh/ssh_config" "/etc/ssh/ssh_config";

} # configure_ssh

##########################################################################################
# MOTD
##########################################################################################
function configure_motd () {

  # Go into the config directory.
  cd "${BASE_DIR}/${CONFS_DIR}";

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Setting the MOTD banner.\033[0m";

  # Install figlet.
  sudo -E aptitude -y -q=2 install figlet;

  # Set the server login banner with figlet.
  MOTD_PATH="/etc/motd";
  echo "$(figlet ${MACHINE_NAME} | head -n -1).local" > "${MOTD_PATH}";
  echo "" >> "${MOTD_PATH}";

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Disabling MOTD scripts.\033[0m";

  # Disable these MOTD scripts.
  sudo -E chmod -f -x "/etc/update-motd.d/50-landscape-sysinfo";
  sudo -E chmod -f -x "/etc/update-motd.d/51-cloudguest";
  sudo -E chmod -f -x "/etc/update-motd.d/90-updates-available";
  sudo -E chmod -f -x "/etc/update-motd.d/91-release-upgrade";
  sudo -E chmod -f -x "/etc/update-motd.d/95-hwe-eol";
  sudo -E chmod -f -x "/etc/update-motd.d/98-cloudguest";

} # configure_motd

##########################################################################################
# Monit
##########################################################################################
function install_monit () {

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Monit related stuff.\033[0m";

  # Install Monit.
  sudo -E RUNLEVEL=1 aptitude -y -q=2 install monit;

  # Run these commands to prevent Monit from coming up on reboot.
  sudo -E service monit stop;
  sudo -E update-rc.d -f monit remove;

} # install_monit

##########################################################################################
# Monit config.
##########################################################################################
function configure_monit () {

  # Go into the config directory.
  cd "${BASE_DIR}/${CONFS_DIR}";

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Installing the Monit configs.\033[0m";

  sudo -E cp -f "monit/monitrc" "/etc/monit/monitrc";
  sudo -E cp -f "monit/node_app.conf" "/etc/monit/conf.d/node_app.conf";

  # Restart Monit.
  sudo -E service monit restart;

  # Run these commands to prevent Monit from coming up on reboot.
  sudo -E service monit stop;
  sudo -E update-rc.d -f monit remove;

} # configure_monit

##########################################################################################
# MongoDB 2.6
##########################################################################################
function install_mongo26 () {

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Installing MongoDB related items.\033[0m";

  # Go into the base directory.
  cd "${BASE_DIR}";

  # Add the official MongoDB repository and install MongoDB.
  curl -ss -O -L "http://docs.mongodb.org/10gen-gpg-key.asc" & CURL_PID=(`jobs -l | awk '{print $2}'`);
  wait ${CURL_PID};
  sudo apt-key add "10gen-gpg-key.asc";
  echo "deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen" | sudo tee "/etc/apt/sources.list.d/mongodb.list" & ADD_REPO_PID=(`jobs -l | awk '{print $2}'`);
  wait ${ADD_REPO_PID};
  sudo -E rm -rf "/var/lib/apt/lists/partial/";
  sudo -E aptitude -y -q=2 update;
  sudo -E aptitude -y -q=2 clean;
  sudo -E aptitude -y -q=2 install mongodb-org=2.6.12 mongodb-org-server=2.6.12 mongodb-org-shell=2.6.12 mongodb-org-mongos=2.6.12 mongodb-org-tools=2.6.12;

  # Pin the currently installed version of MongoDB to ensure no accidental upgrades happen.
  echo "mongodb-org hold" | sudo dpkg --set-selections;
  echo "mongodb-org-server hold" | sudo dpkg --set-selections;
  echo "mongodb-org-shell hold" | sudo dpkg --set-selections;
  echo "mongodb-org-mongos hold" | sudo dpkg --set-selections;
  echo "mongodb-org-tools hold" | sudo dpkg --set-selections;

} # install_mongo26

##########################################################################################
# MongoDB 3.4
##########################################################################################
function install_mongo34 () {

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Installing MongoDB related items.\033[0m";

  # Go into the base directory.
  cd "${BASE_DIR}";

  # Add the official MongoDB repository and install MongoDB.
  curl -ss -O -L "https://www.mongodb.org/static/pgp/server-3.4.asc" & CURL_PID=(`jobs -l | awk '{print $2}'`);
  wait ${CURL_PID};
  sudo apt-key add "server-3.4.asc";
  echo "deb [ arch=amd64 ] http://repo.mongodb.org/apt/ubuntu trusty/mongodb-org/3.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.4.list & ADD_REPO_PID=(`jobs -l | awk '{print $2}'`);
  wait ${ADD_REPO_PID};
  sudo -E rm -rf "/var/lib/apt/lists/partial/";
  sudo -E aptitude -y -q=2 update;
  sudo -E aptitude -y -q=2 clean;
  sudo -E aptitude -y -q=2 install mongodb-org=3.4.9 mongodb-org-server=3.4.9 mongodb-org-shell=3.4.9 mongodb-org-mongos=3.4.9 mongodb-org-tools=3.4.9;

  # Pin the currently installed version of MongoDB to ensure no accidental upgrades happen.
  echo "mongodb-org hold" | sudo dpkg --set-selections;
  echo "mongodb-org-server hold" | sudo dpkg --set-selections;
  echo "mongodb-org-shell hold" | sudo dpkg --set-selections;
  echo "mongodb-org-mongos hold" | sudo dpkg --set-selections;
  echo "mongodb-org-tools hold" | sudo dpkg --set-selections;

} # install_mongo34

##########################################################################################
# Configure MongoDB
##########################################################################################
function configure_mongo () {

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Configuring MongoDB related items.\033[0m";

  # Mongo 2.x: Comment out the 'bind_ip' line to enable network connections outside of 'localhost'.
  sudo -E sed -i 's/bind_ip = 127.0.0.1/#bind_ip = 127.0.0.1/g' "/etc/mongod.conf";

  # Mongo 3.x: Comment out the 'bindIp' line to enable network connections outside of 'localhost'.
  sudo -E sed -i 's/ \+bindIp: 127.0.0.1/  #bindIp: 127.0.0.1/g' "/etc/mongod.conf";

  # Restart the Mongo instance to get the new config loaded.
  sudo -E service mongod restart & RESTART_PID=(`jobs -l | awk '{print $2}'`);
  wait ${RESTART_PID};

  # Go into the base directory.
  cd "${BASE_DIR}";

  # Import any databases that were sent over as the part of the provisioning process.
  if [ -d "${DBS_DIR}" ]; then
    find "${DBS_DIR}" -type f -name "*.bson" |\
      while read db_backup_path
      do
        if [ -f "${db_backup_path}" ]; then
          db_dirname=$(dirname "${db_backup_path}");
          mongo_db=$(basename "${db_dirname}");
          # Output a provisioning message.
          echo -e "\033[33;1mPROVISIONING: Restoring the '${mongo_db}' MongoDB database.\033[0m";
          mongo --quiet "${mongo_db}" --eval "db.dropDatabase()";
          mongorestore --quiet "${db_backup_path}";
        else
          exit 1;
        fi
      done
  fi

} # configure_mongo

##########################################################################################
# Update the locate database.
##########################################################################################
function update_locate_db () {

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Updating the locate database.\033[0m";

  sudo -E updatedb;

} # update_locate_db

##########################################################################################
#   ____                  ____          _
#  / ___|___  _ __ ___   / ___|___   __| | ___
# | |   / _ \| '__/ _ \ | |   / _ \ / _` |/ _ \
# | |__| (_) | | |  __/ | |__| (_) | (_| |  __/
#  \____\___/|_|  \___|  \____\___/ \__,_|\___|
#
##########################################################################################

# Install install stuff.
configure_user_and_group;
install_aptitude;
set_environment;
configure_sources_list;
hash sar 2>/dev/null || { install_sysstat; }
hash updatedb 2>/dev/null || { install_locate; }
configure_motd;

# Get the basics set.
if [ "${PROVISION_BASICS}" = true ]; then

  install_basic_tools;
  hash libtool 2>/dev/null || { install_compiler; }
  if ! grep -q -s "git-core" "/etc/apt/sources.list" "/etc/apt/sources.list.d/"*; then install_git; fi
  hash postfix 2>/dev/null || { install_postfix; }
  # if [ -f "system/login.defs" ] && [ -f "/etc/login.defs" ]; then configure_login_defs; fi
  # if [ -f "system/common-session" ] && [ -f "/etc/pam.d/common-session" ]; then configure_common_session; fi
  # if [ -f "ssh/ssh_config" ] && [ -f "/etc/ssh/ssh_config" ]; then configure_ssh; fi

fi

# Timezone and related stuff.
set_timezone;

# Avahi
hash avahi-daemon 2>/dev/null || { install_avahi; }

# Install and configure MongoDB.
hash mongo 2>/dev/null && hash mongod 2>/dev/null || {
  install_mongo26;
  # install_mongo34;
  configure_mongo;
}

# Monit
# hash monit 2>/dev/null || { install_monit; }
# if [ -f "${BASE_DIR}/${CONFS_DIR}/monit/monitrc" ]; then configure_monit; fi

# Update the locate database.
update_locate_db;
