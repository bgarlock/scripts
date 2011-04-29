#!/bin/sh
# Script to dump all dbs on linux
#

# remove old file
rm /u/linux-mysql-backup/all_databases.sql.gz

mysqldump --all-databases --opt -uroot -pTT2frgw9 > /u/linux-mysql-backup/all_databases.sql

# use gzip to compress the file
gzip /u/linux-mysql-backup/all_databases.sql

