#!/bin/sh

# Run the diskhogs/quota script and report based on date

/root/scripts/others.sh > /var/log/diskhogs/OTHERusage.$(date +%Y%m%d).txt
