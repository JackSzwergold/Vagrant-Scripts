#!/bin/bash

##########################################################################################
#
# Provision Ubuntu (provision_ubuntu.sh) (c) by Jack Szwergold
#
# Provision Ubuntu is licensed under a
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
if [ -n "$1" ]; then
  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: OS is: '${1}'.\033[0m";
  BINS_DIR="deploy_items/bins/${1}";
  CONFS_DIR="deploy_items/confs/${1}";
  # DBS_DIR="deploy_items/dbs/${1}";
fi
# Output a provisioning message.
echo -e "\033[33;1mPROVISIONING: Binaries directory is: '${BINS_DIR}'.\033[0m";
echo -e "\033[33;1mPROVISIONING: Config directory is: '${CONFS_DIR}'.\033[0m";
echo -e "\033[33;1mPROVISIONING: DB directory is: '${DBS_DIR}'.\033[0m";

USERNAME="vagrant";
if [ -n "$2" ]; then USERNAME="${2}"; fi
# Output a provisioning message.
echo -e "\033[33;1mPROVISIONING: User name is: '${USERNAME}'.\033[0m";

PASSWORD="vagrant";
if [ -n "$3" ]; then PASSWORD="${3}"; fi
# Output a provisioning message.
echo -e "\033[33;1mPROVISIONING: User password is: '${PASSWORD}'.\033[0m";

MACHINE_NAME="vagrant";
if [ -n "$4" ]; then MACHINE_NAME="${4}"; fi
# Output a provisioning message.
echo -e "\033[33;1mPROVISIONING: Machine name is: '${MACHINE_NAME}'.\033[0m";

HOST_NAME="vagrant.local";
if [ -n "$5" ]; then HOST_NAME="${5}"; fi
# Output a provisioning message.
echo -e "\033[33;1mPROVISIONING: Host name is: '${HOST_NAME}'.\033[0m";

##########################################################################################
# Optional items set via environment variables.
##########################################################################################

# Output a provisioning message.
echo -e "\033[33;1mPROVISIONING: Basics provisioning: '${PROV_BASICS}'.\033[0m";

# Output a provisioning message.
echo -e "\033[33;1mPROVISIONING: LAMP provisioning: '${PROV_LAMP}'.\033[0m";

# Output a provisioning message.
echo -e "\033[33;1mPROVISIONING: ImageMagick provisioning: '${PROV_IMAGEMAGICK}'.\033[0m";

# Output a provisioning message.
echo -e "\033[33;1mPROVISIONING: GeoIP provisioning: '${PROV_GEOIP}'.\033[0m";

# Output a provisioning message.
echo -e "\033[33;1mPROVISIONING: IPTables provisioning: '${PROV_IPTABLES}'.\033[0m";

# Output a provisioning message.
echo -e "\033[33;1mPROVISIONING: Fail2Ban provisioning: '${PROV_FAIL2BAN}'.\033[0m";

# Output a provisioning message.
echo -e "\033[33;1mPROVISIONING: Java provisioning: '${PROV_JAVA}'.\033[0m";

# Output a provisioning message.
echo -e "\033[33;1mPROVISIONING: Solr provisioning: '${PROV_SOLR}'.\033[0m";

# Output a provisioning message.
echo -e "\033[33;1mPROVISIONING: Elasticsearch provisioning: '${PROV_ELASTICSEARCH}'.\033[0m";

# Output a provisioning message.
echo -e "\033[33;1mPROVISIONING: MongoDB provisioning: '${PROV_MONGO}'.\033[0m";

# Output a provisioning message.
echo -e "\033[33;1mPROVISIONING: NodeJS provisioning: '${PROV_NODEJS}'.\033[0m";

# Output a provisioning message.
echo -e "\033[33;1mPROVISIONING: Nginx provisioning: '${PROV_NGINX}'.\033[0m";

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
# User and Group
##########################################################################################
function configure_user_and_group () {

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Adjusting user and group related items.\033[0m";

  # Create the 'www-readwrite' group.
  sudo -E groupadd -f www-readwrite;

  # Set the user’s main group to be the 'www-readwrite' group.
  sudo -E usermod -g www-readwrite "${USERNAME}";

  # Add the user to the 'www-readwrite' group:
  sudo -E adduser --quiet "${USERNAME}" www-readwrite;

  # Changing the username/password combination.
  echo "${USERNAME}:${PASSWORD}" | sudo -E sudo chpasswd;

} # configure_user_and_group

##########################################################################################
# Environment
##########################################################################################
function set_user_environment () {

  # Go into the config directory.
  cd "${BASE_DIR}/${CONFS_DIR}";

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Setting the selected editor.\033[0m";

  # Set the selected editor to be Nano.
  if [ ! -f "${BASE_DIR}/.selected_editor" ]; then
    echo 'SELECTED_EDITOR="/bin/nano"' > "${BASE_DIR}/.selected_editor";
    sudo -E chown -f "${USERNAME}":www-readwrite "${BASE_DIR}/.selected_editor";
  fi

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Importing the crontab.\033[0m";

  # Importing the crontab.
  sudo -E crontab < "crontab.conf";

} # set_user_environment

##########################################################################################
# Timezone
##########################################################################################
function set_timezone () {

  # Set the timezone value.
  TIMEZONE="America/New_York";

  if ! hash timedatectl 2>/dev/null; then

    # Set the timezone path.
    TIMEZONE_PATH="/usr/share/zoneinfo";

    # Output a provisioning message.
    echo -e "\033[33;1mPROVISIONING: Setting timezone data manually.\033[0m";

    # Set the actual timezone via a symbolic link.
    sudo -E ln -f -s "${TIMEZONE_PATH}/${TIMEZONE}" "/etc/localtime";

  else

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
# Configure repository stuff.
##########################################################################################
function configure_repository_stuff () {

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Install Aptitude.\033[0m";

  # Install Aptitude.
  sudo -E apt-get -y -q=2 install aptitude aptitude-common;

  # Update Aptitude.
  sudo -E aptitude -y -q=2 update;

  # Adjusting the sources list.
  SOURCES_LIST="/etc/apt/sources.list";
  DEB_URL_PATTERN="^#.*deb.*partner$";
  if [ -f "${SOURCES_LIST}" ] && grep -E -q "${DEB_URL_PATTERN}" "${SOURCES_LIST}"; then

    # Output a provisioning message.
    echo -e "\033[33;1mPROVISIONING: Adjusting the sources list.\033[0m";

    # Adjust the sources list.
    sudo -E sed -i "/${DEB_URL_PATTERN}/s/^# //g" "${SOURCES_LIST}";

  fi

} # configure_repository_stuff

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
# IPTables and IPSet
##########################################################################################
function install_iptables () {

  # Go into the config directory.
  cd "${BASE_DIR}/${CONFS_DIR}";

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: IPTables and IPSet stuff.\033[0m";

  # Install IPTables and IPSet stuff.
  sudo -E debconf-set-selections <<< "iptables-persistent iptables-persistent/autosave_v4 boolean true";
  sudo -E debconf-set-selections <<< "iptables-persistent iptables-persistent/autosave_v6 boolean true";
  sudo -E aptitude -y -q=2 install iptables iptables-persistent ipset;

  # Load the IPSet stuff if the file exists.
  if [ -f "iptables/ipset.conf" ]; then
    sudo -E ipset restore < "iptables/ipset.conf";
    sudo -E cp -f "iptables/ipset.conf" "/etc/iptables/rules.ipsets";
  fi

  # Load the IPTables stuff if the file exists.
  if [ -f "iptables/iptables.conf" ]; then
    sudo -E iptables-restore < "iptables/iptables.conf";
    sudo -E cp -f "iptables/iptables.conf" "/etc/iptables/rules.v4";
  fi

  # Patch 'iptables-persistent' if the patch exists and the original 'iptables-persistent' exists.
  if [ -f "/etc/init.d/iptables-persistent" ] && [ -f "iptables/iptables-persistent-ipset.patch" ]; then
    sudo -E patch -fsb "/etc/init.d/iptables-persistent" < "iptables/iptables-persistent-ipset.patch";
  fi

} # install_iptables

##########################################################################################
# Apache
##########################################################################################
function install_apache () {

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Installing Apache and PHP related items.\033[0m";

  # Install the base Apache related items.
  sudo -E RUNLEVEL=1 aptitude -y -q=2 install \
    apache2 apache2-dev php5 \
    libapache2-mod-php5 php-pear \
    apachetop;

  # Install other PHP related related items.
  sudo -E RUNLEVEL=1 aptitude -y -q=2 install \
    php5-mysql php5-pgsql php5-odbc php5-sybase php5-sqlite \
    php5-xmlrpc php5-json php5-xsl php5-curl php5-geoip \
    php-getid3 php5-imap php5-ldap php5-mcrypt \
    php5-pspell php5-gmp php5-gd;

  # Enable the PHP mcrypt module.
  sudo -E php5enmod mcrypt;

  # Enable these core Apache modules.
  sudo -E a2enmod -q rewrite headers expires include proxy proxy_http cgi;

} # install_apache

##########################################################################################
# Apache configure.
##########################################################################################
function configure_apache () {

  # Go into the config directory.
  cd "${BASE_DIR}/${CONFS_DIR}";

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Setting Apache and PHP configs.\033[0m";

  # Copy the Apache config files into place.
  sudo -E cp -f "apache2/apache2.conf" "/etc/apache2/apache2.conf";
  sudo -E cp -f "apache2/envvars" "/etc/apache2/envvars";
  sudo -E cp -f "apache2/mpm_prefork.conf" "/etc/apache2/mods-available/mpm_prefork.conf";
  sudo -E cp -f "apache2/security.conf" "/etc/apache2/conf-available/security.conf";
  sudo -E cp -f "apache2/common.conf" "/etc/apache2/sites-available/common.conf";
  sudo -E cp -f "apache2/000-default.conf" "/etc/apache2/sites-available/000-default.conf";

  # Copy and configure the Apache virtual host config file.
  sudo -E cp -f "apache2/vagrant.local.conf" "/etc/apache2/sites-available/${HOST_NAME}.conf";
  sudo -E sed -i "s/vagrant.local/${HOST_NAME}/g" "/etc/apache2/sites-available/${HOST_NAME}.conf";
  HOST_NAME_ESCAPED=$(echo "${HOST_NAME}" | sed 's/\./\\\\./g');
  sudo -E sed -i "s/vagrant\\\.local/${HOST_NAME_ESCAPED}/" "/etc/apache2/sites-available/${HOST_NAME}.conf";
  sudo -E a2ensite ${HOST_NAME};

  # Copy the PHP config files into place.
  sudo -E cp -f "php/php.ini" "/etc/php5/apache2/php.ini";

} # configure_apache

##########################################################################################
# Apache web root.
##########################################################################################
function set_apache_web_root () {

  # Go into the config directory.
  cd "${BASE_DIR}/${CONFS_DIR}";

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Adjusting the Apache root directory and default file.\033[0m";

  # Change ownership and permissions.
  sudo -E chown -f -R "${USERNAME}":www-readwrite "/var/www/html/";
  sudo -E chmod -f -R 775 "/var/www/html/";
  sudo -E chmod g+s "/var/www/html/";
  sudo -E cp -f "apache2/index.php" "/var/www/html/index.php";
  sudo -E chmod -f -R 664 "/var/www/html/index.php";

} # set_apache_web_root

##########################################################################################
# Apache deployment directories.
##########################################################################################
function set_apache_deployment_directories () {

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Creating the web code deployment directories.\033[0m";

  # Set the deployment directories.
  sudo -E mkdir -p "/var/www/"{builds,configs,content};
  sudo -E chown -f -R "${USERNAME}":www-readwrite "/var/www/"{builds,configs,content};
  sudo -E chmod -f -R 775 "/var/www/"{builds,configs,content};
  sudo -E chmod g+s "/var/www/"{builds,configs,content};

} # set_apache_deployment_directories

##########################################################################################
# Apache virtual host directories.
##########################################################################################
function set_apache_virtual_host_directories () {

  # Go into the config directory.
  cd "${BASE_DIR}/${CONFS_DIR}";

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Creating the web server document root directories.\033[0m";

  sudo -E mkdir -p "/var/www/html/${HOST_NAME}/site";
  sudo -E cp -f "apache2/index.php" "/var/www/html/${HOST_NAME}/site/index.php";
  sudo -E chown -f -R "${USERNAME}":www-readwrite "/var/www/html/${HOST_NAME}";
  sudo -E chmod -f -R 775 "/var/www/html/${HOST_NAME}";
  sudo -E chmod g+s "/var/www/html/${HOST_NAME}";
  sudo -E chmod -f -R 664 "/var/www/html/${HOST_NAME}/site/index.php";

} # set_apache_virtual_host_directories

##########################################################################################
# Apache log rotation.
##########################################################################################
function configure_apache_log_rotation () {

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Adjusting the Apache log rotation script.\033[0m";

  sudo -E sed -i 's/rotate 52/rotate 13/g' "/etc/logrotate.d/apache2";
  sudo -E sed -i 's/create 640 root adm/create 640 root www-readwrite/g' "/etc/logrotate.d/apache2";

  # Adjust permissions on log files.
  sudo -E chmod o+rx "/var/log/apache2";
  sudo -E chgrp www-readwrite "/var/log/apache2/"*;
  sudo -E chmod 644 "/var/log/apache2/"*;

} # configure_apache_log_rotation

##########################################################################################
# MySQL
##########################################################################################
function install_mysql () {

  # Go into the config directory.
  cd "${BASE_DIR}/${CONFS_DIR}";

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Installing and configuring MySQL related items.\033[0m";

  # Install the MySQL server and client.
  sudo -E RUNLEVEL=1 aptitude -y -q=2 install mysql-server mysql-client;

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
# Munin
##########################################################################################
function install_munin () {

  # Go into the config directory.
  cd "${BASE_DIR}/${CONFS_DIR}";

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Installing and configuring Munin related items.\033[0m";

  # Install Munin.
  sudo -E RUNLEVEL=1 aptitude -y -q=2 install munin munin-node munin-plugins-extra libwww-perl;

  # Install the copied Munin config if it exists.
  MUNIN_CONF_PATH="/etc/munin/munin.conf";
  if [ -f "munin/munin.conf" ]; then
    sudo -E cp -f "munin/munin.conf" "${MUNIN_CONF_PATH}";
    sudo -E sed -i "s/^\[vagrant.local\]/\[${HOST_NAME}\]/g" "${MUNIN_CONF_PATH}";
  fi

  # Ditch the default 'localdomain' stuff from the system.
  sudo -E rm -rf "/var/lib/munin/localdomain";
  sudo -E rm -rf "/var/cache/munin/www/localdomain";

  # Activate the Apache related Munin plug-ins.
  sudo -E ln -fs "/usr/share/munin/plugins/apache_accesses" "/etc/munin/plugins/apache_accesses";
  sudo -E ln -fs "/usr/share/munin/plugins/apache_processes" "/etc/munin/plugins/apache_processes";
  sudo -E ln -fs "/usr/share/munin/plugins/apache_volume" "/etc/munin/plugins/apache_volume";

  # Activate the MySQL related Munin plug-ins.
  sudo -E ln -fs "/usr/share/munin/plugins/mysql_bytes" "/etc/munin/plugins/mysql_bytes";
  sudo -E ln -fs "/usr/share/munin/plugins/mysql_queries" "/etc/munin/plugins/mysql_queries";
  sudo -E ln -fs "/usr/share/munin/plugins/mysql_slowqueries" "/etc/munin/plugins/mysql_slowqueries";
  sudo -E ln -fs "/usr/share/munin/plugins/mysql_threads" "/etc/munin/plugins/mysql_threads";

  # Activate the Postfix related Munin plug-ins.
  sudo -E ln -fs "/usr/share/munin/plugins/postfix_mailqueue" "/etc/munin/plugins/postfix_mailqueue";
  sudo -E ln -fs "/usr/share/munin/plugins/postfix_mailvolume" "/etc/munin/plugins/postfix_mailvolume";

  # Activate the Fail2Ban related Munin plug-ins.
  sudo -E ln -fs "/usr/share/munin/plugins/fail2ban" "/etc/munin/plugins/fail2ban";

  # Repair Munin permissions.
  sudo -E munin-check --fix-permissions >/dev/null 2>&1;

  # Restart the Munin node.
  sudo -E service munin-node restart;

} # install_munin

##########################################################################################
# Munin Apache config.
##########################################################################################
function configure_munin_apache () {

  # Go into the config directory.
  cd "${BASE_DIR}/${CONFS_DIR}";

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Installing the Apache Munin config.\033[0m";

  sudo -E rm -f "/etc/apache2/conf-available/munin.conf";
  sudo -E cp -f "apache2/munin.conf" "/etc/apache2/conf-available/munin.conf";
  sudo -E a2enconf -q munin;
  # sudo -E service apache2 restart;

} # configure_munin_apache

##########################################################################################
# Munin Apache config enable.
##########################################################################################
function enable_munin_apache () {

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Enabling the Apache Munin config.\033[0m";

  sudo -E a2enconf -q munin;
  # sudo -E service apache2 restart;

}  # enable_munin_apache

##########################################################################################
# phpMyAdmin
##########################################################################################
function install_phpmyadmin () {

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Installing phpMyAdmin related items.\033[0m";

  # Do this little dance to get things installed.
  curl -ss -O -L "https://files.phpmyadmin.net/phpMyAdmin/4.0.10.11/phpMyAdmin-4.0.10.11-all-languages.tar.gz";
  tar -xf "phpMyAdmin-4.0.10.11-all-languages.tar.gz";
  rm -f "phpMyAdmin-4.0.10.11-all-languages.tar.gz";
  sudo -E mv -f "phpMyAdmin-4.0.10.11-all-languages" "/usr/share/phpmyadmin";

  # Set permissions to root for owner and group.
  sudo -E chown -f root:root -R "/usr/share/phpmyadmin";

} # install_phpmyadmin

##########################################################################################
# phpMyAdmin config.
##########################################################################################
function configure_phpmyadmin () {

  # Go into the config directory.
  cd "${BASE_DIR}/${CONFS_DIR}";

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Configuring phpMyAdmin related items.\033[0m";

  # Set the phpMyAdmin config file.
  sudo -E cp -f "phpmyadmin/config.inc.php" "/usr/share/phpmyadmin/config.inc.php";

  # Copy and set the patched 'Header.class.php' file.
  if [ -f "phpmyadmin/Header.class.php" ]; then
    sudo -E cp -f "phpmyadmin/Header.class.php" "/usr/share/phpmyadmin/libraries/Header.class.php";
  fi

  # Disable the phpMyAdmin PDF export stuff; never works right and can crash a server quite quickly.
  PHPMYADMIN_PLUGIN_PATH="/usr/share/phpmyadmin/libraries/plugins/export/";
  if grep -q -s {PMA_,}ExportPdf.class.php "${PHPMYADMIN_PLUGIN_PATH}"*; then
    sudo -E rm -f "${PHPMYADMIN_PLUGIN_PATH}"{PMA_,}ExportPdf.class.php;
  fi

} # configure_phpmyadmin

##########################################################################################
# phpMyAdmin blowfish secret.
##########################################################################################
function configure_phpmyadmin_blowfish () {

  if [ -f "/usr/share/phpmyadmin/config.inc.php" ] && grep -E -q "a8b7c6d" "/usr/share/phpmyadmin/config.inc.php"; then

    # Output a provisioning message.
    echo -e "\033[33;1mPROVISIONING: Setting a new phpMyAdmin blowfish secret value.\033[0m";

    BLOWFISH_SECRET=$(openssl rand -base64 30);
    sudo -E sed -i "s|'a8b7c6d'|'${BLOWFISH_SECRET}'|g" "/usr/share/phpmyadmin/config.inc.php";

  fi

} # configure_phpmyadmin_blowfish

##########################################################################################
# phpMyAdmin Apache config.
##########################################################################################
function configure_awstats_apache () {

  # Go into the config directory.
  cd "${BASE_DIR}/${CONFS_DIR}";

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Installing the Apache phpMyAdmin config.\033[0m";

  sudo -E cp -f "apache2/phpmyadmin.conf" "/etc/apache2/conf-available/phpmyadmin.conf";
  sudo -E a2enconf -q phpmyadmin;
  # sudo -E service apache2 restart;

} # configure_awstats_apache

##########################################################################################
# GeoIP
##########################################################################################
function install_geoip () {

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Setting up to install the GeoIP binary.\033[0m";

  # Install the core compiler and build options.
  sudo aptitude -y -q=2 install build-essential libtool zlib1g-dev;

  # Get the GeoIP source code.
  cd "${BASE_DIR}";
  curl -ss -O -L "http://www.maxmind.com/download/geoip/api/c/GeoIP-latest.tar.gz";
  tar -xf "GeoIP-latest.tar.gz";
  rm -f "GeoIP-latest.tar.gz";
  cd ./GeoIP*;

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Configuring the GeoIP binary.\033[0m";
  # autoreconf -f -i;
  libtoolize -f -q;
  ./configure;

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Making the GeoIP binary.\033[0m";
  make -s >/dev/null 2>&1;

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Installing the GeoIP binary.\033[0m";
  sudo -E make -s install >/dev/null 2>&1;

  # Cleanup.
  cd "${BASE_DIR}";
  sudo -E rm -rf ./GeoIP*;

} # install_geoip

##########################################################################################
# GeoIP databases.
##########################################################################################
function install_geoip_databases () {

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Installing the GeoIP databases.\033[0m";

  # Get the GeoIP databases.
  if [ ! -f "/tmp/GeoIP.dat.gz" ] && [ ! -f "/usr/local/share/GeoIP/GeoIP.dat" ]; then
    curl -ss -L "http://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz" > "/tmp/GeoIP.dat.gz";
  fi

  if [ ! -f "/tmp/GeoLiteCity.dat.gz" ] && [ ! -f "/usr/local/share/GeoIP/GeoIPCity.dat" ]; then
    curl -ss -L "http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz" > "/tmp/GeoLiteCity.dat.gz";
  fi

  if [ ! -f "/tmp/GeoIPASNum.dat.gz" ] && [ ! -f "/usr/local/share/GeoIP/GeoIPASNum.dat" ]; then
    curl -ss -L "http://geolite.maxmind.com/download/geoip/database/asnum/GeoIPASNum.dat.gz" > "/tmp/GeoIPASNum.dat.gz";
  fi

  if [ ! -f "/tmp/GeoIPCountryCSV.zip" ] && [ ! -f "/usr/local/share/GeoIP/GeoIPCountryWhois.csv" ]; then
    curl -ss -L "http://geolite.maxmind.com/download/geoip/database/GeoIPCountryCSV.zip" > "/tmp/GeoIPCountryCSV.zip";
  fi

  # Create the GeoIP directory—if it doesn't exist—like this.
  sudo mkdir -p "/usr/local/share/GeoIP/";

  # Move and decompress the databases to GeoIP data path.
  if [ -d "/usr/local/share/GeoIP" ]; then

    if [ -f "/tmp/GeoIP.dat.gz" ]; then
      sudo -E mv "/tmp/GeoIP.dat.gz" "/usr/local/share/GeoIP/";
      sudo -E gzip -d -q -f "/usr/local/share/GeoIP/GeoIP.dat.gz";
      sudo -E ln -s -f "/usr/local/share/GeoIP/GeoIP.dat" "/usr/share/GeoIP/";
    fi

    if [ -f "/tmp/GeoLiteCity.dat.gz" ]; then
      sudo -E mv "/tmp/GeoLiteCity.dat.gz" "/usr/local/share/GeoIP/";
      sudo -E gzip -d -q -f "/usr/local/share/GeoIP/GeoLiteCity.dat.gz";
      sudo -E mv "/usr/local/share/GeoIP/GeoLiteCity.dat" "/usr/local/share/GeoIP/GeoIPCity.dat";
      sudo -E ln -s -f "/usr/local/share/GeoIP/GeoIPCity.dat" "/usr/share/GeoIP/";
    fi

    if [ -f "/tmp/GeoIPASNum.dat.gz" ]; then
      sudo -E mv "/tmp/GeoIPASNum.dat.gz" "/usr/local/share/GeoIP/";
      sudo -E gzip -d -q -f "/usr/local/share/GeoIP/GeoIPASNum.dat.gz";
      sudo -E ln -s -f "/usr/local/share/GeoIP/GeoIPASNum.dat" "/usr/share/GeoIP/";
    fi

    if [ -f "/tmp/GeoIPCountryCSV.zip" ]; then
      sudo -E mv "/tmp/GeoIPCountryCSV.zip" "/usr/local/share/GeoIP/";
      sudo -E unzip -o -q -d "/usr/local/share/GeoIP/" "/usr/local/share/GeoIP/GeoIPCountryCSV.zip";
      sudo -E rm -f "/usr/local/share/GeoIP/GeoIPCountryCSV.zip";
      sudo -E ln -s -f "/usr/local/share/GeoIP/GeoIPCountryWhois.csv" "/usr/share/GeoIP/";
    fi

    # Set permissions to root for owner and group.
    sudo -E chown root:root -R "/usr/local/share/GeoIP/";

  fi

} # install_geoip_databases

##########################################################################################
# AWStats
##########################################################################################
function install_awstats () {

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Installing the AWStats related items.\033[0m";

  # Do this little dance to get things installed.
  cd "${BASE_DIR}";
  curl -ss -O -L "http://prdownloads.sourceforge.net/awstats/awstats-7.3.tar.gz";
  tar -xf "awstats-7.3.tar.gz";
  rm -f "awstats-7.3.tar.gz";
  sudo -E mv -f "awstats-7.3" "/usr/share/awstats-7.3";

  # Go into the config directory.
  cd "${BASE_DIR}/${CONFS_DIR}";

  # Set an index page for AWStats.
  sudo -E cp -f "awstats/awstatstotals.php" "/usr/share/awstats-7.3/wwwroot/cgi-bin/index.php";
  sudo -E chmod a+r "/usr/share/awstats-7.3/wwwroot/cgi-bin/index.php";

  # Create the AWStats data directory.
  sudo -E mkdir -p "/usr/share/awstats-7.3/wwwroot/data";
  sudo -E chmod -f g+w "/usr/share/awstats-7.3/wwwroot/data";

  # Now install CPANminus like this.
  hash cpanminus 2>/dev/null || {
    sudo -E aptitude -y -q=2 install cpanminus;
  }

  # With that done, install all of the GeoIP related CPAN modules like this.
  sudo cpanm --install --force --notest --quiet --skip-installed YAML Geo::IP Geo::IPfree Geo::IP::PurePerl URI::Escape Net::IP Net::DNS Net::XWhois Time::HiRes Time::Local;

  # Copy over a basic config file.
  sudo -E cp -f "awstats/awstats.vagrant.local.conf" "/usr/share/awstats-7.3/wwwroot/cgi-bin/awstats.${HOST_NAME}.conf";
  sudo -E sed -i "s/vagrant.local/${HOST_NAME}/g" "/usr/share/awstats-7.3/wwwroot/cgi-bin/awstats.${HOST_NAME}.conf";


  # Set permissions to root for owner and group.
  sudo -E chown -f root:root -R "/usr/share/awstats-7.3";

  # Update the data for the '${HOST_NAME}' config.
  sudo -E "/usr/share/awstats-7.3/wwwroot/cgi-bin/awstats.pl" -config="${HOST_NAME}" -update

} # install_awstats

##########################################################################################
# AWStats Apache config.
##########################################################################################
function configure_awstats_apache () {

  # Go into the config directory.
  cd "${BASE_DIR}/${CONFS_DIR}";

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Installing the Apache AWStats config.\033[0m";

  sudo -E cp -f "apache2/awstats.conf" "/etc/apache2/conf-available/awstats.conf";
  sudo -E a2enconf -q awstats;
  # sudo -E service apache2 restart;

} # configure_awstats_apache

##########################################################################################
# Fail2Ban
##########################################################################################
function install_fail2ban () {

  # Go into the config directory.
  cd "${BASE_DIR}/${CONFS_DIR}";

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Fail2Ban related stuff.\033[0m";

  # Install Fail2Ban.
  sudo -E aptitude -y -q=2 purge fail2ban;
  sudo -E aptitude -y -q=2 install gamin libgamin0 python-central python-gamin python-support;
  curl -ss -O -L "http://old-releases.ubuntu.com/ubuntu/pool/universe/f/fail2ban/fail2ban_0.8.13-1_all.deb";
  sudo -E RUNLEVEL=1 dpkg --force-all -i "fail2ban_0.8.13-1_all.deb";

  # Run these commands to prevent Fail2Ban from coming up on reboot.
  sudo -E service fail2ban stop;
  sudo -E update-rc.d -f fail2ban remove;

} # install_fail2ban

##########################################################################################
# Fail2Ban config.
##########################################################################################
function configure_fail2ban () {

  # Go into the config directory.
  cd "${BASE_DIR}/${CONFS_DIR}";

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Installing the Fail2Ban configs.\033[0m";

  sudo -E cp -f "fail2ban/jail.local" "/etc/fail2ban/jail.local";
  sudo -E cp -f "fail2ban/ddos.conf" "/etc/fail2ban/filter.d/ddos.conf";

  # Restart Fail2Ban.
  sudo -E service fail2ban restart;

  # Run these commands to prevent Fail2Ban from coming up on reboot.
  sudo -E service fail2ban stop;
  sudo -E update-rc.d -f fail2ban remove;

} # configure_fail2ban

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
  sudo -E cp -f "monit/apache2.conf" "/etc/monit/conf.d/apache2.conf";

  # Restart Monit.
  sudo -E service monit restart;

  # Run these commands to prevent Monit from coming up on reboot.
  sudo -E service monit stop;
  sudo -E update-rc.d -f monit remove;

} # configure_monit

##########################################################################################
# ImageMagick
##########################################################################################
function install_imagemagick () {

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Installing ImageMagick from source.\033[0m";

  # Install the dependencies for ImageMagick.
  sudo -E aptitude -y -q=2 install \
    build-essential libtool checkinstall \
    libx11-dev libxext-dev zlib1g-dev libpng12-dev \
    libjpeg-dev libfreetype6-dev libxml2-dev;

  # Build the dependencies for ImageMagick.
  sudo -E aptitude build-dep -y -q imagemagick;

  # Get the ImageMagick source code.
  cd "${BASE_DIR}";
  curl -ss -O -L "http://www.imagemagick.org/download/ImageMagick.tar.gz";
  tar -xf "ImageMagick.tar.gz";
  rm -f "ImageMagick.tar.gz";
  cd ./ImageMagick-*;
  ./configure;
  sudo checkinstall -y;

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Make and install the ImageMagick binary DEB package.\033[0m";
  IMAGEMAGICK_DEB=$(ls -1 imagemagick-*.deb);
  sudo -E RUNLEVEL=1 dpkg --force-all -i "${IMAGEMAGICK_DEB}";
  sudo ldconfig "/usr/local/lib";

  # Cleanup to get rid of the installer stuff.
  cd "${BASE_DIR}";
  sudo -E rm -rf ./ImageMagick-*;

} # install_imagemagick

##########################################################################################
# Scripts.
##########################################################################################
function install_system_scripts () {

  # Go into the config directory.
  cd "${BASE_DIR}/${CONFS_DIR}";

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Installing configuring various system scripts.\033[0m";

  # Copy and configure various system scripts.
  sudo -E mkdir -p "/opt/server_scripts";
  sudo -E chmod 775 "/opt/server_scripts";
  sudo -E chmod g+s "/opt/server_scripts";
  sudo -E cp -f "scripts/"*.sh "/opt/server_scripts/";
  sudo -E chown -f -R root:www-readwrite "/opt/server_scripts/"*.sh;
  sudo -E sed -i "s/vagrant.local/${HOST_NAME}/g" "/opt/server_scripts/"*.cfg.sh;
  sudo -E chmod -f -R 775 "/opt/server_scripts/"*.sh;

  # Create the MySQL backup directory.
  # sudo -E mkdir -p "/opt/mysql_backup";
  # sudo -E chown root:www-readwrite "/opt/mysql_backup";
  # sudo -E chmod 775 "/opt/mysql_backup";
  # sudo -E chmod g+s "/opt/mysql_backup";

} # install_system_scripts

##########################################################################################
# Java
##########################################################################################
function install_java () {

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Installing Java.\033[0m";

  # # Now install Java via PPA.
  # sudo -E aptitude -y -q=2 install python-software-properties debconf-utils;
  #
  # sudo -E add-apt-repository ppa:webupd8team/java;
  # sudo -E aptitude -y -q=2 update;
  # echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | sudo debconf-set-selections;
  # sudo -E aptitude -y -q=2 install oracle-java8-installer oracle-java8-set-default;
  # echo "JAVA_HOME=/usr/lib/jvm/java-8-oracle/jre" >> "/etc/environment";

  # Process to use OpenJDK 7.
  sudo -E aptitude -y -q=2 install openjdk-7-jdk;
  sudo -E mkdir -p "/usr/java";
  sudo -E ln -s "/usr/lib/jvm/java-7-openjdk-amd64" "/usr/java/default";

} # install_java

##########################################################################################
# Install Solr
##########################################################################################
function install_solr () {

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Installing Solr related items.\033[0m";

  # Go into the base directory.
  cd "${BASE_DIR}";

  # Import the public key used by the package management system:
  # curl -ss -L -O "http://archive.apache.org/dist/lucene/solr/5.5.3/solr-5.5.3.tgz";
  # curl -ss -L -O "http://archive.apache.org/dist/lucene/solr/6.2.1/solr-6.2.1.tgz";
  # curl -ss -L -O "http://archive.apache.org/dist/lucene/solr/6.3.0/solr-6.3.0.tgz";
  curl -ss -L -O "http://archive.apache.org/dist/lucene/solr/5.5.3/solr-5.5.3.tgz";
  tar -zxf solr-5.5.3.tgz solr-5.5.3/bin/install_solr_service.sh --strip-components=2;
  sudo -E bash ./install_solr_service.sh solr-5.5.3.tgz;

  # 2016-11-16: Not working. Another idea on how to make the process less dependent on version numbers.
  # curl -ss -L -o "solr.tgz" "http://archive.apache.org/dist/lucene/solr/5.5.3/solr-5.5.3.tgz";
  # tar -zxf solr.tgz $(tar -tzf solr.tgz | grep install_solr_service) --strip-components=2;
  # sudo -E bash ./install_solr_service.sh solr.tgz;

  # Restart Solr.
  # sudo -E service solr restart;

} # install_solr

##########################################################################################
# Install Elasticsearch
##########################################################################################
function install_elasticsearch () {

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Installing ElasticSearch related items.\033[0m";

  # Go into the base directory.
  cd "${BASE_DIR}";

  # Import the public key used by the package management system:
  wget -qO - http://packages.elasticsearch.org/GPG-KEY-elasticsearch | sudo apt-key add -;
  echo 'deb http://packages.elasticsearch.org/elasticsearch/1.7/debian stable main' | sudo tee /etc/apt/sources.list.d/elasticsearch.list;
  sudo -E aptitude -y -q=2 update;
  sudo -E RUNLEVEL=1 aptitude -y -q=2 install elasticsearch;

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
  cd "${BASE_DIR}/${CONFS_DIR}";

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Configuring ElasticSearch related items.\033[0m";

  # Copy the Elasticsearch config file in place and restart sysstat.
  if [ -f "elasticsearch/elasticsearch.yml" ]; then
    sudo -E cp -f "elasticsearch/elasticsearch.yml" "/etc/elasticsearch/elasticsearch.yml";
    sudo -E service elasticsearch restart;
  fi

} # configure_elasticsearch

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
# NodeJS and NPM
##########################################################################################
function install_nodejs () {

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Installing NodeJS and NPM related stuff.\033[0m";

  # Go into the base directory.
  cd "${BASE_DIR}";

  # Purge any already installed version of NodeJS and NPM.
  sudo -E aptitude -y -q=2 purge node npm;

  # Now install NodeJS and NPM via PPA.
  sudo -E aptitude -y -q=2 install python-software-properties;
  # curl -sL https://deb.nodesource.com/setup_6.x | sudo bash - ;
  # curl -sL https://deb.nodesource.com/setup_5.x | sudo bash - ;
  # curl -sL https://deb.nodesource.com/setup_4.x | sudo bash - ;
  # curl -sL https://deb.nodesource.com/setup_0.10 | sudo bash - ;
  curl -sL https://deb.nodesource.com/setup_4.x | sudo bash - ;
  sudo -E aptitude -y -q=2 update;
  sudo -E aptitude -y -q=2 install nodejs;

  # Install 'forever' and 'userdown' for Upstart script support.
  sudo -E npm install -g --no-optional forever 2>&1 >/dev/null;
  sudo -E npm install -g --no-optional userdown 2>&1 >/dev/null;

} # install_nodejs

##########################################################################################
# Nginx
##########################################################################################
function install_nginx () {

  # Go into the config directory.
  cd "${BASE_DIR}/${CONFS_DIR}";

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Installing Nginx related stuff.\033[0m";

  # Now install Nginx.
  sudo -E aptitude -y -q=2 install nginx-full;

  # Copy the Nginx config file in place and restart sysstat.
  NGINX_CONF_PATH="/etc/nginx/sites-available";
  if [ -f "nginx/default" ]; then
    sudo -E cp -f "nginx/default" "${NGINX_CONF_PATH}/default";
    sudo -E sed -i "s/vagrant.local/${HOST_NAME}/g" "${NGINX_CONF_PATH}/default";
    sudo -E service nginx restart;
  fi

} # install_nginx

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
configure_repository_stuff;
configure_user_and_group;
set_user_environment;
hash sar 2>/dev/null || { install_sysstat; }
hash updatedb 2>/dev/null || { install_locate; }
configure_motd;

# Get the basics set.
if [ "${PROV_BASICS}" = true ]; then

  install_basic_tools;
  hash libtool 2>/dev/null || { install_compiler; }
  if ! grep -q -s "git-core" "/etc/apt/sources.list" "/etc/apt/sources.list.d/"*; then install_git; fi
  hash postfix 2>/dev/null || { install_postfix; }
  if [ -f "system/login.defs" ] && [ -f "/etc/login.defs" ]; then configure_login_defs; fi
  if [ -f "system/common-session" ] && [ -f "/etc/pam.d/common-session" ]; then configure_common_session; fi
  if [ -f "ssh/ssh_config" ] && [ -f "/etc/ssh/ssh_config" ]; then configure_ssh; fi

fi

# Timezone and related stuff.
set_timezone;

# Avahi
hash avahi-daemon 2>/dev/null || { install_avahi; }

# GeoIP
if [ "${PROV_GEOIP}" = true ]; then

  hash geoiplookup 2>/dev/null || { install_geoip; }
  if [ ! -d "/usr/local/share/GeoIP" ]; then install_geoip_databases; fi

fi

# IPTables
if [ "${PROV_IPTABLES}" = true ]; then

  hash iptables 2>/dev/null && hash ipset 2>/dev/null || { install_iptables; }

fi

# Fail2Ban
if [ "${PROV_FAIL2BAN}" = true ]; then

  hash fail2ban-client 2>/dev/null || { install_fail2ban; }
  if [ -f "fail2ban/jail.local" ] && [ ! -f "/etc/fail2ban/jail.local" ]; then configure_fail2ban; fi

fi

# Monit
hash monit 2>/dev/null || { install_monit; }
if [ -f "monit/monitrc" ]; then configure_monit; fi

# ImageMagick
if [ "${PROV_IMAGEMAGICK}" = true ]; then
  hash convert 2>/dev/null || { install_imagemagick; }
fi

# Get the LAMP stuff set.
if [ "${PROV_LAMP}" = true ]; then

  # Apache related stuff.
  hash apachectl 2>/dev/null || { install_apache; }
  sudo -E service apache2 stop;
  configure_apache;
  if [ -d "/var/www/html" ]; then set_apache_web_root; fi
  if [ ! -d "/var/www/builds" ]; then set_apache_deployment_directories; fi
  if [ ! -d "/var/www/html/${HOST_NAME}" ]; then set_apache_virtual_host_directories; fi
  if [ -f "/etc/logrotate.d/apache2" ]; then configure_apache_log_rotation; fi

  # MySQL related stuff.
  hash mysql 2>/dev/null && hash mysqld 2>/dev/null || { install_mysql; }

  # Munin related stuff.
  hash munin-node 2>/dev/null || { install_munin; }
  if [ -f "apache2/munin.conf" ] && [ -h "/etc/apache2/conf-available/munin.conf" ]; then configure_munin_apache;
  elif [ -f "apache2/munin.conf" ] && [ ! -h "/etc/apache2/conf-enabled/munin.conf" ]; then enable_munin_apache; fi

  # phpMyAdmin related stuff.
  if [ ! -d "/usr/share/phpmyadmin" ]; then install_phpmyadmin; fi
  if [ -f "phpmyadmin/config.inc.php" ] && [ ! -f "/usr/share/phpmyadmin/config.inc.php" ]; then configure_phpmyadmin; fi
  if [ -f "/usr/share/phpmyadmin/config.inc.php" ]; then configure_phpmyadmin_blowfish; fi
  if [ -f "apache2/phpmyadmin.conf" ] && [ ! -f "/etc/apache2/conf-available/phpmyadmin.conf" ]; then configure_awstats_apache; fi

  # AWStats related stuff.
  if [ ! -d "/usr/share/awstats-7.3" ]; then install_awstats; fi
  if [ -f "apache2/awstats.conf" ] && [ ! -f "/etc/apache2/conf-available/awstats.conf" ]; then configure_awstats_apache; fi

  # Install system scripts.
  install_system_scripts;

  # Restart Apache now that we’re done.
  sudo -E service apache2 restart;

fi

# Get the Java stuff set.
if [ "${PROV_JAVA}" = true ]; then

  # Install and configure Java.
  hash java 2>/dev/null || { install_java; }

fi

# Get the Solr stuff set.
if [ "${PROV_SOLR}" = true ]; then

  # Install and configure Solr.
  install_solr;

fi

# Get the Elasticsearch stuff set.
if [ "${PROV_ELASTICSEARCH}" = true ]; then

  # Install and configure ElasticSearch.
  install_elasticsearch;
  configure_elasticsearch;

fi

# Get the Mongo stuff set.
if [ "${PROV_MONGO}" = true ]; then

  # Install and configure MongoDB.
  hash mongo 2>/dev/null && hash mongod 2>/dev/null || {
    install_mongo26;
    # install_mongo34;
    configure_mongo;
  }

fi

# Get the NodeJS stuff set.
if [ "${PROV_NODEJS}" = true ]; then

  # Install and configure NodeJS and NPM.
  hash node 2>/dev/null || { install_nodejs; }

  # Setup the NodeJS application deployment environment.
  if [ ! -d "/opt/webapps" ]; then set_application_deployment_directories; fi

fi

# Get the Nginx stuff set.
if [ "${PROV_NGINX}" = true ]; then

  # Install and configure Nginx.
  hash nginx 2>/dev/null || { install_nginx; }

fi

# Update the locate database.
update_locate_db;
