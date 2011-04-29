#!/bin/sh
# Script to dump Inventory db for tranfser to storage
#

# remove old file
rm /tmp/inventory.sql.gz

mysqldump --add-drop-table --all --extended-insert --quick -uroot -pTT2frgw9 job --tables m_building m_buyer m_coat m_color m_finish m_grade m_grain m_info m_loc m_loc_sub m_loc_type m_lock m_log m_mfg m_pc_temp_found m_pc_temp_found_new m_stock_type m_txn_det m_txn_hdr m_txn_log m_type m_um m_vendor > /tmp/inventory.sql

# use gzip to compress the file
gzip /tmp/inventory.sql


# Copy the file to storage
/usr/bin/scp /tmp/inventory.sql.gz root@storage:/root
