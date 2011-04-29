# Refresh the DB's after a change

# dump out the latest open_orders
echo "dumping latest open_orders..."
TERM=xterm; export TERM; /usr/bin/lynx -source "http://192.168.200.180/covalent/open_orders.php" 1>/dev/null 2>&1

echo "Exporting the db..."
# Export the DB
/usr/local/bin/db_export.sh

echo "Copying db to garlockprinting.com..."
# Copy the db to the remote server - garlockprinting.com
/usr/bin/scp /tmp/ord_stat.sql.gz garlockp@garlockprinting.com:/home/garlockp

echo "Copying db to storage..."
# Copy the db to the dev server
/usr/bin/scp /tmp/ord_stat.sql.gz root@storage:/root

echo "Executing update on garlockprinting.com..."
# Execute the update command on the remote server
/usr/bin/ssh -lgarlockp garlockprinting.com /home/garlockp/db_update.sh

echo "Executing update on storage..."
# Execute the update command on the dev server
/usr/bin/ssh -lroot storage /usr/local/bin/db_update.sh


