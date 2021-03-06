#!/bin/bash

##########################################################################################
# Configuration options.
##########################################################################################

# How nice should the script be to other processes: 0-19
NICENESS=19

# Set the suffix using date & time info.
DATE=`date +%Y%m%d`
TIME=`date +%H%M`
SUFFIX="-"${DATE}"-"${TIME};

# Set the explicit locations of the MySQL related binaries.
MYSQL_BINARY='/usr/bin/mysql';
MYSQLDUMP_BINARY='/usr/bin/mysqldump';

DATABASE_DUMP_DIRECTORY='/opt/mysql_backup';

EXPIRATION=7;
