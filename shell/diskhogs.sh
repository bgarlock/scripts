#!/bin/sh

# Run the diskhogs/quota script and report based on date

/root/scripts/fquota.sh > /var/log/diskhogs/usage.$(date +%Y%m%d).txt
