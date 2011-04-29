#!/bin/sh
# Script to dump oedb tables in order to move to athena inventory db
#

# remove old file
rm /tmp/oedb-tables-inventory.sql.gz

mysqldump --add-drop-table --all --extended-insert --quick -uroot -pTT2frgw9 oedb --tables jobcontrol subdet customer laminates adhesive > /tmp/oedb-tables-inventory.sql

# use gzip to compress the file
gzip /tmp/oedb-tables-inventory.sql

# Copy to Athena
/usr/bin/scp /tmp/oedb-tables-inventory.sql.gz root@athena:/root/mysql-tmp

# Execute Update on Athena
# Execute the update command on the remote server
/usr/bin/ssh -t -q -lroot athena /usr/local/bin/oedb-update-inventory.sh
