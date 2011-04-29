!#/bin/sh
# Script to display the last date a user logged in from the vpn
# FIXME:  started on 23 OCT, did not finish - want to get each username from 
# /etc/ppp/chap-secrets

grep "peer authentication succeeded" messages*|grep -m1 bruceg
