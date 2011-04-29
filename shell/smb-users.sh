#!/bin/bash
SMBUSERS=`/usr/bin/smbstatus -b|/bin/sed -e '/------/d' -e '/PID/d' \
          -e '/Samba version/d' -e '/^$/d'|/bin/awk -F ' ' '{print $2;}'`
SMBUSERCOUNT=0
for SMBUSER in $SMBUSERS
do
  echo $SMBUSER                #each username
  let "SMBUSERCOUNT += 1"
done
echo $SMBUSERCOUNT             #number of user logged in
exit 0
