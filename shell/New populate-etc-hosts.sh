#!/bin/ksh
x=1
while [ $x -lt 255 ]
do
   echo "192.168.2.$x host_$x"
   x=$((x + 1 ))
done >> /etc/hosts