#!/bin/sh
# Script to dump mailscanner.maillog_arch so we can move it to storage, and flush it.
#

mysqldump --add-drop-table --all --extended-insert --quick -uroot -pTT2frgw9 mailscanner  --tables maillog_arch > /u/maillog_arch.sql

# use gzip to compress the file
gzip /u/maillog_arch.sql

