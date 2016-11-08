#!/bin/bash

##########################################################################################
#
# Provision Basics (provision_basics.sh) (c) by Jack Szwergold
#
# Provision Basics is licensed under a
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

  #echo -e "PROVISIONING: Importing the crontab.\n";

  # Importing the crontab.
  # sudo -E crontab < "crontab.conf";

} # set_environment

##########################################################################################
# Timezone
##########################################################################################
function set_timezone () {

  TIMEZONE="America/New_York";
  TIMEZONE_PATH="/usr/share/zoneinfo";

  echo -e "PROVISIONING: Setting timezone data.\n";

  sudo -E ln -f -s "${TIMEZONE_PATH}"/"${TIMEZONE}" /etc/localtime

} # set_timezone

##########################################################################################
# Avahi
##########################################################################################
function install_avahi () {

  echo -e "PROVISIONING: Avahi related stuff.\n";

  # Install Avahi.
  sudo -E yum install -y -q avahi;

  # Install NSS support for mDNS.
  # curl -ss -O -L "https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm";
  # sudo rpm -i epel-release-latest-6.noarch.rpm;
  # sudo rm epel-release-latest-6.noarch.rpm;
  sudo sed -i 's/enabled=0/enabled=1/g' /etc/yum.repos.d/epel.repo;

  # Now actually instal mDNS.
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
  sudo -E aptitude install -y --assume-yes -q sysstat;

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
  sudo -E aptitude install -y --assume-yes -q \
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
# Postfix and Mail
##########################################################################################
function install_postfix () {

  echo -e "PROVISIONING: Installing Postfix and related mail stuff.\n";

  # Install postfix and general mail stuff.
  debconf-set-selections <<< "postfix postfix/mailname string ${HOST_NAME}";
  debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'";
  sudo -E aptitude install -y --assume-yes -q postfix mailutils;

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
# IPTables and IPSet
##########################################################################################
function install_iptables () {

  echo -e "PROVISIONING: IPTables and IPSet stuff.\n";

  # Install IPTables and IPSet stuff.
  debconf-set-selections <<< "iptables-persistent iptables-persistent/autosave_v4 boolean true";
  debconf-set-selections <<< "iptables-persistent iptables-persistent/autosave_v6 boolean true";
  sudo -E aptitude install -y --assume-yes -q iptables iptables-persistent ipset;

  # Go into the config directory.
  cd "${BASE_DIR}/${CONFIG_DIR}";

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

  echo -e "PROVISIONING: Installing Apache and PHP related items.\n"

  # Install the base Apache related items.
  sudo -E RUNLEVEL=1 aptitude install -y --assume-yes -q \
    apache2 apache2-dev php5 \
    libapache2-mod-php5 php-pear;

  # Install other PHP related related items.
  sudo -E RUNLEVEL=1 aptitude install -y --assume-yes -q \
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

  echo -e "PROVISIONING: Setting Apache and PHP configs.\n";

  # Go into the config directory.
  cd "${BASE_DIR}/${CONFIG_DIR}";

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

  echo -e "PROVISIONING: Adjusting the Apache root directory and default file.\n";

  # Go into the config directory.
  cd "${BASE_DIR}/${CONFIG_DIR}";

  sudo -E rm -rf "/var/www/html";
  sudo -E cp -f "apache2/index.php" "/var/www/index.php";

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
# Apache virtual host directories.
##########################################################################################
function set_apache_virtual_host_directories () {

  echo -e "PROVISIONING: Creating the web server document root directories.\n";

  # Go into the config directory.
  cd "${BASE_DIR}/${CONFIG_DIR}";

  sudo -E mkdir -p "/var/www/${HOST_NAME}/site";
  sudo -E cp -f "apache2/index.php" "/var/www/${HOST_NAME}/site/index.php";
  sudo -E chown -f -R "${USER_NAME}":www-readwrite "/var/www/${HOST_NAME}";
  sudo -E chmod -f -R 775 "/var/www/${HOST_NAME}";
  sudo -E chmod -f -R 664 "/var/www/${HOST_NAME}/site/index.php";

} # set_apache_virtual_host_directories

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
  sudo -E chmod 644 /var/log/apache2/*;

} # configure_apache_log_rotation

##########################################################################################
# MySQL
##########################################################################################
function install_mysql () {

  echo -e "PROVISIONING: Installing and configuring MySQL related items.\n";

  # Install the MySQL server and client.
  sudo -E RUNLEVEL=1 aptitude install -y --assume-yes -q mysql-server mysql-client;

  # Go into the config directory.
  cd "${BASE_DIR}/${CONFIG_DIR}";

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

  echo -e "PROVISIONING: Installing and configuring Munin related items.\n";

  # Install Munin.
  sudo -E RUNLEVEL=1 aptitude install -y --assume-yes -q munin munin-node munin-plugins-extra libwww-perl;

  # Go into the config directory.
  cd "${BASE_DIR}/${CONFIG_DIR}";

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
  sudo -E munin-check --fix-permissions;

  # Restart the Munin node.
  sudo -E service munin-node restart;

} # install_munin

##########################################################################################
# Munin Apache config.
##########################################################################################
function configure_munin_apache () {

  echo -e "PROVISIONING: Installing the Apache Munin config.\n";

  # Go into the config directory.
  cd "${BASE_DIR}/${CONFIG_DIR}";

  sudo -E rm -f "/etc/apache2/conf-available/munin.conf";
  sudo -E cp -f "apache2/munin.conf" "/etc/apache2/conf-available/munin.conf";
  sudo -E a2enconf -q munin;
  # sudo -E service apache2 restart;

} # configure_munin_apache

##########################################################################################
# Munin Apache config enable.
##########################################################################################
function enable_munin_apache () {

  echo -e "PROVISIONING: Enabling the Apache Munin config.\n";

  sudo -E a2enconf -q munin;
  # sudo -E service apache2 restart;

}  # enable_munin_apache

##########################################################################################
# phpMyAdmin
##########################################################################################
function install_phpmyadmin () {

  echo -e "PROVISIONING: Installing phpMyAdmin related items.\n";

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

  echo -e "PROVISIONING: Configuring phpMyAdmin related items.\n";

  # Go into the config directory.
  cd "${BASE_DIR}/${CONFIG_DIR}";

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

    echo -e "PROVISIONING: Setting a new phpMyAdmin blowfish secret value.\n";

    BLOWFISH_SECRET=$(openssl rand -base64 30);
    sudo -E sed -i "s|'a8b7c6d'|'${BLOWFISH_SECRET}'|g" "/usr/share/phpmyadmin/config.inc.php";

  fi

} # configure_phpmyadmin_blowfish

##########################################################################################
# phpMyAdmin Apache config.
##########################################################################################
function configure_awstats_apache () {

  echo -e "PROVISIONING: Installing the Apache phpMyAdmin config.\n";

  # Go into the config directory.
  cd "${BASE_DIR}/${CONFIG_DIR}";

  sudo -E cp -f "apache2/phpmyadmin.conf" "/etc/apache2/conf-available/phpmyadmin.conf";
  sudo -E a2enconf -q phpmyadmin;
  # sudo -E service apache2 restart;

}

##########################################################################################
# GeoIP
##########################################################################################
function install_geoip () {

  echo -e "PROVISIONING: Installing the GeoIP binary.\n";

  # Install the core compiler and build options.
  sudo aptitude install -y --assume-yes -q build-essential zlib1g-dev libtool;

  # Install GeoIP from source code.
  cd "${BASE_DIR}";
  curl -ss -O -L "http://www.maxmind.com/download/geoip/api/c/GeoIP-latest.tar.gz";
  tar -xf "GeoIP-latest.tar.gz";
  rm -f "GeoIP-latest.tar.gz";
  cd ./GeoIP*;
  libtoolize -f;
  ./configure;
  make -s;
  sudo -E make --silent install;
  cd "${BASE_DIR}";
  sudo -E rm -rf ./GeoIP*;

} # install_geoip

##########################################################################################
# GeoIP databases.
##########################################################################################
function install_geoip_databases () {

  echo -e "PROVISIONING: Installing the GeoIP databases.\n";

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

  echo -e "PROVISIONING: Installing the AWStats related items.\n";

  # Do this little dance to get things installed.
  cd "${BASE_DIR}";
  curl -ss -O -L "http://prdownloads.sourceforge.net/awstats/awstats-7.3.tar.gz";
  tar -xf "awstats-7.3.tar.gz";
  rm -f "awstats-7.3.tar.gz";
  sudo -E mv -f "awstats-7.3" "/usr/share/awstats-7.3";

  # Set an index page for AWStats.
  sudo -E cp -f "awstats/awstatstotals.php" "/usr/share/awstats-7.3/wwwroot/cgi-bin/index.php";
  sudo -E chmod a+r "/usr/share/awstats-7.3/wwwroot/cgi-bin/index.php";

  # Create the AWStats data directory.
  sudo -E mkdir -p "/usr/share/awstats-7.3/wwwroot/data";
  sudo -E chmod -f g+w "/usr/share/awstats-7.3/wwwroot/data";

  # Now install CPANminus like this.
  hash cpanminus 2>/dev/null || {
    sudo -E aptitude install -y --assume-yes -q cpanminus;
  }

  # With that done, install all of the GeoIP related CPAN modules like this.
  sudo cpanm --install --force --notest --quiet --skip-installed YAML Geo::IP Geo::IPfree Geo::IP::PurePerl URI::Escape Net::IP Net::DNS Net::XWhois Time::HiRes Time::Local;

  # Go into the config directory.
  cd "${BASE_DIR}/${CONFIG_DIR}";

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

  echo -e "PROVISIONING: Installing the Apache AWStats config.\n";

  # Go into the config directory.
  cd "${BASE_DIR}/${CONFIG_DIR}";

  sudo -E cp -f "apache2/awstats.conf" "/etc/apache2/conf-available/awstats.conf";
  sudo -E a2enconf -q awstats;
  # sudo -E service apache2 restart;

} # configure_awstats_apache

##########################################################################################
# Fail2Ban
##########################################################################################
function install_fail2ban () {

  echo -e "PROVISIONING: Fail2Ban related stuff.\n";

  # Install Fail2Ban.
  sudo -E aptitude purge -y --assume-yes -q fail2ban;
  sudo -E aptitude install -y --assume-yes -q gamin libgamin0 python-central python-gamin python-support;
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

  echo -e "PROVISIONING: Installing the Fail2Ban configs.\n";

  # Go into the config directory.
  cd "${BASE_DIR}/${CONFIG_DIR}";

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
# ImageMagick
##########################################################################################
function install_imagemagick () {

  echo -e "PROVISIONING: Installing ImageMagick from source.\n";

  # Install and build the dependencies for ImageMagick.
  sudo -E aptitude install -y --assume-yes -q \
    build-essential checkinstall \
    libx11-dev libxext-dev zlib1g-dev libpng12-dev \
    libjpeg-dev libfreetype6-dev libxml2-dev;
  sudo aptitude build-dep -y --assume-yes -q imagemagick;

  # Build ImageMagick from source code.
  cd "${BASE_DIR}";
  curl -ss -O -L "http://www.imagemagick.org/download/ImageMagick.tar.gz";
  tar -xf "ImageMagick.tar.gz";
  rm -f "ImageMagick.tar.gz";
  cd ./ImageMagick-*;
  ./configure;
  sudo checkinstall -y;

  # Install ImageMagick from the DEB package.
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
# hash sar 2>/dev/null || {  install_sysstat; }
#hash updatedb 2>/dev/null || { install_locate; }
# configure_motd;

# Get the basics set.
if [ "${PROVISION_BASICS}" = true ]; then

  # Go into the config directory.
  cd "${BASE_DIR}/${CONFIG_DIR}";

  install_basic_tools;
  hash libtool 2>/dev/null || { install_compiler; }
  if ! grep -q -s "git-core" /etc/apt/sources.list /etc/apt/sources.list.d/*; then install_git; fi
  hash postfix 2>/dev/null || { install_postfix; }
  if [ -f "system/login.defs" ] && [ -f "/etc/login.defs" ]; then configure_login_defs; fi
  if [ -f "system/common-session" ] && [ -f "/etc/pam.d/common-session" ]; then configure_common_session; fi
  if [ -f "ssh/ssh_config" ] && [ -f "/etc/ssh/ssh_config" ]; then configure_ssh; fi

fi

# Monit
# hash monit 2>/dev/null || { install_monit; }
# if [ -f "monit/monitrc" ]; then configure_monit; fi

# Update the locate database.
# update_locate_db;
