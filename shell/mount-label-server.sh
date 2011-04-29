#!/bin/sh
#
#
# 13 March 2010 B. Garlock:  Easy way to mount the label server share
#
#



/bin/mount -t smbfs //MACPRO-WIN2K/Formats  /home/samba/work/label-mount -o username=nicewatch,password=nicewatch,workgroup=GARLOCK,fmask=777,dmask=777
