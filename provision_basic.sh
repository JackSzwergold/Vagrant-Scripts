#!/bin/bash

##########################################################################################
#
# Provision (provision.sh) (c) by Jack Szwergold
#
# Provision is licensed under a
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

USER_NAME="vagrant";
if [ -n "$2" ]; then USER_NAME="${2}"; fi
echo -e "PROVISIONING: User name is: '${USER_NAME}'.\n";

MACHINE_NAME="vagrant";
if [ -n "$3" ]; then MACHINE_NAME="${3}"; fi
echo -e "PROVISIONING: Machine name is: '${MACHINE_NAME}'.\n";

HOST_NAME="vagrant.local";
if [ -n "$4" ]; then HOST_NAME="${4}"; fi
echo -e "PROVISIONING: Host name is: '${HOST_NAME}'.\n";

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

} # configure_user_and_group

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

    echo -e "PROVISIONING: Setting timezone data.\n";

    # debconf-set-selections <<< "tzdata tzdata/Areas select America"
    # debconf-set-selections <<< "tzdata tzdata/Zones/America select New_York"
    # sudo -E dpkg-reconfigure tzdata
    sudo -E echo "${TIMEZONE}" > "${TIMEZONE_PATH}";
    sudo -E dpkg-reconfigure -f noninteractive tzdata;

  fi

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
  sudo -E aptitude install -y --assume-yes -q avahi-daemon avahi-utils;

} # install_avahi

##########################################################################################
# Sysstat
##########################################################################################
function install_sysstat () {

  echo -e "PROVISIONING: Sysstat related stuff.\n";

  # Install Sysstat.
  sudo -E aptitude install -y --assume-yes -q sysstat;

  # Copy the Sysstat config file in place and restart sysstat.
  if [ -f "sysstat/sysstat" ]; then
    sudo -E cp -f "sysstat/sysstat" "/etc/default/sysstat";
    sudo -E service sysstat restart;
  fi

} # install_sysstat

##########################################################################################
# Locate
##########################################################################################
function install_locate () {

  echo -e "PROVISIONING: Installing the locate tool and updating the database.\n";

  # Install Locate.
  sudo -E aptitude install -y --assume-yes -q mlocate;

  # Update Locate.
  sudo -E updatedb;

} # install_locate

##########################################################################################
# Compiler
##########################################################################################
function install_compiler () {

  echo -e "PROVISIONING: Installing the core compiler tools.\n";

  # Install the core compiler and build tools.
  sudo -E aptitude install -y --assume-yes -q build-essential libtool;

} # install_compiler

##########################################################################################
# Git
##########################################################################################
function install_git () {

  echo -e "PROVISIONING: Installing Git and related stuff.\n";

  # Purge any already installed version of Git.
  sudo -E aptitude purge -y --assume-yes -q git git-core subversion git-svn;

  # Now install Git via PPA.
  sudo -E aptitude install -y --assume-yes -q python-software-properties;
  sudo -E add-apt-repository -y ppa:git-core/ppa;
  sudo -E aptitude update -y --assume-yes -q;
  sudo -E aptitude install -y --assume-yes -q git git-core subversion git-svn;

} # install_git

##########################################################################################
# MOTD
##########################################################################################
function configure_motd () {

  echo -e "PROVISIONING: Setting the MOTD banner.\n";

  # Install figlet.
  sudo -E aptitude install -y --assume-yes -q figlet;

  # Set the server login banner with figlet.
  # MOTD_PATH="/etc/motd.tail";
  MOTD_PATH="/etc/motd";
  echo "$(figlet ${MACHINE_NAME^} | head -n -1).local" > "${MOTD_PATH}";
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
# MySQL
##########################################################################################
function install_mysql () {

  echo -e "PROVISIONING: Installing and configuring MySQL related items.\n";

  # Install the MySQL server and client.
  sudo -E RUNLEVEL=1 aptitude install -y --assume-yes -q mysql-server mysql-client;

  # Secure the MySQL installation.
  if [ -f "mysql/mysql_secure_installation.sql" ]; then
    mysql -sfu root < "mysql/mysql_secure_installation.sql";
  fi

  # Set the MySQL configuration.
  if [ -f "mysql/my.cnf" ]; then
    sudo -E cp -f "mysql/my.cnf" "/etc/mysql/my.cnf";
  fi

  # Run these commands to prevent MySQL from coming up on reboot.
  sudo -E service mysql stop;
  sudo -E update-rc.d -f mysql remove;

} # install_mysql

##########################################################################################
# Lighttpd
##########################################################################################
function install_lighttpd () {

  echo -e "PROVISIONING: Installing and configuring Lighttpd related items.\n";

  # Install the Lighttpd server.
  sudo -E RUNLEVEL=1 aptitude install -y --assume-yes -q lighttpd;

  # Remove the default/placeholder Lighttpd index page.
  sudo -E rm -f "/var/www/index.lighttpd.html";
  
  # Set the Lighttpd startup service.
  sudo -E update-rc.d -f lighttpd defaults;

} # install_lighttpd

##########################################################################################
# PHP
##########################################################################################
function install_php () {

  echo -e "PROVISIONING: Installing and configuring PHP related items.\n";

  # Install the PHP modules.
  sudo -E RUNLEVEL=1 aptitude install -y --assume-yes -q php5-cgi php5-mysql;

  # Restart Lighttpd.
  sudo -E service lighttpd restart;

} # install_php

##########################################################################################
# FastCGI
##########################################################################################
function install_fastcgi () {

  echo -e "PROVISIONING: Enabling FastCGI in Lighttpd.\n";

  # Enable FastCGI.
  sudo -E lighty-enable-mod fastcgi fastcgi-php;

  # Restart Lighttpd.
  sudo -E service lighttpd restart;

} # install_fastcgi

##########################################################################################
# MediaWiki
##########################################################################################
function install_mediawiki () {

  echo -e "PROVISIONING: Installing and configuring MediaWiki related items.\n";

  # Do this little dance to get things installed.
  cd "${BASE_DIR}";
  curl -ss -O -L "https://releases.wikimedia.org/mediawiki/1.27/mediawiki-1.27.0.tar.gz";

  # Decompress the archive and remove the source archive.
  if [ -f "mediawiki-1.27.0.tar.gz" ]; then
    tar -xf "mediawiki-1.27.0.tar.gz";
    rm -f "mediawiki-1.27.0.tar.gz";
  fi

  # Move the files from the decompressed directory to the web root and ditch the directory.
  if [ -d "mediawiki-1.27.0" ]; then
    sudo -E mv -f mediawiki-1.27.0/* "/var/www/";
    rm -rf "mediawiki-1.27.0";
  fi

  # Set permissions to www-data for owner and group.
  sudo -E chown -f www-data:www-data -R "/var/www/*";
  
  # Set permissions to read and write for the 'LocalSettings.php' file.
  # sudo chown 600 "/var/www/LocalSettings.php";

} # install_mediawiki

function install_mediawiki_mysql () {

  echo -e "PROVISIONING: Setting up MediaWiki MySQL database stuff.\n";

  # Setup the MediaWiki MySQL database stuff.
  if [ -f "mysql/mediawiki_dev_setup.sql" ]; then
    mysql -sfu root < "mysql/mediawiki_dev_setup.sql";
  fi

} # install_mediawiki_mysql

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
set_environment;
set_timezone;
configure_sources_list;
hash avahi-daemon 2>/dev/null || { install_avahi; }
hash sar 2>/dev/null || {  install_sysstat; }
hash updatedb 2>/dev/null || { install_locate; }
configure_motd;
hash libtool 2>/dev/null || { install_compiler; }
if ! grep -q -s "git-core" /etc/apt/sources.list /etc/apt/sources.list.d/*; then install_git; fi

# MySQL, Lighttpd, PHP and FastCGI.
hash mysql 2>/dev/null || { install_mysql; }
install_lighttpd;
install_php;
install_fastcgi;
install_mediawiki;

# Update the locate database.
update_locate_db;

