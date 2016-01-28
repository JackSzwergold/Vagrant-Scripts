#!/bin/bash

######################################################################################
# Set some basic variables.
######################################################################################

BASE_DIR=$(pwd);
echo -e "PROVISIONING: Base directory is: '${BASE_DIR}'.\n\n";

CONFIG_DIR="config_dir";
echo -e "PROVISIONING: Config directory is: '${CONFIG_DIR}'.\n\n";

cd "${BASE_DIR}"/"${CONFIG_DIR}";

######################################################################################
# DEBIAN_FRONTEND
######################################################################################

echo -e "PROVISIONING: Setting the Debian frontend to non-interactive mode.\n"
export DEBIAN_FRONTEND=noninteractive;

######################################################################################
# User and Group
######################################################################################

echo -e "PROVISIONING: Adjusting user and group related items.\n";

# Create the 'www-readwrite' group.
sudo -E groupadd -f www-readwrite;

# Set the Vagrant users main group to be the 'www-readwrite' group.
sudo -E usermod -g www-readwrite vagrant;

# Add the user to the 'www-readwrite' group:
sudo -E adduser --quiet vagrant www-readwrite;

######################################################################################
# Environment
######################################################################################

echo -e "PROVISIONING: Setting the selected edtor.\n";

# Set the selected editor to Nano.

if [ ! -f "${BASE_DIR}/.selected_editor" ]; then
  echo 'SELECTED_EDITOR="/bin/nano"' > "${BASE_DIR}/.selected_editor";
  sudo -E chown -f vagrant:www-readwrite "${BASE_DIR}/.selected_editor";
fi

echo -e "PROVISIONING: Importing the crontab.\n";

# Importing the crontab.
sudo -E crontab < "crontab.conf";

######################################################################################
# Date and Time
######################################################################################

echo -e "PROVISIONING: Syncing with the time/date server.\n";

# Syncing with the time/date server.
sudo -E ntpdate -u ntp.ubuntu.com;

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


# Edit the sources list.
SOURCES_LIST="/etc/apt/sources.list";
DEB_URL_PATTERN="^#.*deb.*partner$";
if [ -f "${SOURCES_LIST}" ] && grep -E -q "${DEB_URL_PATTERN}" "${SOURCES_LIST}"; then

  echo -e "PROVISIONING: Adjusting the sources list.\n";

  # Adjust the sources list.
  sudo -E sed -i "/${DEB_URL_PATTERN}/s/^# //g" "${SOURCES_LIST}";

fi

######################################################################################
# Avahi
######################################################################################

# Check if Avahi is installed and if not, install it.
hash avahi-daemon 2>/dev/null || {

  echo -e "PROVISIONING: Avahi related stuff.\n";

  # Install Avahi.
  sudo -E aptitude install -y --assume-yes -q avahi-daemon avahi-utils;

}

######################################################################################
# Sysstat
######################################################################################

# Check if Sysstat is installed and if not, install it.
hash sar 2>/dev/null || {

  echo -e "PROVISIONING: Sysstat related stuff.\n";

  # Install Sysstat.
  sudo -E aptitude install -y --assume-yes -q sysstat;

  # Enable Sysstat.
  SYSSTAT_CONFIG_PATH="/etc/default/sysstat";
  SYSSTAT_ENABLED='ENABLED="true"';
  if [ -f "${SYSSTAT_CONFIG_PATH}" ] && ! grep -F -q "${SYSSTAT_ENABLED}" "${SYSSTAT_CONFIG_PATH}"; then
    sudo -E sed -i 's/ENABLED="false"/ENABLED="true"/g' "${SYSSTAT_CONFIG_PATH}";
    sudo -E service sysstat restart;
  fi

}

######################################################################################
# Generic Tools
######################################################################################

echo -e "PROVISIONING: Installing a set of generic tools.\n";

# Install generic tools.
sudo -E aptitude install -y --assume-yes -q \
  dnsutils traceroute nmap bc htop finger curl whois rsync lsof \
  iftop figlet lynx mtr-tiny iperf nload zip unzip attr sshpass \
  dkms mc elinks ntp dos2unix p7zip-full nfs-common imagemagick \
  slurm sharutils uuid-runtime chkconfig quota pv trickle apachetop;

######################################################################################
# Locate
######################################################################################

# Check if Locate is installed and if not, install it.
hash updatedb 2>/dev/null || {

  echo -e "PROVISIONING: Installing the locate tool and updating the database.\n";

  # Install Locate.
  sudo -E aptitude install -y --assume-yes -q mlocate;

  # Update Locate.
  sudo -E updatedb;

}

######################################################################################
# Compiler
######################################################################################

# Check if the core compiler and build tools are installed and if not, install it.
hash libtool 2>/dev/null || {

  echo -e "PROVISIONING: Installing the core compiler tools.\n";

  # Install the core compiler and build tools.
  sudo -E aptitude install -y --assume-yes -q build-essential libtool;

}

######################################################################################
# Git
######################################################################################

# Install Git via PPA.
if ! grep -q -s "git-core" /etc/apt/sources.list /etc/apt/sources.list.d/*; then

  echo -e "PROVISIONING: Installing Git and related stuff.\n";

  # Purge any already installed version of Git.
  sudo -E aptitude purge -y --assume-yes -q git git-core subversion git-svn;

  # Now install Git via PPA.
  sudo -E aptitude install -y --assume-yes -q python-software-properties;
  sudo -E add-apt-repository -y ppa:git-core/ppa;
  sudo -E aptitude update -y --assume-yes -q;
  sudo -E aptitude upgrade -y --assume-yes -q;
  sudo -E aptitude install -y --assume-yes -q git git-core subversion git-svn;

fi

######################################################################################
# Postfix and Mail
######################################################################################

# Check if Postfix and related mail tools are installed and if not, install it.
hash postfix 2>/dev/null || {

  echo -e "PROVISIONING: Installing Postfix and related mail stuff.\n";

  # Install postfix and general mail stuff.
  debconf-set-selections <<< "postfix postfix/mailname string vagrant.local";
  debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'";
  sudo -E aptitude install -y --assume-yes -q postfix mailutils;

}

######################################################################################
# UMASK
######################################################################################

# Set the default UMASK value in 'login.defs' to be 002 instead of 022.
LOGIN_DEFS_PATH="/etc/login.defs";
LOGIN_DEFS_PATTERN="^.*UMASK.*022.*$";
if [ -f "${LOGIN_DEFS_PATH}" ] && grep -E -q "${LOGIN_DEFS_PATTERN}" "${LOGIN_DEFS_PATH}"; then

  echo -e "PROVISIONING: Adjusting the UMASK setting in ${LOGIN_DEFS_PATH}.\n";

  # Adjust the UMASK setting in 'login.defs'.
  sudo -E sed -i "s/${LOGIN_DEFS_PATTERN}/UMASK\t\t002/g" "${LOGIN_DEFS_PATH}";

fi

# Set the default UMASK value in 'common-session' to be 002 instead of 022.
COMMON_SESSION_PATH="/etc/pam.d/common-session";
COMMON_SESSION_PATTERN="^.*session\soptional.*pam_umask.so$";
if [ -f "${COMMON_SESSION_PATH}" ] && grep -E -q "${COMMON_SESSION_PATTERN}" "${COMMON_SESSION_PATH}"; then

  echo -e "PROVISIONING: Adjusting the UMASK setting in ${COMMON_SESSION_PATH}.\n";

  # Adjust the UMASK setting in 'common-session'.
  sudo -E sed -i "s/${COMMON_SESSION_PATTERN}/session optional\t\tpam_umask.so\t\tumask=0002/g" "${COMMON_SESSION_PATH}";

fi

######################################################################################
# SSH
######################################################################################

# Fix for slow SSH client connections.
SSH_CONFIG_PATH="/etc/ssh/ssh_config";
SSH_CONFIG_APPEND="    PreferredAuthentications publickey,password,gssapi-with-mic,hostbased,keyboard-interactive";
if [ -f "${SSH_CONFIG_PATH}" ] && ! grep -F -q "${SSH_CONFIG_APPEND}" "${SSH_CONFIG_PATH}"; then

  echo -e "PROVISIONING: SSH adjustments.\n";

  # Append the new preferred authentications setting to the end of the file.
  # sudo -E grep -F -q "${SSH_CONFIG_APPEND}" "${SSH_CONFIG_PATH}" || echo "${SSH_CONFIG_APPEND}" >> "${SSH_CONFIG_PATH}";
  # echo "${SSH_CONFIG_APPEND}" | sudo tee -a "${SSH_CONFIG_PATH}";
  sudo sh -c "echo '${SSH_CONFIG_APPEND}' >> '${SSH_CONFIG_PATH}'";

fi

######################################################################################
# MOTD
######################################################################################

echo -e "PROVISIONING: Setting the MOTD banner.\n";

# Set the server login banner with figlet.
# MOTD_PATH="/etc/motd.tail";
MOTD_PATH="/etc/motd";
figlet "Vagrant" > "${MOTD_PATH}";
echo "" >> "${MOTD_PATH}";

echo -e "PROVISIONING: Disabling MOTD scripts.\n";

# Disable these MOTD scripts.
sudo -E chmod -f -x "/etc/update-motd.d/50-landscape-sysinfo";
sudo -E chmod -f -x "/etc/update-motd.d/51-cloudguest";
sudo -E chmod -f -x "/etc/update-motd.d/90-updates-available";
sudo -E chmod -f -x "/etc/update-motd.d/91-release-upgrade";
sudo -E chmod -f -x "/etc/update-motd.d/95-hwe-eol";
sudo -E chmod -f -x "/etc/update-motd.d/98-cloudguest";

######################################################################################
# IPTables and IPSet
######################################################################################

# Check if IPTables and IPSet are installed and if not, install it.
hash iptables 2>/dev/null || {

  echo -e "PROVISIONING: IPTables and IPSet stuff.\n";

  # Install IPTables and IPSet stuff.
  debconf-set-selections <<< "iptables-persistent iptables-persistent/autosave_v4 boolean true";
  debconf-set-selections <<< "iptables-persistent iptables-persistent/autosave_v6 boolean true";
  sudo -E aptitude install -y --assume-yes -q iptables iptables-persistent ipset;

  # Load the IPSet stuff if the file exists.
  if [ -f "ipset.conf" ]; then
    sudo -E ipset restore < "ipset.conf";
    sudo -E cp -f "ipset.conf" "/etc/iptables/rules.ipsets";
  fi

  # Load the IPTables stuff if the file exists.
  if [ -f "iptables.conf" ]; then
    sudo -E iptables-restore < "iptables.conf";
    sudo -E cp -f "iptables.conf" "/etc/iptables/rules.v4";
  fi

  # Patch 'iptables-persistent' if the patch exists and the original 'iptables-persistent' exists.
  if [ -f "/etc/init.d/iptables-persistent" ] && [ -f "iptables-persistent-ipset.patch" ]; then
    sudo -E patch -fsb "/etc/init.d/iptables-persistent" < "iptables-persistent-ipset.patch";
  fi

}

######################################################################################
# Apache and PHP (Installing)
######################################################################################

# Check if Apache is installed and if not, install it.
hash apachectl 2>/dev/null || {

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

}

######################################################################################
# Stop Apache while other things happen.
######################################################################################

sudo -E service apache2 stop;

######################################################################################
# Apache and PHP (Configuring)
######################################################################################

# Adjust the PHP config.
PHP_CONFIG_PATH="/etc/php5/apache2/php.ini";
EXPOSE_PHP_PATTERN="^expose_php.*=.*On$";
if [ -f "${PHP_CONFIG_PATH}" ] && grep -E -q "${EXPOSE_PHP_PATTERN}" "${PHP_CONFIG_PATH}"; then

  echo -e "PROVISIONING: Disable 'expose_php'.\n";

  # Harden PHP by disabling 'expose_php'.
  sudo -E sed -i "s/${EXPOSE_PHP_PATTERN}/expose_php = Off/g" "${PHP_CONFIG_PATH}";

fi

OPCACHE_PATTERN="^;opcache.enable=0$";
if [ -f "${PHP_CONFIG_PATH}" ] && grep -E -q "${OPCACHE_PATTERN}" "${PHP_CONFIG_PATH}"; then

  echo -e "PROVISIONING: Disable the PHP 5.5 OPcache.\n";

  # Disable the PHP 5.5 OPcache.
  sudo -E sed -i "s/${OPCACHE_PATTERN}/opcache.enable=0/g" "${PHP_CONFIG_PATH}";

fi

# Adjust the Apache security config.
APACHE_SECURITY_PATH="/etc/apache2/conf-available/security.conf";
APACHE_SERVERTOKENS="^ServerTokens OS$";
if [ -f "${APACHE_SECURITY_PATH}" ] && grep -E -q "${APACHE_SERVERTOKENS}" "${APACHE_SECURITY_PATH}"; then

  echo -e "PROVISIONING: Adjusting the Apache 'ServerTokens' setting.\n";

  # Set 'ServerTokens' to Prod.
  sudo -E sed -i "s/${APACHE_SERVERTOKENS}/ServerTokens Prod/g" "${APACHE_SECURITY_PATH}";

fi

APACHE_SERVERSIGNATURE="^ServerSignature On";
if [ -f "${APACHE_SECURITY_PATH}" ] && grep -E -q "${APACHE_SERVERSIGNATURE}" "${APACHE_SECURITY_PATH}"; then

  echo -e "PROVISIONING: Adjusting the Apache 'ServerSignature' setting.\n";

  # Set 'ServerSignature' to Off.
  sudo -E sed -i "s/${APACHE_SERVERSIGNATURE}/ServerSignature Off/g" "${APACHE_SECURITY_PATH}";

fi

APACHE_TRACEENABLE="^TraceEnable On";
if [ -f "${APACHE_SECURITY_PATH}" ] && grep -E -q "${APACHE_TRACEENABLE}" "${APACHE_SECURITY_PATH}"; then

  echo -e "PROVISIONING: Adjusting the Apache 'TraceEnable' setting.\n";

  # Set 'TraceEnable' to Off.
  sudo -E sed -i "s/${APACHE_TRACEENABLE}/TraceEnable Off/g" "${APACHE_SECURITY_PATH}";

fi

# Adjust the Apache run group and UMASK.
APACHE_ENVVARS_PATH="/etc/apache2/envvars";
APACHE_RUN_GROUP="^export APACHE_RUN_GROUP=www-data";
if [ -f "${APACHE_ENVVARS_PATH}" ] && grep -E -q "${APACHE_RUN_GROUP}" "${APACHE_ENVVARS_PATH}"; then

  echo -e "PROVISIONING: Adjusting Apache group setting.\n";

  # Set 'APACHE_RUN_GROUP' to 'www-readwrite'.
  sudo -E sed -i "s/${APACHE_RUN_GROUP}/export APACHE_RUN_GROUP=www-readwrite/g" "${APACHE_ENVVARS_PATH}";

fi

APACHE_UMASK_APPEND="umask 002";
if [ -f "${APACHE_ENVVARS_PATH}" ] && ! grep -E -q "^${APACHE_UMASK_APPEND}" "${APACHE_ENVVARS_PATH}"; then

  echo -e "PROVISIONING: Adjusting Apache UMASK value.\n";

  # Adjusting Apache UMASK value.
  # sudo -E grep -q -E "${APACHE_UMASK_APPEND}" "${APACHE_ENVVARS_PATH}" || echo -e "\n${APACHE_UMASK_APPEND}" >> "${APACHE_ENVVARS_PATH}";
  sudo sh -c "echo '${APACHE_UMASK_APPEND}' >> '${APACHE_ENVVARS_PATH}'";

fi

# Set the config files for Apache.
APACHE_COMMON_CONFIG_PATH="/etc/apache2/sites-available/common.conf";
if [ ! -f "${APACHE_COMMON_CONFIG_PATH}" ]; then

  echo -e "PROVISIONING: Setting Apache configs.\n";

  # Copy the config files into place.
  sudo -E cp -f "apache2/apache2.conf" "/etc/apache2/apache2.conf";
  sudo -E cp -f "apache2/mpm_prefork.conf" "/etc/apache2/mods-available/mpm_prefork.conf";
  sudo -E cp -f "apache2/common.conf" "${APACHE_COMMON_CONFIG_PATH}";
  sudo -E cp -f "apache2/000-default.conf" "/etc/apache2/sites-available/000-default.conf";

fi

# Ditch the default Apache directory and set a new default page.
if [ -d "/var/www/html" ]; then

  echo -e "PROVISIONING: Adjusting the Apache root directory and default file.\n";

  sudo -E rm -rf "/var/www/html";
  sudo -E cp -f "index.php" "/var/www/index.php";

fi

######################################################################################
# Apache Logs
######################################################################################

# Adjust the Apache log rotation script.
APACHE_LOGROTATE_PATH="/etc/logrotate.d/apache2";
if [ -f "${APACHE_SECURITY_PATH}" ]; then

  echo -e "PROVISIONING: Adjusting the Apache log rotation script.\n";

  sudo -E sed -i 's/rotate 52/rotate 13/g' "${APACHE_LOGROTATE_PATH}";
  sudo -E sed -i 's/create 640 root adm/create 640 root www-readwrite/g' "${APACHE_LOGROTATE_PATH}";

  # Adjust permissions on log files.
  sudo -E chmod o+rx /var/log/apache2;
  sudo -E chgrp www-readwrite /var/log/apache2/*;
  sudo -E chmod 644 /var/log/apache2/*;

fi

######################################################################################
# MySQL
######################################################################################

# Check if MySQL is installed and if not, install it.
hash mysql 2>/dev/null || {

  echo -e "PROVISIONING: Installing and configuring MySQL related items.\n";

  # Install the MySQL server and client.
  sudo -E RUNLEVEL=1 aptitude install -y --assume-yes -q mysql-server mysql-client;

  # Secure the MySQL installation.
  mysql -sfu root < "mysql_secure_installation.sql";

  # Run these commands to prevent MySQL from coming up on reboot.
  sudo -E service mysql stop;
  sudo -E update-rc.d -f mysql remove;

}

######################################################################################
# Munin
######################################################################################

# Check if Munin is installed and if not, install it.
hash munin-node 2>/dev/null || {

  echo -e "PROVISIONING: Installing and configuring Munin related items.\n";

  # Install Munin.
  sudo -E RUNLEVEL=1 aptitude install -y --assume-yes -q munin munin-node munin-plugins-extra libwww-perl;

  # Install the copied Munin config if it exists.
  MUNIN_CONF_PATH="/etc/munin/munin.conf";
  if [ -f "munin.conf" ]; then
    sudo -E cp -f "munin.conf" "${MUNIN_CONF_PATH}";
  fi

  # Edit the Munin config.
  if [ -f "${MUNIN_CONF_PATH}" ]; then
    sudo -E sed -i 's/^\[localhost.localdomain\]/\[vagrant.local\]/g' "${MUNIN_CONF_PATH}";
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

}

######################################################################################
# Munin Apache config.
######################################################################################

# Copy and enable the Munin Apache config.
MUNIN_APACHE_CONFIG_PATH="/etc/apache2/conf-available/munin.conf";
if [ -f "apache2/munin.conf" ] && [ -h "${MUNIN_APACHE_CONFIG_PATH}" ]; then

  echo -e "PROVISIONING: Installing the Apache Munin config.\n";

  sudo -E rm -f "${MUNIN_APACHE_CONFIG_PATH}";
  sudo -E cp -f "apache2/munin.conf" "${MUNIN_APACHE_CONFIG_PATH}";
  sudo -E a2enconf -q munin;
  # sudo -E service apache2 restart;

fi

######################################################################################
# phpMyAdmin
######################################################################################

# Install phpMyAdmin from source.
if [ ! -d "/usr/share/phpmyadmin" ]; then

  echo -e "PROVISIONING: Installing phpMyAdmin related items.\n";

  # Do this little dance to get things installed.
  cd "${BASE_DIR}/${CONFIG_DIR}";
  curl -ss -O -L "https://files.phpmyadmin.net/phpMyAdmin/4.0.10.11/phpMyAdmin-4.0.10.11-all-languages.tar.gz";
  tar -xf "phpMyAdmin-4.0.10.11-all-languages.tar.gz";
  rm -f "phpMyAdmin-4.0.10.11-all-languages.tar.gz";
  sudo -E mv -f "phpMyAdmin-4.0.10.11-all-languages" "/usr/share/phpmyadmin";

  # Set permissions to root for owner and group.
  sudo -E chown -f root:root -R "/usr/share/phpmyadmin";

fi

######################################################################################
# phpMyAdmin config.
######################################################################################

# Copy the phpMyAdmin configuration file into place.
PHPMYADMIN_CONFIG_PATH="/usr/share/phpmyadmin/config.inc.php";
if [ -f "phpmyadmin/config.inc.php" ] && [ ! -f "${PHPMYADMIN_CONFIG_PATH}" ]; then

  echo -e "PROVISIONING: Configuring phpMyAdmin related items.\n";

  # Set the phpMyAdmin config file.
  sudo -E cp -f "phpmyadmin/config.inc.php" "${PHPMYADMIN_CONFIG_PATH}";

  # Copy and set the patched 'Header.class.php' file.
  if [ -f "phpmyadmin/Header.class.php" ]; then
    sudo -E cp -f "phpmyadmin/Header.class.php" "/usr/share/phpmyadmin/libraries/Header.class.php";
  fi

  # Disable the phpMyAdmin PDF export stuff; never works right and can crash a server quite quickly.
  PHPMYADMIN_PLUGIN_PATH="/usr/share/phpmyadmin/libraries/plugins/export/";
  if grep -q -s {PMA_,}ExportPdf.class.php "${PHPMYADMIN_PLUGIN_PATH}"*; then
    sudo -E rm -f "${PHPMYADMIN_PLUGIN_PATH}"{PMA_,}ExportPdf.class.php;
  fi

fi

######################################################################################
# phpMyAdmin blowfish secret.
######################################################################################

BLOWFISH_SECRET_PATTERN="a8b7c6d";
if [ -f "${PHPMYADMIN_CONFIG_PATH}" ] && grep -E -q "${BLOWFISH_SECRET_PATTERN}" "${PHPMYADMIN_CONFIG_PATH}"; then

  echo -e "PROVISIONING: Setting a new phpMyAdmin blowfish secret value.\n";

  BLOWFISH_SECRET_NEW=$(openssl rand -base64 30);
  sudo -E sed -i "s/'${BLOWFISH_SECRET_PATTERN}'/'${BLOWFISH_SECRET_NEW}'/g" "${PHPMYADMIN_CONFIG_PATH}";

fi

######################################################################################
# phpMyAdmin Apache config.
######################################################################################

# Copy and enable the AWStats phpMyAdmin config.
PHPMYADMIN_APACHE_CONFIG_PATH="/etc/apache2/conf-available/phpmyadmin.conf";
if [ -f "apache2/phpmyadmin.conf" ] && [ ! -f "${PHPMYADMIN_APACHE_CONFIG_PATH}" ]; then

  echo -e "PROVISIONING: Installing the Apache phpMyAdmin config.\n";

  sudo -E cp -f "apache2/phpmyadmin.conf" "${PHPMYADMIN_APACHE_CONFIG_PATH}";
  sudo -E a2enconf -q phpmyadmin;
  # sudo -E service apache2 restart;

fi

######################################################################################
# GeoIP
######################################################################################

# Install GeoIP from source.
hash geoiplookup 2>/dev/null || {

  echo -e "PROVISIONING: Installing the GeoIP binary.\n";

  # Install the core compiler and build options.
  sudo aptitude install -y --assume-yes -q build-essential zlib1g-dev libtool;

  # Install GeoIP from source code.
  cd "${BASE_DIR}/${CONFIG_DIR}";
  curl -ss -O -L "http://www.maxmind.com/download/geoip/api/c/GeoIP-latest.tar.gz";
  tar -xf "GeoIP-latest.tar.gz";
  rm -f "GeoIP-latest.tar.gz";
  cd ./GeoIP*;
  libtoolize -f;
  ./configure;
  make -s;
  sudo -E make --silent install;
  cd "${BASE_DIR}/${CONFIG_DIR}";
  sudo -E rm -rf ./GeoIP*;

}

# Install the GeoIP databases.
GEOIP_TMP_PATH="/tmp";
GEOIP_DATA_PATH="/usr/local/share/GeoIP";
GEOIP_DATA_SYMLINK_PATH="/usr/share/GeoIP";
if [ ! -d "${GEOIP_DATA_PATH}" ]; then

  echo -e "PROVISIONING: Installing the GeoIP databases.\n";

  # Get the GeoIP databases.
  if [ ! -f "${GEOIP_TMP_PATH}/GeoIP.dat.gz" ] && [ ! -f "${GEOIP_DATA_PATH}/GeoIP.dat" ]; then
    curl -ss -L "http://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz" > "${GEOIP_TMP_PATH}/GeoIP.dat.gz";
  fi

  if [ ! -f "${GEOIP_TMP_PATH}/GeoLiteCity.dat.gz" ] && [ ! -f "${GEOIP_DATA_PATH}/GeoIPCity.dat" ]; then
    curl -ss -L "http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz" > "${GEOIP_TMP_PATH}/GeoLiteCity.dat.gz";
  fi

  if [ ! -f "${GEOIP_TMP_PATH}/GeoIPASNum.dat.gz" ] && [ ! -f "${GEOIP_DATA_PATH}/GeoIPASNum.dat" ]; then
    curl -ss -L "http://geolite.maxmind.com/download/geoip/database/asnum/GeoIPASNum.dat.gz" > "${GEOIP_TMP_PATH}/GeoIPASNum.dat.gz";
  fi

  if [ ! -f "${GEOIP_TMP_PATH}/GeoIPCountryCSV.zip" ] && [ ! -f "${GEOIP_DATA_PATH}/GeoIPCountryWhois.csv" ]; then
    curl -ss -L "http://geolite.maxmind.com/download/geoip/database/GeoIPCountryCSV.zip" > "${GEOIP_TMP_PATH}/GeoIPCountryCSV.zip";
  fi

  # Create the GeoIP directory—if it doesn't exist—like this.
  sudo mkdir -p "${GEOIP_DATA_PATH}/";

  # Move and decompress the databases to GeoIP data path.
  if [ -d "${GEOIP_DATA_PATH}" ]; then

    if [ -f "${GEOIP_TMP_PATH}/GeoIP.dat.gz" ]; then
      sudo -E mv "${GEOIP_TMP_PATH}/GeoIP.dat.gz" "${GEOIP_DATA_PATH}/";
      sudo -E gzip -d -q -f "${GEOIP_DATA_PATH}/GeoIP.dat.gz";
      sudo -E ln -s -f "${GEOIP_DATA_PATH}/GeoIP.dat" "${GEOIP_DATA_SYMLINK_PATH}/";
    fi

    if [ -f "${GEOIP_TMP_PATH}/GeoLiteCity.dat.gz" ]; then
      sudo -E mv "${GEOIP_TMP_PATH}/GeoLiteCity.dat.gz" "${GEOIP_DATA_PATH}/";
      sudo -E gzip -d -q -f "${GEOIP_DATA_PATH}/GeoLiteCity.dat.gz";
      sudo -E mv "${GEOIP_DATA_PATH}/GeoLiteCity.dat" "${GEOIP_DATA_PATH}/GeoIPCity.dat";
      sudo -E ln -s -f "${GEOIP_DATA_PATH}/GeoIPCity.dat" "${GEOIP_DATA_SYMLINK_PATH}/";
    fi

    if [ -f "${GEOIP_TMP_PATH}/GeoIPASNum.dat.gz" ]; then
      sudo -E mv "${GEOIP_TMP_PATH}/GeoIPASNum.dat.gz" "${GEOIP_DATA_PATH}/";
      sudo -E gzip -d -q -f "${GEOIP_DATA_PATH}/GeoIPASNum.dat.gz";
      sudo -E ln -s -f "${GEOIP_DATA_PATH}/GeoIPASNum.dat" "${GEOIP_DATA_SYMLINK_PATH}/";
    fi

    if [ -f "${GEOIP_TMP_PATH}/GeoIPCountryCSV.zip" ]; then
      sudo -E mv "${GEOIP_TMP_PATH}/GeoIPCountryCSV.zip" "${GEOIP_DATA_PATH}/";
      sudo -E unzip -o -q -d "${GEOIP_DATA_PATH}/" "${GEOIP_DATA_PATH}/GeoIPCountryCSV.zip";
      sudo -E rm -f "${GEOIP_DATA_PATH}/GeoIPCountryCSV.zip";
      sudo -E ln -s -f "${GEOIP_DATA_PATH}/GeoIPCountryWhois.csv" "${GEOIP_DATA_SYMLINK_PATH}/";
    fi

    # Set permissions to root for owner and group.
    sudo -E chown root:root -R "${GEOIP_DATA_PATH}/";

  fi

fi

######################################################################################
# AWStats
######################################################################################

# Install AWStats from source.
AWSTATS_ROOT_DIR="/usr/share/awstats-7.3";
if [ ! -d "${AWSTATS_ROOT_DIR}" ]; then

  echo -e "PROVISIONING: Installing the AWStats related items.\n";

  # Do this little dance to get things installed.
  cd "${BASE_DIR}/${CONFIG_DIR}";
  curl -ss -O -L "http://prdownloads.sourceforge.net/awstats/awstats-7.3.tar.gz";
  tar -xf "awstats-7.3.tar.gz";
  rm -f "awstats-7.3.tar.gz";
  sudo -E mv -f "awstats-7.3" "${AWSTATS_ROOT_DIR}";

  # Set an index page for AWStats.
  sudo -E cp -f "awstats/awstatstotals.php" "${AWSTATS_ROOT_DIR}/wwwroot/cgi-bin/index.php";
  sudo -E chmod a+r "${AWSTATS_ROOT_DIR}/wwwroot/cgi-bin/index.php";

  # Create the AWStats data directory.
  sudo -E mkdir -p "${AWSTATS_ROOT_DIR}/wwwroot/data";
  sudo -E chmod -f g+w "${AWSTATS_ROOT_DIR}/wwwroot/data";

  # Now install CPANminus like this.
  hash cpanminus 2>/dev/null || {
    sudo -E aptitude install -y --assume-yes -q cpanminus;
  }

  # With that done, install all of the GeoIP related CPAN modules like this.
  sudo cpanm --install --force --notest --quiet --skip-installed YAML Geo::IP Geo::IPfree Geo::IP::PurePerl URI::Escape Net::IP Net::DNS Net::XWhois Time::HiRes Time::Local;

  # Copy over a basic config file.
  sudo -E cp -f "awstats/awstats.model.deployment.conf" "${AWSTATS_ROOT_DIR}/wwwroot/cgi-bin/awstats.vagrant.local.conf";

  # Set permissions to root for owner and group.
  sudo -E chown -f root:root -R "${AWSTATS_ROOT_DIR}";

  # Update the data for the 'vagrant.local' config.
  sudo -E "${AWSTATS_ROOT_DIR}/wwwroot/cgi-bin/awstats.pl" -config="vagrant.local" -update

fi

######################################################################################
# AWStats Apache config.
######################################################################################

# Copy and enable the AWStats Apache config.
AWSTATS_APACHE_CONFIG_PATH="/etc/apache2/conf-available/awstats.conf";
if [ -f "apache2/awstats.conf" ] && [ ! -f "${AWSTATS_APACHE_CONFIG_PATH}" ]; then

  echo -e "PROVISIONING: Installing the Apache AWStats config.\n";

  sudo -E cp -f "apache2/awstats.conf" "${AWSTATS_APACHE_CONFIG_PATH}";
  sudo -E a2enconf -q awstats;
  # sudo -E service apache2 restart;

fi

######################################################################################
# Fail2Ban
######################################################################################

# Check if Fail2Ban is installed and if not, install it.
hash fail2ban-client 2>/dev/null || {

  echo -e "PROVISIONING: Fail2Ban related stuff.\n";

  # Install Fail2Ban.
  sudo -E RUNLEVEL=1 aptitude purge -y --assume-yes -q fail2ban;
  sudo -E RUNLEVEL=1 aptitude install -y --assume-yes -q gamin libgamin0 python-central python-gamin python-support;
  curl -ss -O -L "http://old-releases.ubuntu.com/ubuntu/pool/universe/f/fail2ban/fail2ban_0.8.13-1_all.deb";
  sudo -E RUNLEVEL=1 dpkg --force-all -i "fail2ban_0.8.13-1_all.deb";

  # Run these commands to prevent Fail2Ban from coming up on reboot.
  sudo -E service fail2ban stop;
  sudo -E update-rc.d -f fail2ban remove;

}

######################################################################################
# Fail2Ban config.
######################################################################################

# Copy and enable the Fail2Ban configs.
FAIL2BAN_LOCAL_JAIL_PATH="/etc/fail2ban/jail.local";
if [ -f "fail2ban/jail.local" ] && [ ! -f "${FAIL2BAN_LOCAL_JAIL_PATH}" ]; then

  echo -e "PROVISIONING: Installing the Fail2Ban configs.\n";

  sudo -E cp -f "fail2ban/jail.local" "${FAIL2BAN_LOCAL_JAIL_PATH}";
  sudo -E cp -f "fail2ban/ddos.conf" "/etc/fail2ban/filter.d/ddos.conf";

  # Restart Fail2Ban.
  sudo -E service fail2ban restart;

  # Run these commands to prevent Fail2Ban from coming up on reboot.
  sudo -E service fail2ban stop;
  sudo -E update-rc.d -f fail2ban remove;

fi

######################################################################################
# Update the locate database.
######################################################################################

echo -e "PROVISIONING: Updating the locate database.\n";

sudo -E updatedb;

######################################################################################
# Restart Apache now that we’re done.
######################################################################################

sudo -E service apache2 restart;

# Ditch the config files in the working directory.
# sudo -E rm -f "${BASE_DIR}"/*.{conf,patch,php,sql}
