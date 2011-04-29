#!/bin/sh
# Script to dump db for upload to web server
#

# remove old file
rm /tmp/ord_stat.sql.gz

mysqldump --add-drop-table --all --extended-insert --quick -uroot -pTT2frgw9 ord_stat  --tables inventory open_orders phpss_account custrep customer_qc > /tmp/ord_stat.sql

# use gzip to compress the file
gzip /tmp/ord_stat.sql

