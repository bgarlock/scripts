#!/bin/sh
#
# Script to change to the /var/yp directory and run make
# since for some reason, new users are not being propagated to 
# slave YP servers.
#
cd /var/yp
make
