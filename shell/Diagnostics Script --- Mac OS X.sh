#!/bin/bash

#This is a menu for basic diagnostics by Thomas Larkin

echo "Hello $USER, Welcome to the Tom's Diagnostic script!"
echo "Today is  ";date
echo "Number of user logged in : " ; who | wc -l
echo "Calendar"
cal

selection=
until [ "$selection" = "0" ]; do
    echo ""
    echo "Select an option please"
    echo "1 - Display all objects in /Volumes"
    echo "2 - Display total disk usage of /, this may take a while.  You will be prompted for admin access"
    echo "3 - Display the disk usage of my Home Directory, this may take a while"
    echo "4 - Print the contents of /var/log/system.log"
    echo "5 - List all current users logged in this computer"
    echo "6 - Display my Network Settings and Information"
    echo "7 - Display my BASH command paths"	
    echo "8 - Display all the current running processes"
    echo "9 - Display current resources being used"	
    echo "10 - Display the print error log"
    echo "11 - Display the crash reporter log"
    echo "12 - Run Verify permissions on the boot volume"	
    echo "13 - Run Repair Permissions on the boot volume"
    echo "14 - Run verify volume on the boot volume"
    echo "15 - list all information of boot volume"
    echo "0 - exit program"
    echo ""
    echo -n "Enter selection: "
    read selection
    echo ""
    case $selection in
       1 ) ls -al /Volumes ;;
       2 ) sudo du -h / | sort ;;
       3 ) du -a -h /Users/$USER | sort ;;
	   4 ) cat /var/log/system.log ;;
	   5 ) finger -h ;;
	   6 ) ifconfig ;;
	   7 ) echo $PATH ;;
	   8 ) ps -A ;;
	   9 ) top -s5 20 ;;
       10 ) cat /var/log/cups/error_log ;;
       11 ) cat /var/log/crashreporter.log ;;
       12 ) diskutil verifyPermissions / ;;
       13 ) diskutil repairPermissions / ;;
       14 ) diskutil verifyVolume / ;;
       15 ) diskutil list / ;;
	   0 ) exit ;;
       * ) echo "Please enter a valid option"
    esac
done