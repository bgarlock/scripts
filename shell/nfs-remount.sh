#!/bin/sh
#
# script by B. Garlock to umount, and mount all NFS drives, in case
# a drive gets umounted, or storage is rebooted.
# should also consider making hard mounts to storage
#

/bin/umount -a -t nfs

/bin/sleep 1

/bin/mount -a -t nfs
