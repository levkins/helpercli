#!/bin/sh

folder=$PWD   #~/shells/
export "DB_FILE=$folder/helpercli.db"
randomfile=$(cat /dev/urandom | tr -dc A-Za-z0-9 | head -c 6)
mkdir /tmp/helpercli/
sqlite3 $DB_FILE "SELECT txt FROM node WHERE name='cli'" > /tmp/helpercli/$randomfile.sh
ls -ls /tmp/helpercli/
bash /tmp/helpercli/$randomfile.sh $1 $2
echo "Start DELETE FILES"
rm -rf /tmp/helpercli/
