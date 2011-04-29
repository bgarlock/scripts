#!/bin/sh
#
# Bruce Garlock November, 2004
# Update 1: 4/28/05: Add a section to recreate the .htaccess file for
# DirectoryIndex
#

#
# This script will clean out the shipping/receiving Scans on a daily basis
cd /mnt/store-home/pub/incoming/shipping
rm -rf /mnt/store-home/pub/incoming/shipping/*

#
# create an index.html file, which will be appended by the windows software.
#

touch index.html
chown ftp:ftp index.html

#
# Make sure the directory group ownership is ftp so that proper writes can
# be done
#

chgrp ftp /mnt/store-home/pub/incoming
chgrp ftp /mnt/store-home/pub/incoming/shipping
chgrp ftp /mnt/store-home/pub/incoming/shipping * -R
chgrp ftp /mnt/store-home/pub/incoming/* -R

#
# Recreate .htaccess, and make sure to point it to the index file
#
cat > /mnt/store-home/pub/incoming/shipping/.htaccess <<EOF
DirectoryIndex index.html.htm
EOF

