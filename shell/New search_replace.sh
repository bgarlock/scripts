#!/bin/bash
#
# Search and replace utility
# Bruce Garlock 7-31-02
#
for file in $( find www -name "*.html" )
do
  cp $file ${file}.bak
  sed '1,$s/Copyright &copy; 1998, 2002/Copyright &copy; 1998, 2003/g' < ${file}.bak > $file
done

