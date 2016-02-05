#!/bin/bash

##########################################################################################
# Configuration options.
##########################################################################################

# Set the working directory.
DIR="/tmp/"

# Set binary variable locations.
IFCONFIG_BIN="/sbin/ifconfig"
# IPSET_BIN="/usr/sbin/ipset"
IPSET_BIN="/sbin/ipset"

# Set IP address manually if network interaface addres is not external
# IP_ADDRESS=$($IFCONFIG_BIN en0 | awk '/inet addr/ {split ($2,A,":"); print A[2]}')

# Set IP address manually if network interaface address.
# IP_ADDRESS="123.456.789.0"

# Set the sundry variables.
IPSET_ACTION="REJECT"
IPSET_SET_TIMEOUT=10800 # 3 hour timeout.
IPSET_IP_TIMEOUT=10800 # 3 hour timeout.
CURL_TIMEOUT=30

# Set the IPSet setnames.
SET_TOR_IPS="TOR_IPS"
SET_BANNED_RANGES="BANNED_RANGES"

# Set the TOR ports.
TOR_PORT_ARRAY=();
TOR_PORT_ARRAY[0]=80
TOR_PORT_ARRAY[1]=9998

# Set the IPSet setname array.
SETNAME_ARRAY=();
SETNAME_ARRAY[0]=${SET_TOR_IPS};
SETNAME_ARRAY[1]=${SET_BANNED_RANGES};

# Set URLs
TOR_URL="http://check.torproject.org/cgi-bin/TorBulkExitList.py?ip=$IP_ADDRESS&port="

# Set the GeoIP CSVs
GEOIP_COUNTRY_CSV="/usr/local/share/GeoIP/GeoIPCountryWhois.csv"

# Set a country array.
COUNTRY_ARRAY=();
COUNTRY_ARRAY[0]='CN'; # China
COUNTRY_ARRAY[1]='RU'; # Russian Federation
COUNTRY_ARRAY[2]='UA'; # Ukraine
COUNTRY_ARRAY[3]='IN'; # India
COUNTRY_ARRAY[4]='BR'; # Brazil
COUNTRY_ARRAY[5]='VN'; # Vietnam
COUNTRY_ARRAY[6]='KR'; # South Korea
COUNTRY_ARRAY[7]='IR'; # Iran
