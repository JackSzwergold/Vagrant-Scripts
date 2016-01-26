#!/bin/bash

######################################################################################
# DEBIAN_FRONTEND
######################################################################################

echo -e "PROVISIONING: Set the Debian frontend to non-interactive mode.\n"
export DEBIAN_FRONTEND=noninteractive

######################################################################################
# User and Group
######################################################################################

echo -e "PROVISIONING: User and group related stuff.\n"

# Create the 'www-readwrite' group.
sudo -E groupadd -f www-readwrite

# Set the Vagrant users main group to be the 'www-readwrite' group.
sudo -E usermod -g www-readwrite vagrant

# Add the user to the 'www-readwrite' group:
sudo -E adduser --quiet vagrant www-readwrite

######################################################################################
# Environment
######################################################################################

# echo -e "PROVISIONING: Environment stuff.\n"

# Set the selected editor to Nano.
# sudo -u vagrant echo 'SELECTED_EDITOR="/bin/nano"' > ".selected_editor";

######################################################################################
# Date and Time
######################################################################################

echo -e "PROVISIONING: Set the date and time stuff.\n"

# Sync with the time/date server.
sudo -E ntpdate -u ntp.ubuntu.com

# Set the time zone data.
# debconf-set-selections <<< "tzdata tzdata/Areas select America"
# debconf-set-selections <<< "tzdata tzdata/Zones/America select New_York"
# sudo -E dpkg-reconfigure tzdata
TIMEZONE="America/New_York";
TIMEZONE_PATH="/etc/timezone";
if [ "${TIMEZONE}" != $(cat "${TIMEZONE_PATH}") ]; then
  sudo -E echo "${TIMEZONE}" > "${TIMEZONE_PATH}";
  sudo -E dpkg-reconfigure -f noninteractive tzdata;
fi

# Edit the 'sources.list' to enable partner package updates.
SOURCES_LIST="/etc/apt/sources.list";
if [ -f "${SOURCES_LIST}" ]; then
  sudo -E sed -i '/^#.*deb.*partner$/s/^# //g' "${SOURCES_LIST}";
fi

# Install Avahi daemon stuff.
sudo -E aptitude install -y --assume-yes -q avahi-daemon avahi-utils

######################################################################################
# Sysstat
######################################################################################

echo -e "PROVISIONING: Sysstat related stuff.\n"

# Install 'sysstat'.
sudo -E aptitude install -y --assume-yes -q sysstat

# Enable 'sysstat'.
SYSSTAT_CONFIG_PATH="/etc/default/sysstat";
if [ -f "${SYSSTAT_CONFIG_PATH}" ]; then
  sudo -E sed -i 's/ENABLED="false"/ENABLED="true"/g' "${SYSSTAT_CONFIG_PATH}";
fi

# Restart 'sysstat'.
sudo -E service sysstat restart

######################################################################################
# Generic Tools
######################################################################################

echo -e "PROVISIONING: Installing a set of generic tools.\n"

# Install generic tools.
sudo -E aptitude install -y --assume-yes -q \
  dnsutils traceroute nmap bc htop finger curl whois rsync lsof \
  iftop figlet lynx mtr-tiny iperf nload zip unzip attr sshpass \
  dkms mc elinks ntp dos2unix p7zip-full nfs-common imagemagick \
  slurm sharutils uuid-runtime chkconfig quota pv trickle apachetop

######################################################################################
# Locate
######################################################################################

echo -e "PROVISIONING: Installing the locate tool and updating the database.\n"

# Install and update the locate database.
sudo -E aptitude install -y --assume-yes -q locate
sudo -E updatedb

######################################################################################
# Compiler
######################################################################################

echo -e "PROVISIONING: Installing the core compiler tools.\n"

# Install the core compiler and built options.
sudo -E aptitude install -y --assume-yes -q build-essential

######################################################################################
# Git
######################################################################################

echo -e "PROVISIONING: Installing Git and related stuff.\n"

# Install Git via PPA.
if ! grep -q -s "git-core" /etc/apt/sources.list /etc/apt/sources.list.d/*; then
  sudo -E aptitude install -y --assume-yes -q python-software-properties
  sudo -E add-apt-repository -y ppa:git-core/ppa
  sudo -E aptitude update -y --assume-yes -q
  sudo -E aptitude upgrade -y --assume-yes -q
  sudo -E aptitude install -y --assume-yes -q git git-core subversion git-svn
fi

######################################################################################
# Postfix and Mail
######################################################################################

echo -e "PROVISIONING: Installing Postfix and related mail stuff.\n"

# Install postfix and general mail stuff.
debconf-set-selections <<< "postfix postfix/mailname string vagrant.local"
debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'"
sudo -E aptitude install -y --assume-yes -q postfix mailutils

######################################################################################
# UMASK
######################################################################################

echo -e "PROVISIONING: Adjusting the UMASK stuff.\n"

# Set the default UMASK value in 'login.defs' to be 002 instead of 022.
LOGIN_DEFS_PATH="/etc/login.defs";
if [ -f "${LOGIN_DEFS_PATH}" ]; then
  sudo -E sed -i 's/UMASK[ \t]*022/UMASK\t\t002/g' "${LOGIN_DEFS_PATH}";
fi

# Set the default UMASK value in 'common-session' to be 002 instead of 022.
COMMON_SESSION_PATH="/etc/pam.d/common-session";
if [ -f "${COMMON_SESSION_PATH}" ]; then
  sudo -E sed -i 's/^session optional[ \t]*pam_umask\.so$/session\soptional\t\tpam_umask\.so\t\tumask=0002/g' "${COMMON_SESSION_PATH}";
fi

######################################################################################
# SSH
######################################################################################

echo -e "PROVISIONING: SSH adjustments.\n"

# Fix for slow SSH client connections.
SSH_CONFIG_PATH="/etc/ssh/ssh_config";
if [ -f "${SSH_CONFIG_PATH}" ]; then
  SSH_APPEND="    PreferredAuthentications publickey,password,gssapi-with-mic,hostbased,keyboard-interactive";
  sudo -E grep -q -F "${SSH_APPEND}" "${SSH_CONFIG_PATH}" || echo "${SSH_APPEND}" >> "${SSH_CONFIG_PATH}";
fi

######################################################################################
# MOTD
######################################################################################

echo -e "PROVISIONING: MOTD adjustments.\n"

# Set the server login banner with figlet.
# MOTD_PATH="/etc/motd.tail";
MOTD_PATH="/etc/motd";
figlet "Vagrant" > "${MOTD_PATH}";
echo "" >> "${MOTD_PATH}";

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

echo -e "PROVISIONING: IPTables and IPSet stuff.\n"

# Install IPTables and IPSet stuff.
debconf-set-selections <<< "iptables-persistent iptables-persistent/autosave_v4 boolean true"
debconf-set-selections <<< "iptables-persistent iptables-persistent/autosave_v6 boolean true"
sudo -E aptitude install -y --assume-yes -q iptables iptables-persistent ipset

# Load the IPSet stuff if the file exists.
if [ -f "ipset.conf" ]; then
  sudo -E ipset restore < "ipset.conf"
  sudo -E cp -f "ipset.conf" "/etc/iptables/rules.ipsets"
fi

# Load the IPTables stuff if the file exists.
if [ -f "iptables.conf" ]; then
  sudo -E iptables-restore < "iptables.conf"
  sudo -E cp -f "iptables.conf" "/etc/iptables/rules.v4"
fi

# Patch 'iptables-persistent' if the patch exists and the original 'iptables-persistent' exists.
if [ -f "/etc/init.d/iptables-persistent" ] && [ -f "iptables-persistent-ipset.patch" ]; then
  sudo -E patch -fsb "/etc/init.d/iptables-persistent" < "iptables-persistent-ipset.patch"
fi

######################################################################################
# Apache and PHP (Installing)
######################################################################################

echo -e "PROVISIONING: Installing Apache and PHP stuff.\n"

# Install the base Apache stuff.
sudo -E RUNLEVEL=1 aptitude install -y --assume-yes -q \
  apache2 apache2-threaded-dev php5 \
  libapache2-mod-php5 php-pear

# Install other PHP related stuff.
sudo -E RUNLEVEL=1 aptitude install -y --assume-yes -q \
  php5-mysql php5-pgsql php5-odbc php5-sybase php5-sqlite \
  php5-xmlrpc php5-json php5-xsl php5-curl php5-geoip \
  php-getid3 php5-imap php5-ldap php5-mcrypt \
  php5-pspell php5-gmp php5-gd

# Enable the PHP mcrypt module.
sudo -E php5enmod mcrypt

# Enable these core Apache modules.
sudo -E a2enmod -q rewrite headers expires include proxy proxy_http cgi

######################################################################################
# Apache and PHP (Configuring)
######################################################################################

echo -e "PROVISIONING: Configuring the Apache and PHP stuff.\n"

# Adjust the PHP config.
PHP_CONFIG_PATH="/etc/php5/apache2/php.ini";
if [ -f "${PHP_CONFIG_PATH}" ]; then
  # Harden PHP by disabling 'expose_php'.
  sudo -E sed -i 's/expose_php = On/expose_php = Off/g' "${PHP_CONFIG_PATH}";
  # Disable the PHP 5.5 opcache.
  sudo -E sed -i 's/;opcache.enable=0/opcache.enable=0/g' "${PHP_CONFIG_PATH}";
fi

# Harden Apache.
APACHE_SECURITY_PATH="/etc/apache2/conf-available/security.conf";
if [ -f "${APACHE_SECURITY_PATH}" ]; then
  sudo -E sed -i 's/^ServerTokens OS/ServerTokens Prod/g' "${APACHE_SECURITY_PATH}";
  sudo -E sed -i 's/^ServerSignature On/ServerSignature Off/g' "${APACHE_SECURITY_PATH}";
  sudo -E sed -i 's/^TraceEnable On/TraceEnable Off/g' "${APACHE_SECURITY_PATH}";
fi

# Adjust the Apache run group and UMASK.
APACHE_ENVVARS_PATH="/etc/apache2/envvars";
if [ -f "${APACHE_ENVVARS_PATH}" ]; then
  sudo -E sed -i 's/^export APACHE_RUN_GROUP=www-data/export APACHE_RUN_GROUP=www-readwrite/g' "${APACHE_ENVVARS_PATH}";
  APACHE_APPEND="umask 002";
  sudo -E grep -q -F "${APACHE_APPEND}" "${APACHE_ENVVARS_PATH}" || echo -e "\n${APACHE_APPEND}" >> "${APACHE_ENVVARS_PATH}";
fi

# Set the config files for Apache.
sudo -E cp -f "000-default.conf" "/etc/apache2/sites-available/000-default.conf"
sudo -E cp -f "common.conf" "/etc/apache2/sites-available/common.conf"

# Ditch the default Apache directory and set a new default page.
sudo -E rm -rf "/var/www/html"
sudo -E cp -f "index.php" "/var/www/index.php"

# Replace the default man Apache config and the MPM prefork config with something simpler and more resource friendly.
sudo -E cp -f "apache2.conf" "/etc/apache2/apache2.conf"
sudo -E cp -f "mpm_prefork.conf" "/etc/apache2/mods-available/mpm_prefork.conf"

# Restart Apache to get the new config settings loaded.
sudo -E service apache2 restart

######################################################################################
# Apache Logs
######################################################################################

echo -e "PROVISIONING: Adjusting Apache log rotation.\n"

# Adjust the Apache log rotation script.
APACHE_LOGROTATE_PATH="/etc/logrotate.d/apache2";
if [ -f "${APACHE_SECURITY_PATH}" ]; then
  sudo -E sed -i 's/rotate 52/rotate 13/g' "${APACHE_LOGROTATE_PATH}";
  sudo -E sed -i 's/create 640 root adm/create 640 root www-readwrite/g' "${APACHE_LOGROTATE_PATH}";
fi

# Adjust permissions on log files.
sudo -E chmod o+rx /var/log/apache2
sudo -E chgrp www-readwrite /var/log/apache2/*
sudo -E chmod 644 /var/log/apache2/*

######################################################################################
# MySQL
######################################################################################

echo -e "PROVISIONING: Installing and configuring MySQL stuff.\n"

# Install the MySQL server and client.
sudo -E RUNLEVEL=1 aptitude install -y --assume-yes -q mysql-server mysql-client

# Secure the MySQL installation.
mysql -sfu root < "mysql_secure_installation.sql";

# Run these commands to prevent MySQL from coming up on reboot.
sudo -E service mysql stop
sudo -E update-rc.d -f mysql remove

######################################################################################
# Munin
######################################################################################

echo -e "PROVISIONING: Installing and configuring Munin stuff.\n"

# Install Munin.
sudo -E RUNLEVEL=1 aptitude install -y --assume-yes -q munin munin-node munin-plugins-extra libwww-perl

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
sudo -E ln -fs "/usr/share/munin/plugins/apache_accesses" "/etc/munin/plugins/apache_accesses"
sudo -E ln -fs "/usr/share/munin/plugins/apache_processes" "/etc/munin/plugins/apache_processes"
sudo -E ln -fs "/usr/share/munin/plugins/apache_volume" "/etc/munin/plugins/apache_volume"

# Activate the MySQL related Munin plug-ins.
sudo -E ln -fs "/usr/share/munin/plugins/mysql_bytes" "/etc/munin/plugins/mysql_bytes"
sudo -E ln -fs "/usr/share/munin/plugins/mysql_queries" "/etc/munin/plugins/mysql_queries"
sudo -E ln -fs "/usr/share/munin/plugins/mysql_slowqueries" "/etc/munin/plugins/mysql_slowqueries"
sudo -E ln -fs "/usr/share/munin/plugins/mysql_threads" "/etc/munin/plugins/mysql_threads"

# Activate the Postfix related Munin plug-ins.
sudo -E ln -fs "/usr/share/munin/plugins/postfix_mailqueue" "/etc/munin/plugins/postfix_mailqueue"
sudo -E ln -fs "/usr/share/munin/plugins/postfix_mailvolume" "/etc/munin/plugins/postfix_mailvolume"

# Activate the Fail2Ban related Munin plug-ins.
sudo -E ln -fs "/usr/share/munin/plugins/fail2ban" "/etc/munin/plugins/fail2ban"

# Repair Munin permissions.
sudo -E munin-check --fix-permissions

# Start the Munin node.
sudo -E service munin-node restart

######################################################################################
# Munin Apache config.
######################################################################################

echo -e "PROVISIONING: Installing the Apache Munin config.\n"

# Copy and enable the Munin Apache config.
if [ -f "apache-munin.conf" ]; then
  sudo -E cp -f "apache-munin.conf" "/etc/apache2/conf-available/munin.conf"
  sudo -E a2enconf -q munin
  sudo -E service apache2 restart
fi

######################################################################################
# phpMyAdmin
######################################################################################

echo -e "PROVISIONING: Installing and configuring phpMyAdmin stuff.\n"

# Install phpMyAdmin from source.
if [ ! -f "/usr/share/phpmyadmin" ]; then
  sudo -E curl -ss -O -L "https://files.phpmyadmin.net/phpMyAdmin/4.0.10.11/phpMyAdmin-4.0.10.11-all-languages.tar.gz";
  sudo -E tar -xf "phpMyAdmin-4.0.10.11-all-languages.tar.gz"
  sudo -E rm -f "phpMyAdmin-4.0.10.11-all-languages.tar.gz";
  sudo -E mv -f "phpMyAdmin-4.0.10.11-all-languages" "/usr/share/phpmyadmin";
  # Set permissions to root for owner and group.
  sudo -E chown -f root:root -R "/usr/share/phpmyadmin";
fi

# Copy the phpMyAdmin configuration file into place.
PHPMYADMIN_CONFIG_PATH="/usr/share/phpmyadmin/config.inc.php";
if [ ! -f "${PHPMYADMIN_CONFIG_PATH}" ]; then
  if [ -f "phpmyadmin-config.inc.php" ]; then
    sudo -E cp -f "phpmyadmin-config.inc.php" "${PHPMYADMIN_CONFIG_PATH}"
  else
    sudo -E cp -f "/usr/share/phpmyadmin/config.sample.inc.php" "${PHPMYADMIN_CONFIG_PATH}";
  fi
  # Set the blowfish secret stuff.
  if [ -f "${PHPMYADMIN_CONFIG_PATH}" ]; then
    BLOWFISH_SECRET_DEFAULT='a8b7c6d';
    BLOWFISH_SECRET_NEW=$(openssl rand -base64 30);
    sudo -E sed -i "s|cfg\['blowfish_secret'\] = '${BLOWFISH_SECRET_DEFAULT}'|cfg['blowfish_secret'] = '${BLOWFISH_SECRET_NEW}'|" "${PHPMYADMIN_CONFIG_PATH}";
  fi
fi

# Disable the phpMyAdmin PDF export stuff; never works right and can crash a server quite quickly.
sudo rm -f "/usr/share/phpmyadmin/libraries/plugins/export/PMA_ExportPdf.class.php"
sudo rm -f "/usr/share/phpmyadmin/libraries/plugins/export/ExportPdf.class.php"

# Copy and enable the Apache phpMyAdmin config.
if [ -f "apache-phpmyadmin.conf" ]; then
  sudo -E cp -f "apache-phpmyadmin.conf" "/etc/apache2/conf-available/phpmyadmin.conf"
  sudo -E a2enconf -q phpmyadmin
  sudo -E service apache2 restart
fi

######################################################################################
# Update the locate database.
######################################################################################

echo -e "PROVISIONING: Updating the locate database.\n"

sudo -E updatedb
