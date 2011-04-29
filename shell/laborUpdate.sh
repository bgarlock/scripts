#!/bin/sh

#
# 2010-01-11: B. Garlock
# This script pulls out the LABOR transactions from Covalent, and INSERTS or UPDATES them
# into MySQL
#


TERM=xterm
export TERM 

/usr/bin/lynx -auth=jimb:901158 -source "http://192.168.200.180/covalent/mysql_update/labor/populate_oedb_labor.php" 
