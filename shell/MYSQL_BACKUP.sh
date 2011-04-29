#!/usr/bin/env bash

#
# Created 2005-06-24 by Matthew Montgomery - mmontgom@rackspace.com 
# 
# Change: 2006-06-01 by Matthew Montgomery
#  Add support for ibbbackup for InnoDB tables
#  Add support for MySQL 4.1 and 5.0
#

DATE=`date -I`
DATADIR="/var/lib/mysql"
BASE_DIR="/mnt/drive2/backup"
BACKUP_DIR="$BASE_DIR/current"
INTERVAL="$1"
RETENTION=14 # days
HOST=`hostname -s`
MYVERSION=`mysql -Bse "SELECT substring_index(version(),'.',2)"`
###  Uncomment this line to specify the path to and enable ibbackup for hotcopy of InnoDB tables.
# IBBACKUP="/usr/local/bin/ibbackup"

if [ "$MYVERSION" = '4.1' ] || [ "$MYVERSION" = '5.0' ] ; then
	PURGELOGS='mysql -e "PURGE MASTER LOGS BEFORE DATE_SUB( NOW(), INTERVAL 1 HOUR )"'
elif [ $MYVERSION = '3.23' -o "$MYVERSION" = '4.0' ]; then
	PURGELOGS='mysql -e "RESET MASTER"'
else
echo "UNSUPPORTED MYSQL VERSION"
exit 1
fi

if [ ! $1 ];
then
	read -p "Backup Interval? (Hourly|Daily) : " INTERVAL
fi

case $INTERVAL in
	hourly | HOURLY | Hourly | 1 )
	echo "Performing HOURLY level backup -- `date`"
	mysql -e "FLUSH LOGS"
	if [ -d $BASE_DIR/$DATE ] && [ "$MYVERSION" = '4.1' -o "$MYVERSION" = '5.0' ] ; then
		rsync -aub $DATADIR/$HOST-bin.?????? $BASE_DIR/$DATE
	elif [ -d $BASE_DIR/$DATE ] && [ "$MYVERSION" = '3.23' -o "$MYVERSION" = '4.0' ] ; then
		rsync -aub $DATADIR/$HOST-bin.??? $BASE_DIR/$DATE
	else 
		echo "No destination dir! please run daily backup first." 1>&2
		exit 1
	fi
	sleep 1
	find $BASE_DIR -size 98c -exec rm -rf '{}' \;
	exit 0
	;;
	daily | DAILY | Daily | 2 )
	echo "Performing DAILY level backup -- `date`"
	if [ ! -d $BACKUP_DIR ];
	then
		echo Creating $BACKUP_DIR
		mkdir -p $BACKUP_DIR
	fi

	if [ ! -z "$IBBACKUP" ] ; then
		$IBBACKUP /etc/my.cnf /etc/my.cnf.ibbackup 2>&1
		$IBBACKUP --apply-log /etc/my.cnf.ibbackup 2>&1
		rm $BACKUP_DIR/ibbackup_logfile
	fi
	mysqlhotcopy --regexp=.* $BACKUP_DIR
	chown -R mysql: $BACKUP_DIR/
	mv $BACKUP_DIR $BASE_DIR/$DATE
	eval $PURGELOGS
	find $BASE_DIR -ctime +$RETENTION -exec rm -rf '{}' \;
	exit 0
	;;
	* )
	echo "Invalid Selection" 1>&2
	exit 1
esac
