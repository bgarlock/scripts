#!/bin/bash
#
# iSight Auto Upload Script - by Dylan O'Donnell 2006 
#####################################################
# Edit CAPITALS with appropriate details 
#  Notes : Change file path to a folder without other JPEGs 
#	 : IF you get zero-byte files, try removing the "passive" line from the FTP stuff. 
#
#####################################################

# Generate filename based on date stamp
date=$(date +%m%d%y%H%M%S).jpg;

# Take iSight Photo and store in /tmp with datestamp filename
/bin/isightcapture -w 640 -h 480 -t jpg /Users/USERACCOUNT/Documents/$date;

# Wait a little while, if Mac is waking from sleep, needs a moment to connect to network
sleep 60;

# Generate semaphore for connectivity by pinging NASA
isconnected=$(ping -c 1 www.nasa.gov | grep 64 | wc | awk '{print $1}');

# If connected...
if [ "$isconnected" -eq "1" ]; then 

# Make .netrc FTP session commands on the fly
cat > ~/.netrc <<-EOF
        machine WWW.YOURWEBSITE.COM
        login USERNAME
        password PASS
        macdef init
        lcd /Users/USERACCOUNT/Documents
        cd REMOTE/DIR
        passive
        prompt
        restrict
        type binary
        prompt
        mput *.jpg
        quit

EOF

# Run FTP session to put JPGs in webspace, then delete from /tmp
chmod 600 ~/.netrc
ftp -i WWW.YOURWEBSITE.COM
rm /Users/USERACCOUNT/Documents/*.jpg

else 
        # If not connected.. leave captures there until next time. 
        echo "No Connection, Image not transferred or deleted.";
fi