#!/bin/sh
# Script to dump a table for backup or moving to another mysql server
#

# Change the following variables below to select the database, and table
# Output will be in /tmp/$TABLE.sql

DB="oedb"
TABLE="standards"

#
# Don't change anything below unless you know what you are doing.
#

mysqldump --add-drop-table --all --extended-insert --quick -uroot -pTT2frgw9 $DB  --tables $TABLE > /tmp/$TABLE.sql

# use gzip to compress the file
gzip /tmp/$TABLE.sql

