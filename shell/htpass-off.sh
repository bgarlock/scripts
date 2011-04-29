# Script to disable Mark's login per Phil in the Intranet password Group
# Also for Squid

cp /home/httpd/global/.htpasswd.MARKOFF /home/httpd/global/.htpasswd

cp /etc/squid/passwd.MARKOFF /etc/squid/passwd

/usr/bin/killall -HUP squid


