#!/bin/sh

# Run the diskhogs/quota script and report based on date

/root/scripts/u.sh > /var/log/diskhogs/udiskusage.$(date +%Y%m%d).txt
