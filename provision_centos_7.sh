#!/bin/bash

##########################################################################################
#
# Provision CentOS 7 (provision_centos_7.sh) (c) by Jack Szwergold
#
# Provision CentOS 7 is licensed under a
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

PROVISION_LAMP=false;
if [ -n "$9" ]; then PROVISION_LAMP="${9}"; fi
# Output a provisioning message.
echo -e "\033[33;1mPROVISIONING: LAMP provisioning: '${PROVISION_LAMP}'.\033[0m";

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
  sudo -E usermod -g www-readwrite "${USER_NAME}";

  # Add the user to the 'www-readwrite' group.
  sudo -E usermod -a -G www-readwrite "${USER_NAME}";

  # Changing the username/password combination.
  echo "${USER_NAME}:${PASSWORD}" | sudo -E sudo chpasswd;

} # configure_user_and_group

##########################################################################################
# Environment
##########################################################################################
function set_environment () {

  # Go into the config directory.
  cd "${BASE_DIR}/${CONFS_DIR}";

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Setting the selected editor.\033[0m";

  # Set the selected editor to be Nano.
  echo 'export VISUAL="nano"'$'\r' >> ~/.bash_profile;
  echo 'export EDITOR="nano"'$'\r' >> ~/.bash_profile;

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Importing the crontab.\033[0m";

  # Importing the crontab.
  sudo -E sed -i "s/vagrant.local/${HOST_NAME}/g" "crontab.conf";
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
# Avahi
##########################################################################################
function install_avahi () {

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Avahi related stuff.\033[0m";

  # Install Avahi.
  sudo -E yum install -y -q avahi;

  # Enable EPEL (Extra Packages for Enterprise Linux)
  sudo sed -i "s/enabled=0/enabled=1/g" "/etc/yum.repos.d/epel.repo";

  # Install NSS support for mDNS which is required by Avahi.
  sudo -E yum install -y -q nss-mdns;

  # Start the system messagebus.
  sudo -E service messagebus restart;

  # Start Avahi daemon.
  sudo -E service avahi-daemon start;

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
  sudo -E yum install -y -q sysstat;

  # Restart Sysstat.
  sudo -E service sysstat restart;

} # install_sysstat

##########################################################################################
# Basic Tools
##########################################################################################
function install_basic_tools () {

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Installing a set of generic tools.\033[0m";

  # Install basic repo stuff.
  sudo -E yum install -y -q epel-release deltarpm;

  # Install generic tools.
  sudo -E yum install -y -q \
    bind-utils dnsutils traceroute nmap bc htop finger curl whois rsync lsof \
    iftop figlet lynx mtr-tiny iperf nload zip unzip attr sshpass \
    dkms mc elinks dos2unix p7zip-full nfs-common \
    slurm sharutils uuid-runtime chkconfig quota pv trickle ntp \
    virtualbox-dkms \
    nano man man-pages;

} # install_basic_tools

##########################################################################################
# Locate
##########################################################################################
function install_locate () {

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Installing the locate tool and updating the database.\033[0m";

  # Install Locate.
  sudo -E yum install -y -q mlocate;

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
  sudo -E yum groupinstall -y -q "Development Tools";

} # install_compiler

##########################################################################################
# Git
##########################################################################################
function install_git () {

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Installing Git and related stuff.\033[0m";

  # Purge any already installed version of Git.
  sudo -E yum remove -y -q git;

  # Now install Git via WANDisco.
  sudo -E yum install -y -q "http://opensource.wandisco.com/centos/6/git/x86_64/wandisco-git-release-6-1.noarch.rpm" 2>/dev/null;
  sudo -E yum install -y -q git;

} # install_git

##########################################################################################
# Postfix and Mail
##########################################################################################
function install_postfix () {

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Installing Postfix and related mail stuff.\033[0m";

  # Install postfix and general mail stuff.
  sudo -E yum install -y -q postfix cyrus-sasl cyrus-imapd mailx;

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

  # Install basic repo stuff.
  sudo -E yum install -y -q epel-release deltarpm;

  # Install figlet.
  sudo -E yum install -y -q figlet;

  # Set the server login banner with figlet.
  MOTD_PATH="/etc/motd";
  echo "$(figlet ${MACHINE_NAME} | head -n -1).local" > "${MOTD_PATH}";
  echo "" >> "${MOTD_PATH}";

} # configure_motd

##########################################################################################
# Apache
##########################################################################################
function install_apache () {

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Installing Apache and PHP related items.\033[0m";

  # Install the base Apache related items.
  sudo -E yum install -y -q httpd mod_ssl apachetop;

  # Install other PHP related related items.
  sudo -E yum install -y -q php php-common \
    php-mysqlnd php-pgsql php-odbc \
    php-xmlrpc php-json php-xsl php-curl \
    php-ldap php-mcrypt \
    php-pspell php-gmp php-gd php-mbstring;

  # Install PHP Pear and PHP development stuff.
  sudo -E yum install -y -q php-pear php-devel;

  # Update the Pear/PECL channel stuff.
  sudo -E pecl channel-update pecl.php.net;

  # TODO: Stop and disable FirewallD (aka: IPTables). (Note this shouldn’t be here; set a separate function.)
  sudo -E systemctl stop firewalld;
  sudo -E systemctl disable firewalld;

  # Restart Apache.
  sudo -E service httpd restart;

  # Set MySQL to start on reboot.
  sudo -E systemctl enable httpd.service;
  # sudo -E chkconfig --add httpd;
  # sudo -E chkconfig --level 345 httpd on;

} # install_apache

##########################################################################################
# Oracle OCI8 Instant Client
##########################################################################################
function install_instantclient () {

  # Go into the config directory.
  cd "${BASE_DIR}/${BINS_DIR}";

  if ls oracle-instantclient* 1> /dev/null 2>&1; then

    # Output a provisioning message.
    echo -e "\033[33;1mPROVISIONING: Oracle OCI8 Instant Client.\033[0m";

    # Set the 'EXISTS' value to 'false'.
    EXISTS=false;

    # Loop through the files.
    for FULL_PATH in oracle-instantclient*; do

      if [ -f "${FULL_PATH}" ]; then

        # Install the RPMs
        sudo -E rpm -U "${FULL_PATH}";

        # Set the 'EXISTS' value to 'true'.
        EXISTS=true;

      fi

    done

    if [ "$EXISTS" = true ]; then

      # Install the OCI8 module.
      printf "\n" | sudo -E pecl install -f oci8-2.0.12 >/dev/null 2>&1;

      # Add the OCI8 extention to the PHP config.
      sudo -E sh -c "printf '\n[OCI8]\nextension=oci8.so\n' >> /etc/php.ini";

      # Restart Apache.
      sudo -E service httpd restart;

    fi

  fi

} # install_instantclient

##########################################################################################
# Apache configure.
##########################################################################################
function configure_apache () {

  # Go into the config directory.
  cd "${BASE_DIR}/${CONFS_DIR}";

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Setting Apache and PHP configs.\033[0m";

  # Copy the Apache config files into place.
  sudo -E cp -f "httpd-centos-7/httpd.conf" "/etc/httpd/conf/httpd.conf";
  sudo -E cp -f "httpd-centos-7/httpd" "/etc/sysconfig/httpd";

  # Copy and configure the Apache virtual host config file.
  sudo -E sed -i "s/vagrant.local/${HOST_NAME}/g" "/etc/httpd/conf/httpd.conf";
  HOST_NAME_ESCAPED=$(echo "${HOST_NAME}" | sed "s/\./\\\\./g");
  sudo -E sed -i "s/vagrant\\\.local/${HOST_NAME_ESCAPED}/" "/etc/httpd/conf/httpd.conf";

  # Copy the PHP config files into place.
  sudo -E cp -f "php/php.ini" "/etc/php.ini";

  # Set the user’s main group to be the 'www-readwrite' group.
  sudo -E usermod -g www-readwrite apache;

  # Add the user to the 'www-readwrite' group.
  sudo -E usermod -a -G www-readwrite apache;

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
  sudo -E chown -f -R "${USER_NAME}":www-readwrite "/var/www/html/";
  sudo -E chmod -f -R 775 "/var/www/html/";
  sudo -E chmod g+s "/var/www/html/";
  sudo -E cp -f "httpd-centos-7/index.php" "/var/www/html/index.php";
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
  sudo -E chown -f -R "${USER_NAME}":www-readwrite "/var/www/"{builds,configs,content};
  sudo -E chmod -f -R 775 "/var/www/"{builds,configs,content};
  sudo -E chmod g+s "/var/www/"{builds,configs,content};

} # set_apache_deployment_directories

##########################################################################################
# Set the deployment user.
##########################################################################################
function set_deployment_user () {

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Creating the deployment user.\033[0m";

  # Create the user.
  sudo -E adduser deploy;

  # Create the 'www-readwrite' group.
  sudo -E groupadd -f www-readwrite;

  # Set the user’s main group to be the 'www-readwrite' group.
  sudo -E usermod -g www-readwrite deploy;

  # Add the user to the 'www-readwrite' group.
  sudo -E usermod -a -G www-readwrite deploy;

  # Change the username/password combination.
  echo "deploy:deploy" | sudo -E sudo chpasswd;

} # set_deployment_user

##########################################################################################
# Set application configs.
##########################################################################################
function set_application_configs () {

  # Go into the config directory.
  cd "${BASE_DIR}/${CONFS_DIR}";

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Setting applictaion configs.\033[0m";

  if [ -d "local/" ]; then

    # Create the sandbox config directory.
    sudo -E mkdir -p "/var/www/configs/sandbox/";

    # Copy the local configs into the sandbox config directory.
    sudo -E cp -f "local/"* "/var/www/configs/sandbox/";

  fi

} # set_application_configs

##########################################################################################
# Apache log rotation.
##########################################################################################
function configure_apache_log_rotation () {

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Adjusting the Apache log rotation script.\033[0m";

  # Adjust log rotation stuff.
  sudo -E sed -i "s/rotate 52/rotate 13/g" "/etc/logrotate.d/httpd";
  sudo -E sed -i "s/create 640 root adm/create 640 root www-readwrite/g" "/etc/logrotate.d/httpd";

  # Adjust permissions on log files.
  sudo -E chmod o+rx "/var/log/httpd";
  sudo -E chgrp www-readwrite "/var/log/httpd/"*;
  sudo -E chmod -f 664 "/var/log/httpd/"*;

} # configure_apache_log_rotation

##########################################################################################
# Apache virtual host directories.
##########################################################################################
function set_apache_virtual_host_directories () {

  # Go into the config directory.
  cd "${BASE_DIR}/${CONFS_DIR}";

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Creating the web server document root directories.\033[0m";

  # Set up the Apache virtual host directories.
  sudo -E mkdir -p "/var/www/html/${HOST_NAME}/site";
  sudo -E cp -f "httpd-centos-7/index.php" "/var/www/html/${HOST_NAME}/site/index.php";
  sudo -E chown -f -R "${USER_NAME}:www-readwrite" "/var/www/html/${HOST_NAME}";
  sudo -E chmod -f -R 775 "/var/www/html/${HOST_NAME}";
  sudo -E chmod g+s "/var/www/html/${HOST_NAME}";
  sudo -E chmod -f 664 "/var/www/html/${HOST_NAME}/site/index.php";

} # set_apache_virtual_host_directories

##########################################################################################
# MySQL
##########################################################################################
function install_mysql () {

  # Go into the config directory.
  cd "${BASE_DIR}/${CONFS_DIR}";

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Installing and configuring MySQL related items.\033[0m";

  # Adding the official MySQL repository to get MySQL 5.5 installed.
  sudo -E rpm -U "http://repo.mysql.com/mysql-community-release-el7-5.noarch.rpm" 2>/dev/null;

  # Install the MySQL server and client.
  sudo -E RUNLEVEL=1 yum install -y -q mysql mysql-server;

  # Start MySQL.
  sudo -E service mysqld start;

  # Secure the MySQL installation.
  if [ -f "mysql-centos-7/mysql_secure_installation.sql" ]; then
    mysql -sfu root < "mysql-centos-7/mysql_secure_installation.sql";
  fi

  # Restart MySQL.
  sudo -E service mysqld restart;

  # Set MySQL to start on reboot.
  sudo -E systemctl enable mysql.service;
  # sudo -E chkconfig --add mysql;
  # sudo -E chkconfig --level 345 mysql on;

} # install_mysql

##########################################################################################
# MariaDB (MySQL Clone)
##########################################################################################
function install_mariadb () {

  # Go into the config directory.
  cd "${BASE_DIR}/${CONFS_DIR}";

  # Output a provisioning message.
  echo -e "\033[33;1mPROVISIONING: Installing and configuring MariaDB related items.\033[0m";

  # Setup the MariaDB repository.
  if [ -f "mysql-centos-7/mariadb55.repo" ]; then

    # Copy the MariaDB repo definition to the Yum repos directory.
    sudo -E cp -f "mysql-centos-7/mariadb55.repo" "/etc/yum.repos.d/";

    # Clean the Yum repo cache.
    sudo yum -y -q clean all;

  fi

  # Install the MariaDB MySQL server and client.
  sudo -E RUNLEVEL=1 yum install -y -q MariaDB-client MariaDB-server;

  # Start MySQL.
  sudo -E service mysql start;

  # Secure the MySQL installation.
  if [ -f "mysql-centos-7/mysql_secure_installation.sql" ]; then
    mysql -sfu root < "mysql-centos-7/mysql_secure_installation.sql";
  fi

  # Restart MySQL.
  sudo -E service mysql restart;

  # Set MySQL to start on reboot.
  # sudo -E systemctl enable mysql.service;
  sudo -E chkconfig --add mysql;
  sudo -E chkconfig --level 345 mysql on;

} # install_mariadb

##########################################################################################
# MySQL configure.
##########################################################################################
function configure_mysql () {

  # Go into the base directory.
  cd "${BASE_DIR}";

  # Import any databases that were sent over as the part of the provisioning process.
  if [ -d "${DBS_DIR}" ]; then
    find "${DBS_DIR}" -type f -name "*.sql" | sort |\
      while read db_backup_path
      do
      	if [ -f "${db_backup_path}" ]; then
      	  db_dirname=$(dirname "${db_backup_path}");
      	  db_basename=$(basename "${db_backup_path}");
      	  db_filename="${db_basename%.*}";
      	  mysql_db=$(basename "${db_dirname}");
          # Output a provisioning message.
          echo -e "\033[33;1mPROVISIONING: Restoring the '${mysql_db}' MySQL database.\033[0m";
      	  db_filename_prefix=${db_filename%-*};
      	  if [ "$db_filename_prefix" == "000" ]; then
            # Output a provisioning message.
            echo -e "\033[33;1mPROVISIONING: Importing '${db_backup_path}'.\033[0m";
            mysql -uroot -proot <${db_backup_path};
          else
            # Output a provisioning message.
            echo -e "\033[33;1mPROVISIONING: Importing '${db_backup_path}'.\033[0m";
            mysql -uroot -proot "${mysql_db}" <"${db_backup_path}";
      	  fi
      	else
      	  exit 1;
      	fi
      done
  fi

} # configure_mysql

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
  sudo -E mkdir -p "/opt/mysql_backup";
  sudo -E chown root:www-readwrite "/opt/mysql_backup";
  sudo -E chmod 775 "/opt/mysql_backup";
  sudo -E chmod g+s "/opt/mysql_backup";

} # install_system_scripts

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
set_environment;
hash sar 2>/dev/null || { install_sysstat; }
hash updatedb 2>/dev/null || { install_locate; }
configure_motd;

# Get the basics set.
if [ "${PROVISION_BASICS}" = true ]; then

  install_basic_tools;
  hash libtool 2>/dev/null || { install_compiler; }
  install_git;
  install_postfix;
  # if [ -f "system/login.defs" ] && [ -f "/etc/login.defs" ]; then configure_login_defs; fi
  # if [ -f "system/common-session" ] && [ -f "/etc/pam.d/common-session" ]; then configure_common_session; fi
  # if [ -f "ssh/ssh_config" ] && [ -f "/etc/ssh/ssh_config" ]; then configure_ssh; fi

fi

# Timezone and related stuff.
set_timezone;

# Avahi
hash avahi-daemon 2>/dev/null || { install_avahi; }

# Get the LAMP stuff set.
if [ "${PROVISION_LAMP}" = true ]; then

  # Apache related stuff.
  hash apachectl 2>/dev/null || { install_apache; }
  sudo -E service httpd stop;
  configure_apache;
  install_instantclient;
  if [ -d "/var/www/html" ]; then set_apache_web_root; fi
  if [ ! -d "/var/www/builds" ]; then set_apache_deployment_directories; fi
  set_deployment_user;
  if [ -d "/var/www/configs" ]; then set_application_configs; fi
  if [ ! -d "/var/www/html/${HOST_NAME}" ]; then set_apache_virtual_host_directories; fi
  # if [ -f "/etc/logrotate.d/httpd" ]; then configure_apache_log_rotation; fi

  # MySQL related stuff.
  # hash mysql 2>/dev/null && hash mysqld 2>/dev/null || { install_mysql; }
  hash mysql 2>/dev/null && hash mysqld 2>/dev/null || { install_mariadb; }
  configure_mysql;

  # Install system scripts.
  install_system_scripts;

  # Restart Apache now that we’re done.
  sudo -E service httpd restart;

fi

# Update the locate database.
update_locate_db;
