#!/bin/bash

##########################################################################################
#
# Provision ElasticSearch Ubuntu (provision_elasticsearch_ubuntu.sh) (c) by Jack Szwergold
#
# Provision ElasticSearch Ubuntu is licensed under a
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
echo -e "\033[33;1mPROVISIONING: Base directory is: '${BASE_DIR}'.\033[0m\n";

CONFIG_DIR="deployment_configs";
if [ -n "$1" ]; then CONFIG_DIR="${1}"; fi
# Output a provisioning message.
echo -e "\033[33;1mPROVISIONING: Config directory is: '${CONFIG_DIR}'.\033[0m\n";

DB_DIR="deployment_dbs";
if [ -n "$2" ]; then DB_DIR="${2}"; fi
# Output a provisioning message.
echo -e "\033[33;1mPROVISIONING: DB directory is: '${DB_DIR}'.\033[0m\n";

BINARIES_DIR="deployment_binaries";
if [ -n "$3" ]; then BINARIES_DIR="${3}"; fi
# Output a provisioning message.
echo -e "\033[33;1mPROVISIONING: Binaries directory is: '${BINARIES_DIR}'.\033[0m\n";

USER_NAME="vagrant";
if [ -n "$4" ]; then USER_NAME="${4}"; fi
# Output a provisioning message.
echo -e "\033[33;1mPROVISIONING: User name is: '${USER_NAME}'.\033[0m\n";

PASSWORD="vagrant";
if [ -n "$5" ]; then PASSWORD="${5}"; fi
# Output a provisioning message.
echo -e "\033[33;1mPROVISIONING: User password is: '${PASSWORD}'.\033[0m\n";

MACHINE_NAME="vagrant";
if [ -n "$6" ]; then MACHINE_NAME="${6}"; fi
# Output a provisioning message.
echo -e "\033[33;1mPROVISIONING: Machine name is: '${MACHINE_NAME}'.\033[0m\n";

HOST_NAME="vagrant.local";
if [ -n "$7" ]; then HOST_NAME="${7}"; fi
# Output a provisioning message.
echo -e "\033[33;1mPROVISIONING: Host name is: '${HOST_NAME}'.\033[0m\n";

##########################################################################################
# Go into the config directory.
##########################################################################################

cd "${BASE_DIR}/${CONFIG_DIR}";

##########################################################################################
# Adjusting the Debian frontend setting to non-interactive mode.
##########################################################################################

# Output a provisioning message.
echo -e "\033[33;1mPROVISIONING: Setting the Debian frontend to non-interactive mode.\033[0m\n";
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
  echo -e "\033[33;1mPROVISIONING: Adjusting user and group related items.\033[0m\n";

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

  echo -e "\033[33;1mPROVISIONING: Install Aptitude.\033[0m\n";

  # Install Aptitude.
  sudo -E apt install -y -q=2 aptitude;

} # install_aptitude

##########################################################################################
# Environment
##########################################################################################
function set_environment () {

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Setting the selected editor.\033[0m\n";

  # Set the selected editor to be Nano.
  if [ ! -f "${BASE_DIR}/.selected_editor" ]; then
    echo 'SELECTED_EDITOR="/bin/nano"' > "${BASE_DIR}/.selected_editor";
    sudo -E chown -f "${USER_NAME}":www-readwrite "${BASE_DIR}/.selected_editor";
  fi

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Importing the crontab.\033[0m\n";

  # Importing the crontab.
  sudo -E crontab < "crontab.conf";

} # set_environment

##########################################################################################
# Timezone
##########################################################################################
function set_timezone () {

  TIMEZONE="America/New_York";
  TIMEZONE_PATH="/etc/timezone";
  if [ "${TIMEZONE}" != $(cat "${TIMEZONE_PATH}") ]; then

    # Output a provisioning message.
    echo -e "\033[33;1mPROVISIONING: Setting timezone data.\033[0m\n";

    sudo -E echo "${TIMEZONE}" > "${TIMEZONE_PATH}";
    sudo -E dpkg-reconfigure -f noninteractive tzdata 2>/dev/null;

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
    echo -e "\033[33;1mPROVISIONING: Adjusting the sources list.\033[0m\n";

    # Adjust the sources list.
    sudo -E sed -i "/${DEB_URL_PATTERN}/s/^# //g" "/etc/apt/sources.list";

  fi

} # configure_sources_list

##########################################################################################
# Avahi
##########################################################################################
function install_avahi () {

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Avahi related stuff.\033[0m\n";

  # Install Avahi.
  sudo -E aptitude install -y -q=2 avahi-daemon avahi-utils;

} # install_avahi

##########################################################################################
# Sysstat
##########################################################################################
function install_sysstat () {

  # Go into the config directory.
  cd "${BASE_DIR}/${CONFIG_DIR}";

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Sysstat related stuff.\033[0m\n";

  # Install Sysstat.
  sudo -E aptitude install -y -q=2 sysstat;

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
  echo -e "\033[33;1mPROVISIONING: Installing a set of generic tools.\033[0m\n";

  # Install generic tools.
  sudo -E aptitude install -y -q=2 \
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

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Installing the locate tool and updating the database.\033[0m\n";

  # Install Locate.
  sudo -E aptitude install -y -q=2 mlocate;

  # Update Locate.
  sudo -E updatedb;

} # install_locate

##########################################################################################
# Compiler
##########################################################################################
function install_compiler () {

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Installing the core compiler tools.\033[0m\n";

  # Install the core compiler and build tools.
  sudo -E aptitude install -y -q=2 build-essential libtool;

} # install_compiler

##########################################################################################
# Git
##########################################################################################
function install_git () {

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Installing Git and related stuff.\033[0m\n";

  # Purge any already installed version of Git.
  sudo -E aptitude purge -y -q git git-core subversion git-svn;

  # Now install Git via PPA.
  sudo -E aptitude install -y -q=2 python-software-properties;
  sudo -E add-apt-repository -y ppa:git-core/ppa;
  sudo -E aptitude update -y -q=2;
  sudo -E aptitude install -y -q=2 git git-core subversion git-svn;

} # install_git

##########################################################################################
# MOTD
##########################################################################################
function configure_motd () {

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Setting the MOTD banner.\033[0m\n";

  # Install figlet.
  sudo -E aptitude install -y -q=2 figlet;

  # Set the server login banner with figlet.
  # MOTD_PATH="/etc/motd.tail";
  MOTD_PATH="/etc/motd";
  # echo "$(figlet ${MACHINE_NAME^} | head -n -1).local" > "${MOTD_PATH}";
  echo "$(figlet ${MACHINE_NAME} | head -n -1).local" > "${MOTD_PATH}";
  echo "" >> "${MOTD_PATH}";

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Disabling MOTD scripts.\033[0m\n";

  # Disable these MOTD scripts.
  sudo -E chmod -f -x "/etc/update-motd.d/50-landscape-sysinfo";
  sudo -E chmod -f -x "/etc/update-motd.d/51-cloudguest";
  sudo -E chmod -f -x "/etc/update-motd.d/90-updates-available";
  sudo -E chmod -f -x "/etc/update-motd.d/91-release-upgrade";
  sudo -E chmod -f -x "/etc/update-motd.d/95-hwe-eol";
  sudo -E chmod -f -x "/etc/update-motd.d/98-cloudguest";

} # configure_motd

##########################################################################################
# Java
##########################################################################################
function install_java () {

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Installing Java.\033[0m\n";

  # Now install Java via PPA.
  sudo -E aptitude install -y -q=2 python-software-properties debconf-utils;

  sudo -E add-apt-repository ppa:webupd8team/java;
  sudo -E aptitude update -y -q=2;
  echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | sudo debconf-set-selections;
  sudo -E aptitude install -y -q=2 oracle-java8-installer oracle-java8-set-default;

  # Now install Java via PPA.
  echo "JAVA_HOME=/usr/lib/jvm/java-8-oracle/jre" >> "/etc/environment";

} # install_java

##########################################################################################
# Install Elasticsearch
##########################################################################################
function install_elasticsearch () {

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Installing ElasticSearch related items.\033[0m\n";

  # Import the public key used by the package management system:
  wget -qO - http://packages.elasticsearch.org/GPG-KEY-elasticsearch | sudo apt-key add -;
  echo 'deb http://packages.elasticsearch.org/elasticsearch/1.7/debian stable main' | sudo tee /etc/apt/sources.list.d/elasticsearch.list;
  sudo -E aptitude update -y -q=2;
  sudo -E RUNLEVEL=1 aptitude install -y -q=2 elasticsearch;

  # Set ElasticSearch to be able to come up on reboot.
  sudo update-rc.d elasticsearch defaults 95 10;

  # Restart ElasticSearch.
  sudo -E service elasticsearch restart;

} # install_elasticsearch

##########################################################################################
# Configure Elasticsearch
##########################################################################################
function configure_elasticsearch () {

  # Go into the config directory.
  cd "${BASE_DIR}/${CONFIG_DIR}";

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Configuring ElasticSearch related items.\033[0m\n";

  # Copy the Elasticsearch config file in place and restart sysstat.
  if [ -f "elasticsearch/elasticsearch.yml" ]; then
    sudo -E cp -f "elasticsearch/elasticsearch.yml" "/etc/elasticsearch/elasticsearch.yml";
    sudo -E service elasticsearch restart;
  fi

} # configure_elasticsearch

##########################################################################################
# Update the locate database.
##########################################################################################
function update_locate_db () {

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Updating the locate database.\033[0m\n";

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

configure_user_and_group;
install_aptitude;
set_environment;
set_timezone;
configure_sources_list;
hash avahi-daemon 2>/dev/null || { install_avahi; }
hash sar 2>/dev/null || {  install_sysstat; }
hash updatedb 2>/dev/null || { install_locate; }
configure_motd;
install_basic_tools;
hash libtool 2>/dev/null || { install_compiler; }
if ! grep -q -s "git-core" "/etc/apt/sources.list" "/etc/apt/sources.list.d/"*; then install_git; fi

# Install configure Java.
install_java;

# Install configure ElasticSearch.
install_elasticsearch;
configure_elasticsearch;

# Update the locate database.
update_locate_db;
