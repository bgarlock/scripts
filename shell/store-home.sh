#!/bin/bash
#
# Simple script to backup esential files, and copy them to a
# NFS drive so the main machine can backup each night
#
# Author: Bruce S. Garlock
# Date: 2002-10-15
#


/bin/mount -t smbfs //STORAGE/store-home /mnt/store -o username=store,password=store,workgroup=GARLOCK

