#!/bin/bash

##########################################################################################
#
# Provision NodeJS Ubuntu 16.04 (provision_nodejs_ubuntu_1604.sh) (c) by Jack Szwergold
#
# Provision NodeJS Ubuntu 16.04 is licensed under a
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

PASSWORD="vagrant";
if [ -n "$4" ]; then PASSWORD="${4}"; fi
echo -e "PROVISIONING: User password is: '${PASSWORD}'.\n";

MACHINE_NAME="vagrant";
if [ -n "$5" ]; then MACHINE_NAME="${5}"; fi
echo -e "PROVISIONING: Machine name is: '${MACHINE_NAME}'.\n";

HOST_NAME="vagrant.local";
if [ -n "$6" ]; then HOST_NAME="${6}"; fi
echo -e "PROVISIONING: Host name is: '${HOST_NAME}'.\n";

##########################################################################################
# Go into the config directory.
##########################################################################################

cd "${BASE_DIR}/${CONFIG_DIR}";

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
# User and Group
##########################################################################################
function configure_user_and_group () {

  echo -e "PROVISIONING: Adjusting user and group related items.\n";

  # Create the 'www-readwrite' group.
  sudo -E groupadd -f www-readwrite;

  # Set the user’s main group to be the 'www-readwrite' group.
  sudo -E usermod -g www-readwrite "${USER_NAME}";

  # Add the user to the 'www-readwrite' group:
  sudo -E adduser --quiet "${USER_NAME}" www-readwrite;

  # Changing the username/password combination.
  echo "${USER_NAME}:${PASSWORD}" | sudo -E sudo chpasswd

} # configure_user_and_group

##########################################################################################
# Aptitude
##########################################################################################
function install_aptitude () {

  echo -e "PROVISIONING: Install Aptitude.\n";

  # Install Aptitude.
  sudo -E apt install -y -q aptitude;

} # install_aptitude

##########################################################################################
# Environment
##########################################################################################
function set_environment () {

  echo -e "PROVISIONING: Setting the selected editor.\n";

  # Set the selected editor to be Nano.
  if [ ! -f "${BASE_DIR}/.selected_editor" ]; then
    echo 'SELECTED_EDITOR="/bin/nano"' > "${BASE_DIR}/.selected_editor";
    sudo -E chown -f "${USER_NAME}":www-readwrite "${BASE_DIR}/.selected_editor";
  fi

  echo -e "PROVISIONING: Importing the crontab.\n";

  # Go into the config directory.
  cd "${BASE_DIR}/${CONFIG_DIR}";

  # Importing the crontab.
  sudo -E crontab < "crontab.conf";

} # set_environment

##########################################################################################
# Timezone
##########################################################################################
function set_timezone () {

  TIMEZONE="America/New_York";

  echo -e "PROVISIONING: Setting timezone data.\n";

  sudo -E timedatectl set-timezone "${TIMEZONE}";

} # set_timezone

##########################################################################################
# Sources List.
##########################################################################################
function configure_sources_list () {

  SOURCES_LIST="/etc/apt/sources.list";
  DEB_URL_PATTERN="^#.*deb.*partner$";
  if [ -f "${SOURCES_LIST}" ] && grep -E -q "${DEB_URL_PATTERN}" "/etc/apt/sources.list"; then

    echo -e "PROVISIONING: Adjusting the sources list.\n";

    # Adjust the sources list.
    sudo -E sed -i "/${DEB_URL_PATTERN}/s/^# //g" "/etc/apt/sources.list";

  fi

} # configure_sources_list

##########################################################################################
# Avahi
##########################################################################################
function install_avahi () {

  echo -e "PROVISIONING: Avahi related stuff.\n";

  # Install Avahi.
  sudo -E aptitude install -y -q avahi-daemon avahi-utils;

} # install_avahi

##########################################################################################
# Sysstat
##########################################################################################
function install_sysstat () {

  echo -e "PROVISIONING: Sysstat related stuff.\n";

  # Install Sysstat.
  sudo -E aptitude install -y -q sysstat;

  # Go into the config directory.
  cd "${BASE_DIR}/${CONFIG_DIR}";

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

  echo -e "PROVISIONING: Installing a set of generic tools.\n";

  # Install generic tools.
  sudo -E aptitude install -y -q \
    dnsutils traceroute nmap bc htop finger curl whois rsync lsof \
    iftop figlet lynx mtr-tiny iperf nload zip unzip attr sshpass \
    dkms mc elinks ntp dos2unix p7zip-full nfs-common \
    slurm sharutils uuid-runtime chkconfig quota pv trickle apachetop \
    virtualbox-dkms;

} # install_basic_tools

##########################################################################################
# Locate
##########################################################################################
function install_locate () {

  echo -e "PROVISIONING: Installing the locate tool and updating the database.\n";

  # Install Locate.
  sudo -E aptitude install -y -q mlocate;

  # Update Locate.
  sudo -E updatedb;

} # install_locate

##########################################################################################
# Compiler
##########################################################################################
function install_compiler () {

  echo -e "PROVISIONING: Installing the core compiler tools.\n";

  # Install the core compiler and build tools.
  sudo -E aptitude install -y -q build-essential libtool;

} # install_compiler

##########################################################################################
# Git
##########################################################################################
function install_git () {

  echo -e "PROVISIONING: Installing Git and related stuff.\n";

  # Purge any already installed version of Git.
  sudo -E aptitude purge -y -q git git-core subversion git-svn;

  # Now install Git via PPA.
  sudo -E aptitude install -y -q python-software-properties;
  sudo -E add-apt-repository -y ppa:git-core/ppa;
  sudo -E aptitude update -y -q;
  sudo -E aptitude install -y -q git git-core subversion git-svn;

} # install_git

##########################################################################################
# MOTD
##########################################################################################
function configure_motd () {

  echo -e "PROVISIONING: Setting the MOTD banner.\n";

  # Install figlet.
  sudo -E aptitude install -y -q figlet;

  # Set the server login banner with figlet.
  MOTD_PATH="/etc/motd";
  echo "$(figlet ${MACHINE_NAME} | head -n -1).local" > "${MOTD_PATH}";
  echo "" >> "${MOTD_PATH}";

  echo -e "PROVISIONING: Disabling MOTD scripts.\n";

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

  echo -e "PROVISIONING: Monit related stuff.\n";

  # Install Monit.
  sudo -E RUNLEVEL=1 aptitude install -y -q monit;

  # Run these commands to prevent Monit from coming up on reboot.
  sudo -E service monit stop;
  sudo -E update-rc.d -f monit remove;

} # install_monit

##########################################################################################
# Monit config.
##########################################################################################
function configure_monit () {

  echo -e "PROVISIONING: Installing the Monit configs.\n";

  # Go into the config directory.
  cd "${BASE_DIR}/${CONFIG_DIR}";

  sudo -E cp -f "monit/monitrc" "/etc/monit/monitrc";
  sudo -E cp -f "monit/node_app.conf" "/etc/monit/conf.d/node_app.conf";

  # Restart Monit.
  sudo -E service monit restart;

  # Run these commands to prevent Monit from coming up on reboot.
  sudo -E service monit stop;
  sudo -E update-rc.d -f monit remove;

} # configure_monit

##########################################################################################
# NodeJS and NPM
##########################################################################################
function install_nodejs () {

  echo -e "PROVISIONING: Installing NodeJS and NPM related stuff.\n";

  # Go into the base directory.
  cd "${BASE_DIR}";

  # Purge any already installed version of NodeJS and NPM.
  sudo -E aptitude purge -y -q node npm;

  # Now install NodeJS and NPM via PPA.
  sudo -E aptitude install -y -q python-software-properties;
  # curl -sL https://deb.nodesource.com/setup_6.x | sudo bash - ;
  # curl -sL https://deb.nodesource.com/setup_5.x | sudo bash - ;
  # curl -sL https://deb.nodesource.com/setup_4.x | sudo bash - ;
  # curl -sL https://deb.nodesource.com/setup_0.10 | sudo bash - ;
  curl -sL https://deb.nodesource.com/setup_4.x | sudo bash - ;
  sudo -E aptitude update -y -q;
  sudo -E aptitude install -y -q nodejs;

  # Install 'forever' and 'userdown' for Upstart script support.
  sudo -E npm install -g --no-optional forever 2>&1 >/dev/null;
  sudo -E npm install -g --no-optional userdown 2>&1 >/dev/null;

} # install_nodejs

##########################################################################################
# Deployment directories.
##########################################################################################
function set_application_deployment_directories () {

  echo -e "PROVISIONING: Creating the web code deployment directories.\n";

  sudo -E mkdir -p "/opt/webapps/"{builds,configs,deployed_code};
  sudo -E chown -f -R "${USER_NAME}":www-readwrite "/opt/webapps";
  sudo -E chmod -f -R 775 "/opt/webapps";
  sudo -E chmod g+s "/opt/webapps";
  sudo -E chmod g+s "/opt/webapps/"{builds,configs,deployed_code};

} # set_application_deployment_directories

##########################################################################################
# Update the locate database.
##########################################################################################
function update_locate_db () {

  echo -e "PROVISIONING: Updating the locate database.\n";

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

# sudo -E ntpdate -u ntp.ubuntu.com;
configure_user_and_group;
install_aptitude;
set_environment;
set_timezone;
configure_sources_list;
hash avahi-daemon 2>/dev/null || { install_avahi; }
hash sar 2>/dev/null || { install_sysstat; }
hash updatedb 2>/dev/null || { install_locate; }
configure_motd;
install_basic_tools;
hash libtool 2>/dev/null || { install_compiler; }
if ! grep -q -s "git-core" "/etc/apt/sources.list" "/etc/apt/sources.list.d/"*; then install_git; fi

# Install configure NodeJS and NPM.
hash node 2>/dev/null || { install_nodejs; }

# Setup the NodeJS application deployment environment.
if [ ! -d "/opt/webapps" ]; then set_application_deployment_directories; fi

# Monit
hash monit 2>/dev/null || { install_monit; }
if [ -f "${BASE_DIR}/${CONFIG_DIR}/monit/monitrc" ]; then configure_monit; fi

# Update the locate database.
update_locate_db;