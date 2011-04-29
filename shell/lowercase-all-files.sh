# This script will take all files in the CWD and translate them all to lowercase.  Useful for 
# using sort, since sometimes mixed uppercase/lowercase first letters will mess up alphabetizing
#!/bin/bash
for i in $(ls); do
  oldname="$i"
  newname=$(echo "$oldname" | tr 'A-Z' 'a-z')
  if [ "$oldname" != "$newname" ]
  then
      mv -i "$oldname" "$newname"
  fi
done