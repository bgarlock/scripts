# Script to poll the Backup MX servers for garlockprinting and 360imaginginc.com 
# mail servers

# Shutdown current fetchmail process
echo "Shutting Down Current Fetchmail..."
/etc/fetchmaildown
sleep 2

echo "ETRN to rollernet.us servers"
/usr/bin/fetchmail -p ETRN --fetchdomains garlockprinting.com mail.rollernet.us
/usr/bin/fetchmail -p ETRN --fetchdomains garlockprinting.com mail2.rollernet.us

/usr/bin/fetchmail -p ETRN --fetchdomains 360imaginginc.com mail.rollernet.us
/usr/bin/fetchmail -p ETRN --fetchdomains 360imaginginc.com mail2.rollernet.us

echo "Restarting fetchmail"
sleep 2 

# Startup fetchmail
/etc/fetchmailup
