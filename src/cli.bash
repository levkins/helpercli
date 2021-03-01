#!/bin/bash

SQLruns () # parent function
{
    #/tmp/helpercli/
    randomfile=$(cat /dev/urandom | tr -dc A-Za-z0-9 | head -c 6)
    echo -e "---namedb: \e[93m$row_name \e[0m---"
    echo -e "---Look: \e[32m$randomfile "
    echo -e "\e[34m=============================\e[0m"
    sqlite3 $DB_FILE "SELECT txt FROM $tab_name \
	    WHERE name='$row_name'" > /tmp/helpercli/$randomfile.bash
    bash /tmp/helpercli/$randomfile.bash
	exit 0
}

Selecter ()
{
    echo -e "\e[1;33mHello, Human! \e[0m"
        ar_tabl_db=($(sqlite3 $DB_FILE "SELECT tbl_name FROM "main".sqlite_master WHERE type='table'") )
    echo -e "\e[93m===> Select table:"
    echo -e "For EXIT, press any letter \e[0m"
    echo "----------------------------------"
    select tab_name in $(sqlite3 $DB_FILE "SELECT tbl_name FROM "main".sqlite_master WHERE type='table'");
    do echo "TABLE: $tab_name" ; break ; done
    
    echo -e "\e[93m===> Select name $tabledb: \e[0m"
    select row_name in $(sqlite3 $DB_FILE "SELECT name FROM $tab_name")
    do
        echo "ROW: $row_name"
        echo $(sqlite3 $DB_FILE "SELECT other FROM $tab_name WHERE name='$row_name'")
        break
    done
    echo "----------------------------------"
    export -f SQLruns ; sleep 3 ; SQLruns
}

if [ -z $2 ]; then tab_name=node
  else row_name=$1 ; tab_name=$2 ; SQLruns;exit ; fi
if [ -z $1 ]; then continue ; else row_name=$1 ; SQLruns;exit ; fi

Selecter
