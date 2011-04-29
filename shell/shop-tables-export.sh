#!/bin/sh
# Script to dump shop tables to move to athena
#

# remove old file
rm /tmp/shop-tables.sql.gz

mysqldump --add-drop-table --all --extended-insert --quick -uroot -pTT2frgw9 shop --tables machine machine_group department employee activity > /tmp/shop-tables.sql

# use gzip to compress the file
gzip /tmp/shop-tables.sql


# Copy to Athena

/usr/bin/scp /tmp/shop-tables.sql.gz root@athena:/root/mysql-tmp


# Execute Update on Athena

# Execute the update command on the remote server
/usr/bin/ssh -t -q -lroot athena /usr/local/bin/shop-update.sh
