#!/bin/bash
#
# Simple script to backup esential files, and copy them to a
# NFS drive so the main machine can backup each night
#
# Author: Bruce S. Garlock
# Date: 2002-10-15
#

###########################
# Configuration Area BEGIN#
###########################
# set filename/location to backup to here
#
LOCATION="/opt/remote/solvent"
FILENAME="solvent.tar"
TAR=/bin/tar
#
#
####################
# End Configuration#
####################

# Mount the smb dir first

/bin/mount -t smbfs //SOLVINK1/Ink /import/SOLVINK/Ink -o username=Administrator,password=ink,workgroup=INK 
sleep 2

/bin/mount -t smbfs //SOLVINK1/Dispense /import/SOLVINK/Dispense -o username=Administrator,password=ink,workgroup=INK 
sleep 2

## Remove old backup file first

rm -rf $LOCATION/$FILENAME.bz2

## Create new file

$TAR cfj $LOCATION/$FILENAME.bz2 /import/SOLVINK


# umount the smbfs dirs

/bin/umount /import/SOLVINK/Ink
/bin/umount /import/SOLVINK/Dispense

