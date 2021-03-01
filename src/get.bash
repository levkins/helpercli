#!/bin/bash

echo "Get value on table: "
echo "----------------------------------"
echo -n "Table name: " ; read tabledb
echo -n "Name TXT column: " ; read columndb
sqlite3 $DB_FILE "SELECT txt FROM ${tabledb} WHERE name='${columndb}'" > ./$columndb.bash
echo
echo -n "File saved on: $PWD/$columndb.sh"
echo

