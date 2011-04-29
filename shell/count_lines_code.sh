#!/bin/bash

# 30 December 2008:  B. Garlock
# initial version for count_lines_code.sh

# This find command, used in conjunction with egrep and wc, will count all the lines in 
# php source files, as well as some other filetypes as identified in the egrep line starting
# with egrep '\php|\.as......'  you can add additional file types their to include them
# in the counting of lines of code.

# usage: simply run this from within the root of a project folder, and it will recursively
#        count all the lines of code, and not count the lines of code with subversion
#        hidden folders that are usually part of the project folder base in the .svn
#        folder.

find . -path './pma' -prune -o -path './blog' -prune -o -path './punbb' -prune -o -path './js/3rdparty' -prune -o -print | egrep '\.php|\.as|\.sql|\.css|\.js' | grep -v '\.svn' | xargs cat | sed '/^\s*$/d' | wc -l
