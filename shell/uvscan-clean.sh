#!/bin/sh
#
#
# 3/27/08 - script to clean out 'hung' uvscan processes
#           B. Garlock.
#

# use ps to list all processes, then just ones with a PPID=1, and of those
# only show the processes with 'uvscan' in their name.  The second field is
# the PID, so we want to kill based on the PID.

echo "Killing the following PID's:"
ps -ef | awk '$3 == 1 && $8 ~ "uvscan" {print $2}'

kill -9 $(ps -ef | awk '$3 == 1 && $8 ~ "uvscan" {print $2}')
