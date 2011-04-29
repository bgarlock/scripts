#
# script to copy 'mail stores' from linux to new imap server 
# B. Garlock
#
# 2008-07-16:  Version 0.1 -- Initial script
# 2008-07-17:  Version 0.2 -- Bug fixes to vars
#              Version 0.3 -- Output of text file explicitly stated
#              Version 0.4 -- Anything outside of /home needs to have the directory
#                             created on $DEST.
#              Version 0.5 -- Built some arrays and loops to get rid of redundancy.
#
# echo the current date/time to a file, so we know when we START and at the end, we will add
# it so we know when it finishes

echo -e `date '+%D %T'`"\tSTART email copy script" >> ~/scripts/copy-accounts.txt
#
###############################
#                             #
# BEGIN CONFIG AREA           #
#                             #
###############################

#  Destination IP address (or hostname if it resolves)
DEST=192.168.200.4

#
# Setup Array for users in /mnt/store-home
# ONLY change the names!  Keep the rest of the formatting (i.e. spaces) the same!
#

storage=( mikec max judy mattb tracy bruceg kevink )

# Setup Array for users in /u/Users  --  (The same applies here, as above - don't go
# messing with spaces and anything else other than the names, unless you know what will
# happen.

users=( bobb chad jimb jasonc peteg )

#####################################
#  END CONFIG AREA - DON'T MODIFY   #
#  BELOW THIS LINE UNLESS YOU KNOW  #
#  WHAT THE HECK YOU ARE DOING.. OR #
#  YOU CAN FIGURE IT OUT            #
#####################################



#
# 1st, copy the /home folder, and send everything to $DEST:/home
#
echo -e `date '+%D %T'`"\tCurrently copying /home" >> ~/scripts/copy-accounts.txt
cd /home && tar -cf - . | ssh $DEST "cd /home && tar -xpf - "
echo -e `date '+%D %T'`"\tCopying /home complete"  >> ~/scripts/copy-accounts.txt


# Now things get a little crazy.  Because we are restoring to /home and the source is
# actually in a different dir, we need to do some making of directories so we can
# untar into them.
#

# FIXME:  we should check to see if the dir exists first, and then make the dir if it does
#         not exist.  This is using a more unintelligent approach of _assuming_ the dirs
#         are not there.  (Not my best work - I am under pressure to keep it simple)


# Now copy stuff in /mnt/store-home -users only
echo -e `date '+%D %T'`"\tCopying users folders in /mnt/store-home"  >> ~/scripts/copy-accounts.txt

for name in ${storage[@]}
do
   cd /mnt/store-home/$name && tar -cf - . | ssh $DEST "cd /home && mkdir $name && cd /home/$name && tar -xpf - "
done

# Log our stop time for this section of the copy.
echo -e `date '+%D %T'`"\tDONE Copying /mnt/store-home USERS complete"  >> ~/scripts/copy-accounts.txt

# Now copy stuff in /u/Users -users only
echo -e `date '+%D %T'`"\tCopying users in /u/Users"  >> ~/scripts/copy-accounts.txt

for names in ${users[@]}
do
   cd /mnt/store-home/$names && tar -cf - . | ssh $DEST "cd /home && mkdir $names && cd /home/$names && tar -xpf - "
done

# Log our stop time for this portion of the script
echo -e `date '+%D %T'`"\tDONE copying from /u/Users"  >> ~/scripts/copy-accounts.txt


# Now the inboxes, where everyone is in /var/spool/mail
echo -e `date '+%D %T'`"\tNow copying the users inboxes is /var/spool/mail"  >> ~/scripts/copy-accounts.txt 

cd /var/spool/mail && tar -cf - . | ssh $DEST "cd /var/spool/mail && tar -xpf - "
echo -e `date '+%D %T'`"\tDone copying inboxes"  >> ~/scripts/copy-accounts.txt


# Now let's log the time we stopped.  This should give us a good idea of how long this 
# process took for benchmarking, and getting a good baseline of the process.
echo -e `date '+%D %T'`"\tFINISH email copy script"  >> ~/scripts/copy-accounts.txt

# If we made it this far, we are done!
exit 0
