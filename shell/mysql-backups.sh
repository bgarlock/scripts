#!/bin/sh
#
#  MySQL Backup Script -- By B. Garlock
#  Keeps 5 different days, including current day for a total of 6 days
#  worth of backups.
#  Very basic - no error checking - make sure destination directories 
#  exist.
#

echo "Rotating MySQL backups:"

for i in /home/mysql/mysql_backup.sql; do
    if [ -f "${i}" ]; then
        echo " $i"
        if [ -x /usr/bin/gzip ]; then gzext=".gz"; else gzext=""; fi
        if [ -f "${i}.4" ]; then mv -f "${i}.4" "${i}.5"; fi
        if [ -f "${i}.3" ]; then mv -f "${i}.3" "${i}.4"; fi
        if [ -f "${i}.2" ]; then mv -f "${i}.2" "${i}.3"; fi
        if [ -f "${i}.1" ]; then mv -f "${i}.1" "${i}.2"; fi
        if [ -f "${i}.0" ]; then mv -f "${i}.0" "${i}.1"; fi
        if [ -f "${i}" ]; then 
                mv -f "${i}" "${i}.0"; 
        fi
        touch "${i}" && chmod 640 "${i}"
    fi
done

# dump new backup
echo "Dumping new MySQL backup."
/usr/bin/mysqldump -h localhost -u $BACKUP_USER -p $PASSWORD\
 --all-databases > /home/mysql/mysql_backup.sql