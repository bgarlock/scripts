#!/bin/bash
ifconfig en0 | grep inactive > /dev/null
RC=$?

if [ $RC -eq 0 ] ; then
  WIREDSTR="inactive"
else
  WIREDSTR="$(ifconfig en0 | grep media: | grep \( | sed 's/.*(//' | sed 's/ .*//' | sed 's/baseT/ MBit\/s/')"
fi

/System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources/airport -I | grep "AirPort: Off" > /dev/null
RC=$?

if [ $RC -eq 0 ] ; then
        WIRELESSSTR="inactive"
else
  /System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources/airport -I | grep running > /dev/null
  RC=$?
  if [ $RC -eq 0 ] ; then
          WIRELESSSTR="$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources/airport -I | grep lastTxRate: | sed 's/.*: //' | sed 's/$/ MBit\/s/')"
  else
    WIRELESSSTR="disconnected"
  fi
fi

echo -e "Wireless:\t$WIRELESSSTR"
echo -e "Wired:\t$WIREDSTR"
