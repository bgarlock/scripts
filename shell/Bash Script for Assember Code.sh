#!/bin/sh 
# This is just a simply script made in few minutes 
# written by brainnolo 
# modified by robthebrew 
# usage: asm2hex arch 'opcode' 
# where arch is one of ppc or i386 
# eg asm2hex ppc 'li r3,0x0' 

if [ -z "$1" ] 
then 
echo "Usage: asm2hex arch 'opcode'" 
echo "Where arch is ppc or i386. If no arch is specified" 
echo "then the achitecture of the local machine is assumed" 
echo " the opcode should be in single quotes" 

exit 
else 

if [ -z "$2" ] 
then 
echo $1 > /tmp/instruction 
archi=$(machine) 

else 
echo $2 > /tmp/instruction 
archi=$1 

fi 

as -arch $archi -f -o /tmp/asm2hex.tmp /tmp/instruction 
echo -n '0x' 
# NOTE: next line edited to get rid of the superfluous zeros 8/july/06 
otool -t /tmp/asm2hex.tmp | tail -n 1 | sed ``s/\ //g'' | sed ``s/^00000000//g'' 
rm /tmp/asm2hex.tmp 
rm /tmp/instruction 
fi 
exit 0