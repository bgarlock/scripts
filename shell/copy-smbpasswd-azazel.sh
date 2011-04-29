#!/bin/sh
# Script to first check to make sure destination host is up, and then copy the smbpasswd to it

HOSTCRP="azazel.garlockprinting.com"

if ping -c 1 -q $HOSTCRP; then
# Your ping was successful, you are connected. Do stuff here
/usr/bin/scp /etc/samba/smbpasswd azazel:/etc/samba

else
# Your ping didn't work. Something may be wrong.
exit 1
fi 
