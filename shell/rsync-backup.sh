#!/bin/sh
#
#
# rsync backup to corona (192.168.200.215)
# 23 June 2008: B. Garlock initial script
#
#
rsync -av /etc 192.168.200.215::linux
