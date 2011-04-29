#!/bin/bash
#
#  B. Garlock   17JUNE10
#  1.  Create a semaphore to check for system up
#  2.  Do some FTP goodness
#
#####################################################

# Generate filename based on date stamp
date=$(date +%m%d%y%H%M%S).jpg;

# Generate semaphore for connectivity by pinging NASA -- Yea, this IS Rocket Science!!
isconnected=$(ping -c 1 www.nasa.gov| grep 64 | wc | awk '{print $1}');

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
        echo "Rocket Science Sucks when there is no connectivity!!!";
fi