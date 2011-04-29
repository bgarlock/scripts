### Begin LOGIN ALLOW #####################################################
### Add this to the *BEGINNING* of /etc/profile
###                  ^^^^^^^^^
### Only allow certain users to login Mon-Fri between specific hous.
CK_LOGIN_DAY_TIME="YES"   # YES or NO
LOGNAME="`logname`"       # Login name
if [ "${CK_LOGIN_DAY_TIME}" = "YES" -a "${LOGNAME}" != "root" ]
then
   LOG="/tmp/login$$"     # Temporary log file.
   MAIL_TO="root"         # Email notification
   set `date` > /dev/null # Grab date settings
   DAY="$1"               # Day of week
   HOUR="`date +%H`"      # Hour of the day in 24 hour notation
   case ${DAY} in
     Mon|Tue|Wed|Thu|Fri) # Only allow logins on these days
                          case $HOUR in # Only allow login during these hours
                                   0|1|2|3|4|5|6|7|8|9) ALLOW_LOGIN="YES" ;; 
                         00|01|02|03|04|05|06|07|08|09) ALLOW_LOGIN="YES" ;; 
                            10|11|12|13|14|15|16|17|18) ALLOW_LOGIN="YES" ;; 
                                                     *) ALLOW_LOGIN="NO"  ;;
                          esac ;
                          ;;
                       *) # No login allowed on weekend
                          ALLOW_LOGIN="NO" ;;
   esac
   if [ "${ALLOW_LOGIN}" = "NO" ]
   then
        echo "=================================="  > $LOG ;
        echo "***    !!!!  WARNING  !!!!     ***" >> $LOG ;
        echo "*** UNAUTHORIZED-LOGIN-ATTEMPT ***" >> $LOG ;
        echo "==================================" >> $LOG ;
        echo "DATE: `date`"                       >> $LOG ;
        echo "  ID: $LOGNAME"                     >> $LOG ;
        echo " TTY: `tty`"                        >> $LOG ;
        echo "==================================" >> $LOG ;
        cat $LOG | mail -s "LOGIN_VIOLATION" $MAIL_TO
        rm -f $LOG > /dev/null
        echo "\nLOGIN VIOLATION ATTEMPT"
      # exit 0 ;  # Uncomment this line if you want to logout user.
   fi
fi
### End   LOGIN ALLOW #####################################################
