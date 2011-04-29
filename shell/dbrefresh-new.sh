# Refresh the DB's after a change

# dump out the latest open_orders
echo "dumping latest open_orders..."
TERM=xterm; export TERM; /usr/bin/lynx -source "http://192.168.200.180/covalent/oedb/internet_ord_stat/update_status.php" 1>/dev/null 2>&1

echo "Exporting the db..."
# Export the DB
/usr/local/bin/db_export-new.sh

echo "Copying db to garlockprinting.com..."
# Copy the db to the remote server - garlockprinting.com
/usr/bin/scp -P 62606 /tmp/ord_stat_new.sql.gz garlockp@garlockprinting.com:/home/garlockp

echo "Executing update on garlockprinting.com..."
# Execute the update command on the remote server
/usr/bin/ssh -t -q -p 62606 -lgarlockp garlockprinting.com /home/garlockp/db_update_new.sh



