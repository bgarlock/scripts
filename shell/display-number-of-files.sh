#!/bin/bash
#
# 2009-10-12  :  bgarlock  :  This script simply counts up the number of files in a users
#             :            :  home folder.  This can be useful for finding out who has
#             :            :  a lot of small files, which may cause an issue where the 
#             :            :  free inodes could run out, essentially bringing the server
#             :            :  down.
#
#

cd /home && for i in *; do echo -n "$i: "; find $i -type f | wc -l;
done 
