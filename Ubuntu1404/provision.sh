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
sudo groupadd -f www-readwrite

# Set the Vagrant users main group to be the 'www-readwrite' group.
sudo usermod -g www-readwrite vagrant

# Add the user to the 'www-readwrite' group:
sudo adduser --quiet vagrant www-readwrite

######################################################################################
# Date and Time
######################################################################################
echo -e "PROVISIONING: Set the date and time stuff.\n"

# Sync with the time/date server.
sudo ntpdate -u ntp.ubuntu.com

# Set the time zone data.
# debconf-set-selections <<< "tzdata tzdata/Areas select America"
# debconf-set-selections <<< "tzdata tzdata/Zones/America select New_York"
# sudo dpkg-reconfigure tzdata
TIMEZONE="America/New_York";
TIMEZONE_PATH="/etc/timezone";
if [ "${TIMEZONE}" != $(cat "${TIMEZONE_PATH}") ]; then
  sudo echo "${TIMEZONE}" > "${TIMEZONE_PATH}";
  sudo dpkg-reconfigure -f noninteractive tzdata;
fi

# Edit the 'sources.list' to enable partner package updates.
SOURCES_LIST="/etc/apt/sources.list";
if [ -f "${SOURCES_LIST}" ]; then
  sudo sed -i '/^#.*deb.*partner$/s/^# //g' "${SOURCES_LIST}"
fi

# Install Avahi daemon stuff.
sudo aptitude install -y --assume-yes -q avahi-daemon avahi-utils

######################################################################################
# Sysstat
######################################################################################
echo -e "PROVISIONING: Sysstat related stuff.\n"

# Install 'sysstat'.
sudo aptitude install -y --assume-yes -q sysstat

# Enable 'sysstat'.
SYSSTAT_CONFIG_PATH="/etc/default/sysstat";
if [ -f "${SYSSTAT_CONFIG_PATH}" ]; then
  sudo sed -i 's/ENABLED="false"/ENABLED="true"/g' "${SYSSTAT_CONFIG_PATH}";
fi

# Restart 'sysstat'.
sudo service sysstat restart

######################################################################################
# Generic Tools
######################################################################################
echo -e "PROVISIONING: Installing a set of generic tools.\n"

# Install generic tools.
sudo aptitude install -y --assume-yes -q \
  dnsutils traceroute nmap bc htop finger curl whois rsync lsof \
  iftop figlet lynx mtr-tiny iperf nload zip unzip attr sshpass \
  dkms mc elinks ntp dos2unix p7zip-full nfs-common imagemagick \
  slurm sharutils uuid-runtime chkconfig quota pv trickle apachetop

######################################################################################
# Locate
######################################################################################
echo -e "PROVISIONING: Installing the locate tool and updating the database.\n"

# Install and update the locate database.
sudo aptitude install -y --assume-yes -q locate
sudo updatedb

######################################################################################
# Compiler
######################################################################################
echo -e "PROVISIONING: Installing the core compiler tools.\n"

# Install the core compiler and built options.
sudo aptitude install -y --assume-yes -q build-essential

######################################################################################
# Git
######################################################################################
echo -e "PROVISIONING: Installing Git and related stuff.\n"

# Install Git via PPA.
if ! grep -q -s "git-core" /etc/apt/sources.list /etc/apt/sources.list.d/*; then
  sudo aptitude install -y --assume-yes -q python-software-properties
  sudo add-apt-repository -y ppa:git-core/ppa
  sudo aptitude update -y --assume-yes -q
  sudo aptitude upgrade -y --assume-yes -q
  sudo aptitude install -y --assume-yes -q git git-core subversion git-svn
fi

######################################################################################
# Postfix and Mail
######################################################################################
echo -e "PROVISIONING: Installing Postfix and related mail stuff.\n"

# Install postfix and general mail stuff.
debconf-set-selections <<< "postfix postfix/mailname string vagrant.local"
debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'"
sudo aptitude install -y --assume-yes -q postfix mailutils

######################################################################################
# UMASK
######################################################################################
echo -e "PROVISIONING: Adjusting the UMASK stuff.\n"

# Set the default UMASK value in 'login.defs' to be 002 instead of 022.
LOGIN_DEFS_PATH="/etc/login.defs";
if [ -f "${LOGIN_DEFS_PATH}" ]; then
  sudo sed -i 's/UMASK[ \t]*022/UMASK\t\t002/g' "${LOGIN_DEFS_PATH}";
fi

# Set the default UMASK value in 'common-session' to be 002 instead of 022.
COMMON_SESSION_PATH="/etc/pam.d/common-session";
if [ -f "${COMMON_SESSION_PATH}" ]; then
  sudo sed -i 's/^session optional[ \t]*pam_umask\.so$/session\soptional\t\tpam_umask\.so\t\tumask=0002/g' "${COMMON_SESSION_PATH}";
fi

######################################################################################
# SSH
######################################################################################
echo -e "PROVISIONING: SSH adjustments.\n"

# Fix for slow SSH client connections.
SSH_CONFIG_PATH="/etc/ssh/ssh_config";
if [ -f "${SSH_CONFIG_PATH}" ]; then
  # sudo echo "    PreferredAuthentications publickey,password,gssapi-with-mic,hostbased,keyboard-interactive" >> "${SSH_CONFIG_PATH}";
  SSH_APPEND="    PreferredAuthentications publickey,password,gssapi-with-mic,hostbased,keyboard-interactive";
  sudo grep -q -F "${SSH_APPEND}" "${SSH_CONFIG_PATH}" || echo "${SSH_APPEND}" >> "${SSH_CONFIG_PATH}";
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
sudo chmod -f -x "/etc/update-motd.d/50-landscape-sysinfo";
sudo chmod -f -x "/etc/update-motd.d/51-cloudguest";
sudo chmod -f -x "/etc/update-motd.d/90-updates-available";
sudo chmod -f -x "/etc/update-motd.d/91-release-upgrade";
sudo chmod -f -x "/etc/update-motd.d/95-hwe-eol";
sudo chmod -f -x "/etc/update-motd.d/98-cloudguest";

######################################################################################
# IPTables and IPSet
######################################################################################
echo -e "PROVISIONING: IPTables and IPSet stuff.\n"

# Install IPTables and IPSet stuff.
debconf-set-selections <<< "iptables-persistent iptables-persistent/autosave_v4 boolean true"
debconf-set-selections <<< "iptables-persistent iptables-persistent/autosave_v6 boolean true"
sudo aptitude install -y --assume-yes -q iptables iptables-persistent ipset

# Load the IPSet stuff if the file exists.
if [ -f "ipset.conf" ]; then
  sudo ipset restore < "ipset.conf"
  sudo cp "ipset.conf" "/etc/iptables/rules.ipsets"
fi

# Load the IPTables stuff if the file exists.
if [ -f "iptables.conf" ]; then
  sudo iptables-restore < "iptables.conf"
  sudo cp "iptables.conf" "/etc/iptables/rules.v4"
fi

# Patch 'iptables-persistent' if the patch exists and the original 'iptables-persistent' exists.
if [ -f "/etc/init.d/iptables-persistent" ] && [ -f "iptables-persistent-ipset.patch" ]; then
  sudo patch -fsb "/etc/init.d/iptables-persistent" < "iptables-persistent-ipset.patch"
fi