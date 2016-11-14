#!/bin/bash

##########################################################################################
#
# Provision CentOS LAMP (provision_centos_lamp.sh) (c) by Jack Szwergold
#
# Provision CentOS LAMP is licensed under a
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
#          2016-09-25, js: simplifying things
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

##########################################################################################
# Optional items.
##########################################################################################

PROVISION_BASICS=false;
if [ -n "$6" ]; then PROVISION_BASICS="${6}"; fi
echo -e "PROVISIONING: Basics provisioning: '${PROVISION_BASICS}'.\n";

PROVISION_LAMP=true;
if [ -n "$7" ]; then PROVISION_LAMP="${7}"; fi
echo -e "PROVISIONING: LAMP provisioning: '${PROVISION_LAMP}'.\n";

# Go into the config directory.
cd "${BASE_DIR}/${CONFIG_DIR}";

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
  sudo -E usermod -a -G www-readwrite "${USER_NAME}" ;

} # configure_user_and_group

##########################################################################################
# Environment
##########################################################################################
function set_environment () {

  echo -e "PROVISIONING: Setting the selected editor.\n";

  # Set the selected editor to be Nano.
  echo 'export VISUAL="nano"'$'\r' >> ~/.bash_profile;
  echo 'export EDITOR="nano"'$'\r' >> ~/.bash_profile;

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

  # Set the timezone variables.
  TIMEZONE="America/New_York";
  TIMEZONE_PATH="/usr/share/zoneinfo";

  echo -e "PROVISIONING: Setting timezone data.\n";

  # Set the actual timezone via a symbolic link.
  sudo -E ln -f -s "${TIMEZONE_PATH}"/"${TIMEZONE}" "/etc/localtime";

} # set_timezone

##########################################################################################
# Avahi
##########################################################################################
function install_avahi () {

  echo -e "PROVISIONING: Avahi related stuff.\n";

  # Install Avahi.
  sudo -E yum install -y -q avahi;

  # Enable EPEL (Extra Packages for Enterprise Linux)
  sudo sed -i 's/enabled=0/enabled=1/g' /etc/yum.repos.d/epel.repo;

  # Install NSS support for mDNS which is required by Avahi.
  sudo -E yum install -y -q nss-mdns;

  # Start the system messagebus.
  sudo -E service messagebus restart;

  # Start Avahi daemon.
  sudo service avahi-daemon start

} # install_avahi

##########################################################################################
# Sysstat
##########################################################################################
function install_sysstat () {

  echo -e "PROVISIONING: Sysstat related stuff.\n";

  # Install Sysstat.
  sudo -E yum install -y -q sysstat;

  # Enable Sysstat.
  # sudo sed -i 's/ENABLED="false"/ENABLED="true"/g' /etc/sysconfig/sysstat;

  # Restart Sysstat.
  sudo -E service sysstat restart;

} # install_sysstat

##########################################################################################
# Basic Tools
##########################################################################################
function install_basic_tools () {

  echo -e "PROVISIONING: Installing a set of generic tools.\n";

  # Install generic tools.
  sudo -E yum install -y -q \
    dnsutils traceroute nmap bc htop finger curl whois rsync lsof \
    iftop figlet lynx mtr-tiny iperf nload zip unzip attr sshpass \
    dkms mc elinks ntp dos2unix p7zip-full nfs-common \
    slurm sharutils uuid-runtime chkconfig quota pv trickle apachetop \
    virtualbox-dkms nano;

} # install_basic_tools

##########################################################################################
# Locate
##########################################################################################
function install_locate () {

  echo -e "PROVISIONING: Installing the locate tool and updating the database.\n";

  # Install Locate.
  sudo -E yum install -y -q mlocate;

  # Update Locate.
  sudo -E updatedb;

} # install_locate

##########################################################################################
# Compiler
##########################################################################################
function install_compiler () {

  echo -e "PROVISIONING: Installing the core compiler tools.\n";

  # Install the core compiler and build tools.
  sudo -E yum groupinstall -y -q 'Development Tools';

} # install_compiler

##########################################################################################
# Git
##########################################################################################
function install_git () {

  echo -e "PROVISIONING: Installing Git and related stuff.\n";

  # Purge any already installed version of Git.
  sudo -E yum remove -y -q git;

  # Now install Git via WANDisco.
  sudo -E yum install -y -q "http://opensource.wandisco.com/centos/6/git/x86_64/wandisco-git-release-6-1.noarch.rpm";
  sudo -E yum install -y -q git;

} # install_git

##########################################################################################
# Postfix and Mail
##########################################################################################
function install_postfix () {

  echo -e "PROVISIONING: Installing Postfix and related mail stuff.\n";

  # Install postfix and general mail stuff.
  sudo -E yum install -y -q postfix;
  sudo -E yum install -y -q cyrus-sasl;
  sudo -E yum install -y -q cyrus-imapd;
  sudo -E yum install -y -q mailx;

} # install_postfix

##########################################################################################
# Setting the 'login.defs' config file.
##########################################################################################
function configure_login_defs () {

  echo -e "PROVISIONING: Setting the 'login.defs' config file.\n";

  # Copy the 'login.defs' file in place.
  sudo -E cp -f "system/login.defs" "/etc/login.defs";

} # configure_login_defs

##########################################################################################
# Setting the 'common-session' config file.
##########################################################################################
function configure_common_session () {

  echo -e "PROVISIONING: Setting the 'common-session' config file.\n";

  # Go into the config directory.
  cd "${BASE_DIR}/${CONFIG_DIR}";

  # Copy the 'login.defs' file in place.
  sudo -E cp -f "system/common-session" "/etc/pam.d/common-session";

} # configure_common_session

##########################################################################################
# SSH configure.
##########################################################################################
function configure_ssh () {

  echo -e "PROVISIONING: Setting the SSH config file.\n";

  # Go into the config directory.
  cd "${BASE_DIR}/${CONFIG_DIR}";

  # Copy the 'login.defs' file in place.
  sudo -E cp -f "ssh/ssh_config" "/etc/ssh/ssh_config";

} # configure_ssh

##########################################################################################
# MOTD
##########################################################################################
function configure_motd () {

  echo -e "PROVISIONING: Setting the MOTD banner.\n";

  # Install figlet.
  sudo -E yum install -y -q figlet;

  # Set the server login banner with figlet.
  MOTD_PATH="/etc/motd";
  # echo "$(figlet ${MACHINE_NAME^} | head -n -1).local" > "${MOTD_PATH}";
  echo "$(figlet ${MACHINE_NAME} | head -n -1).local" > "${MOTD_PATH}";
  echo "" >> "${MOTD_PATH}";

} # configure_motd

##########################################################################################
# Apache
##########################################################################################
function install_apache () {

  echo -e "PROVISIONING: Installing Apache and PHP related items.\n"

  # Install the base Apache related items.
  sudo -E yum install -y httpd mod_php mod_ssl;

  # Install other PHP related related items.
  sudo -E yum install -y \
		php-mysql php-pgsql php-odbc \
		php-xmlrpc php-json php-xsl php-curl \
		php-getid3 php-imap php-ldap php-mcrypt \
		php-pspell php-gmp php-gd;

  # Enable the PHP mcrypt module.
  # sudo -E php5enmod mcrypt;

  # Enable these core Apache modules.
  # sudo -E a2enmod -q rewrite headers expires include proxy proxy_http cgi;

  # Set Apache to start on reboot.
  sudo chkconfig --add httpd;
  sudo chkconfig --level 345 httpd on;

  # TODO: Stop and disable IPTables. (Note this shouldn’t be here; set a separate function.)
  sudo -E service iptables stop;
  sudo -E chkconfig iptables off;

  # Restart Apache.
  sudo -E service httpd restart;

} # install_apache

##########################################################################################
# Apache configure.
##########################################################################################
function configure_apache () {

  echo -e "PROVISIONING: Setting Apache and PHP configs.\n";

  # Go into the config directory.
  cd "${BASE_DIR}/${CONFIG_DIR}";

  # Copy the Apache config files into place.
  sudo -E cp -f "apache2/httpd.conf" "/etc/httpd/conf/httpd.conf";
  sudo -E cp -f "apache2/httpd" "/etc/sysconfig/httpd";

  # Copy and configure the Apache virtual host config file.
  sudo -E sed -i "s/vagrant.local/${HOST_NAME}/g" "/etc/httpd/conf/httpd.conf";
  HOST_NAME_ESCAPED=$(echo "${HOST_NAME}" | sed 's/\./\\\\./g');
  sudo -E sed -i "s/vagrant\\\.local/${HOST_NAME_ESCAPED}/" "/etc/httpd/conf/httpd.conf";

  # Copy the PHP config files into place.
  sudo -E cp -f "php/php.ini" "/etc/php.ini";

} # configure_apache

##########################################################################################
# Apache web root.
##########################################################################################
function set_apache_web_root () {

  echo -e "PROVISIONING: Adjusting the Apache root directory and default file.\n";

  # Go into the config directory.
  cd "${BASE_DIR}/${CONFIG_DIR}";

  sudo -E chown -f -R "${USER_NAME}":www-readwrite "/var/www/html/";
  sudo -E chmod -f -R 775 "/var/www/html/";
  sudo -E cp -f "apache2/index.php" "/var/www/html/index.php";
  sudo -E chmod -f -R 664 "/var/www/html/index.php";

} # set_apache_web_root

##########################################################################################
# Apache deployment directories.
##########################################################################################
function set_apache_deployment_directories () {

  echo -e "PROVISIONING: Creating the web code deployment directories.\n";

  sudo -E mkdir -p "/var/www/"{builds,configs,content};
  sudo -E chown -f -R "${USER_NAME}":www-readwrite "/var/www/"{builds,configs,content};
  sudo -E chmod -f -R 775 "/var/www/"{builds,configs,content};

} # set_apache_deployment_directories

##########################################################################################
# Set application configs.
##########################################################################################
function set_application_configs () {

  echo -e "PROVISIONING: Setting applictaion configs.\n";

  # Go into the config directory.
  cd "${BASE_DIR}/${CONFIG_DIR}";

  sudo -E cp -f "local/"* "/var/www/configs/";

} # set_application_configs

##########################################################################################
# Apache log rotation.
##########################################################################################
function configure_apache_log_rotation () {

  echo -e "PROVISIONING: Adjusting the Apache log rotation script.\n";

  sudo -E sed -i 's/rotate 52/rotate 13/g' "/etc/logrotate.d/apache2";
  sudo -E sed -i 's/create 640 root adm/create 640 root www-readwrite/g' "/etc/logrotate.d/apache2";

  # Adjust permissions on log files.
  sudo -E chmod o+rx /var/log/apache2;
  sudo -E chgrp www-readwrite /var/log/apache2/*;
  sudo -E chmod -f 664 /var/log/apache2/*;

} # configure_apache_log_rotation

##########################################################################################
# Apache virtual host directories.
##########################################################################################
function set_apache_virtual_host_directories () {

  echo -e "PROVISIONING: Creating the web server document root directories.\n";

  # Go into the config directory.
  cd "${BASE_DIR}/${CONFIG_DIR}";

  sudo -E mkdir -p "/var/www/html/${HOST_NAME}/site";
  sudo -E cp -f "apache2/index.php" "/var/www/html/${HOST_NAME}/site/index.php";
  sudo -E chown -f -R "${USER_NAME}":www-readwrite "/var/www/html/${HOST_NAME}";
  sudo -E chmod -f -R 775 "/var/www/html/${HOST_NAME}";
  sudo -E chmod -f 664 "/var/www/html/${HOST_NAME}/site/index.php";

} # set_apache_virtual_host_directories

##########################################################################################
# MySQL
##########################################################################################
function install_mysql () {

  echo -e "PROVISIONING: Installing and configuring MySQL related items.\n";

  # Install the MySQL server and client.
  sudo -E RUNLEVEL=1 yum install -y mysql-server;

  # Set MySQL to start on reboot.
  sudo chkconfig --add mysqld;
  sudo chkconfig --level 345 mysqld on;

  # Start MySQL.
  sudo service mysqld start;

  # Go into the config directory.
  cd "${BASE_DIR}/${CONFIG_DIR}";

  # Secure the MySQL installation.
  if [ -f "mysql/mysql_secure_installation.sql" ]; then
    mysql -sfu root < "mysql/mysql_secure_installation.sql";
  fi

  # Restart MySQL.
  sudo service mysqld restart;

} # install_mysql

function configure_mysql () {

  # Go into the base directory.
  cd "${BASE_DIR}";

  # Import any databases that were sent over as the part of the provisioning process.
  if [ -d "${DB_DIR}" ]; then
    find "${DB_DIR}" -type f -name "*.sql" | sort |\
      while read db_backup_path
      do
    	if [ -f "${db_backup_path}" ]; then
    	  db_dirname=$(dirname "${db_backup_path}");
    	  db_basename=$(basename "${db_backup_path}");
    	  db_filename="${db_basename%.*}";
    	  # db_extension="${db_basename##*.}";
    	  # db_parent_dir=$(basename "${db_dirname}");
    	  mysql_db=$(basename "${db_dirname}");
    	  echo -e "PROVISIONING: Restoring the '${mysql_db}' MySQL database.\n";
    	  db_filename_prefix=${db_filename%-*};
    	  # db_filename_suffix=${db_filename#*-};
    	  if [ "$db_filename_prefix" == "000" ]; then
          mysql -uroot -proot <${db_backup_path};
        else
          mysql -uroot -proot "${mysql_db}" <"${db_backup_path}";
    	  fi
    	  #
    	else
    	  exit 1;
    	fi
      done
  fi

} # configure_mysql

##########################################################################################
# Monit
##########################################################################################
function install_monit () {

  echo -e "PROVISIONING: Monit related stuff.\n";

  # Install Monit.
  sudo -E RUNLEVEL=1 aptitude install -y --assume-yes -q monit;

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
  sudo -E cp -f "monit/apache2.conf" "/etc/monit/conf.d/apache2.conf";

  # Restart Monit.
  sudo -E service monit restart;

  # Run these commands to prevent Monit from coming up on reboot.
  sudo -E service monit stop;
  sudo -E update-rc.d -f monit remove;

} # configure_monit

##########################################################################################
# Scripts.
##########################################################################################
function install_system_scripts () {

  echo -e "PROVISIONING: Installing configuring various system scripts.\n";

  # Copy and configure various system scripts.
  cd "${BASE_DIR}/${CONFIG_DIR}";
  sudo -E cp -f "scripts/"*.sh "/opt/";
  sudo -E chown -f -R root:root "scripts/"*.sh "/opt/";
  sudo -E sed -i "s/vagrant.local/${HOST_NAME}/g" "/opt/"*.cfg.sh;
  sudo -E chmod -f -R 700 "/opt/"*.sh;

} # install_system_scripts

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
hash avahi-daemon 2>/dev/null || { install_avahi; }
hash sar 2>/dev/null || {  install_sysstat; }
hash updatedb 2>/dev/null || { install_locate; }
configure_motd;

# Get the basics set.
if [ "${PROVISION_BASICS}" = true ]; then

  # Go into the config directory.
  cd "${BASE_DIR}/${CONFIG_DIR}";

  install_basic_tools;
  hash libtool 2>/dev/null || { install_compiler; }
  install_git;
  install_postfix;
  # if [ -f "system/login.defs" ] && [ -f "/etc/login.defs" ]; then configure_login_defs; fi
  # if [ -f "system/common-session" ] && [ -f "/etc/pam.d/common-session" ]; then configure_common_session; fi
  # if [ -f "ssh/ssh_config" ] && [ -f "/etc/ssh/ssh_config" ]; then configure_ssh; fi

fi

# Monit
# hash monit 2>/dev/null || { install_monit; }
# if [ -f "monit/monitrc" ]; then configure_monit; fi

if [ "${PROVISION_LAMP}" = true ]; then

  # Go into the config directory.
  cd "${BASE_DIR}/${CONFIG_DIR}";

  # Apache
  hash apachectl 2>/dev/null || { install_apache; }
  sudo -E service httpd stop;
  configure_apache;
  if [ -d "/var/www/html" ]; then set_apache_web_root; fi
  if [ ! -d "/var/www/builds" ]; then set_apache_deployment_directories; fi
  if [ -d "/var/www/configs" ]; then set_application_configs; fi
  if [ ! -d "/var/www/html/${HOST_NAME}" ]; then set_apache_virtual_host_directories; fi
  # if [ -f "/etc/logrotate.d/apache2" ]; then configure_apache_log_rotation; fi

  # MySQL
  hash mysql && hash mysqld 2>/dev/null || { install_mysql; }
  configure_mysql;

  # Install system scripts.
  install_system_scripts;

  # Restart Apache now that we’re done.
  sudo -E service httpd restart;

fi

# Update the locate database.
update_locate_db;
