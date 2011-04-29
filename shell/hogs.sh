#!/bin/sh

# Run the diskhogs/quota script and report based on date

/root/scripts/homehogs.sh > /var/log/homehogs/usage.$(date +%Y%m%d).txt
