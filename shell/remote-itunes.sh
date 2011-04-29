#!/bin/bash 
dns-sd -P "name of server" _daap._tcp local 3690 localhost 127.0.0.1 & 
PID=$! 
ssh -N bruceg@bruceg.dyndns.org -p62606 -L 3690:localhost:3689
kill $PID
