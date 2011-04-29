#!/bin/sh
# VMware clone script


if [ $# != 2 ]; then
	echo "\nUsage: $0 <original VM name> <new VM name>\n"
	exit 127
fi

SOURCE="$1"
DEST="$2"

echo "SOURCE is \"$SOURCE\""
echo "DEST is \"$DEST\""

if [ "`ls "$SOURCE" | grep "\.lck$"`" != "" ]; then
	echo "Shut down the VM \"$SOURCE\" first"
	exit 127
fi

if [ "`ls | grep "$DEST"`" != "" ]; then
	echo "Destination VM already exists - pick a new name or delete first"
	exit 127
fi

echo "\nCopying:"
cp -Rv "$SOURCE" "$DEST"

echo "\nRenaming files in $DEST:"
ls "$DEST" | grep "^$SOURCE" | while read FILE
do
        mv -v "$DEST/$FILE" "$DEST/`echo $FILE | sed -e \"s/^$SOURCE/$DEST/\"`"
done

echo "\nReplacing \"$SOURCE\" with \"$DEST\" in text files:"
ls "$DEST" | grep -v "\(\.nvram$\|\.vmdk$\|\.log$\)" | while read FILE
do
	echo "Doing \"$DEST/$FILE\", writing to \"$DEST/$FILE.temp\""
	sed -e "s/$SOURCE/$DEST/g" "$DEST/$FILE" > "$DEST/$FILE.temp"
done

echo "\nRenaming temp files to get rid of \".temp\":"
ls "$DEST" | grep "\.temp$" | while read FILE
do
	mv -vf "$DEST/$FILE" "$DEST/`echo $FILE | sed -e \"s/\.temp//\"`"
done

echo "\n(Re)Setting permissions:"
chown -Rv root:root "$DEST"
chmod -v 755 "$DEST"
chmod -v 600 "$DEST"/*
chmod -v +rx "$DEST"/*.vmx
chmod -v +r "$DEST"/*.log
