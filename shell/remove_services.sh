#!/bin/bash
# 
# B. Garlock 14 April 2008
# Script to quickly remove un-needed services from booting
#
# Salt to taste....

for SERVICE in gpm kudzu pcmcia isdn canna rawdevices
do
   /sbin/chkconfig $SERVICE off
   /sbin/service $SERVICE stop
done
