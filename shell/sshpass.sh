#!/bin/bash
#  B. Garlock 08Feb11
#  Generate SSH key and propagate to server for passwordless login
#
if [ -z "$1" ]; then
   echo "You must give an argument: sshpass.sh <username>@<servername or ip address>"
   exit 1
fi
SSHKEY=id_dsa.pub
KEYFILE=authorized_keys2
PAYLOAD=`cat .ssh/$SSHKEY`
echo "Attaching key to authorized_keys file"
ssh $1 "mkdir -p .ssh && chmod 700 .ssh && touch .ssh/$KEYFILE \
     && chmod 644 .ssh/$KEYFILE \
     && echo '$PAYLOAD' >> .ssh/$KEYFILE \
     && rm -f $SSHKEY"
echo "Successfully transferred SSH key for a passwordless Login."
