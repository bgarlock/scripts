#!/bin/sh

# Script to copy the sullivan_master folder to the ship_rates share
# Each night, so if someone changes something, the master
# will always overwrite the changes

# First, remove the current sullivan directory, so we can do a cp -a of
# the master to the ship_rates share folder

rm -rf /home/samba/work/ship_rates/sullivan

# Now copy back in the master, but rename as sullivan

cp -a /home/samba/work/sullivan_master /home/samba/work/ship_rates/sullivan
