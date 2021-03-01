#!/bin/bash

SQLruns () #Родитель остальных действий
{
    #/tmp/helpercli/
    randomfile=$(cat /dev/urandom | tr -dc A-Za-z0-9 | head -c 6)
    echo -e "---namedb: \e[93m$namedb \e[0m---"
    echo -e "---Look: \e[32m$randomfile "
    echo -e "\e[34m=============================\e[0m"
    sqlite3 $DB_FILE "SELECT txt FROM ${tabledb} \
            WHERE name='${namedb}'" > /tmp/helpercli/$randomfile.bash 
    sh /tmp/helpercli/$randomfile.bash
        exit 0
}

MenuForm ()
{
MENU_ANSWER=$($DIALOG  \
    --cancel-button "Exit" \
    --title "Меню таблицы" \
    --menu "НУ давай, нажимай" 20 40 8\
        0 ${ar_menu_db[0]} \
        1 ${ar_menu_db[1]} \
        2 ${ar_menu_db[2]} \
        3 ${ar_menu_db[3]} \
        4 ${ar_menu_db[4]} \
        5 ${ar_menu_db[5]} \
        6 ${ar_menu_db[6]} \
        7 ${ar_menu_db[7]} \
        8 ${ar_menu_db[8]} \
        9 ${ar_menu_db[9]} \
        10 ${ar_menu_db[10]} \
        11 ${ar_menu_db[11]} \
        12 ${ar_menu_db[12]} \
        13 ${ar_menu_db[13]} \
        14 " ${ar_menu_db[14]} " 3>&1 1>&2 2>&3)
#if [ $? != 0 ]
# then echo $? Exit ; exit 0
#fi
#RunerSql
}

RunerSql ()
{
    tabledb=${ar_tabl_db[$TAB_ANSWER]}
    ar_menu_db=($(sqlite3 $DB_FILE "SELECT menu FROM $tabledb ") )
    ar_name_db=($(sqlite3 $DB_FILE "SELECT name FROM $tabledb") )
    MenuForm
    namedb=${ar_name_db[$MENU_ANSWER]}

    echo "Запускаем 3сек ===> $namedb in $tabledb "
    export -f SQLruns ; sleep 3 ; SQLruns
}

TabForm ()
{
TAB_ANSWER=$($DIALOG  \
    --cancel-button "Exit" \
    --title "Выбор таблицы" \
    --menu "Сделай же свой выбор" 20 40 8\
        0 ${ar_tabl_db[0]} \
        1 ${ar_tabl_db[1]} \
        2 ${ar_tabl_db[2]} \
        3 ${ar_tabl_db[3]} \
        4 ${ar_tabl_db[4]} \
        5 ${ar_tabl_db[5]} \
        6 ${ar_tabl_db[6]} \
        7 ${ar_tabl_db[7]} \
        8 ${ar_tabl_db[8]} \
        9 "BYE" 3>&1 1>&2 2>&3)
if [ $? != 0 ]
 then echo $? ; exit 0
fi
RunerSql
}


if [ ! -x "`which whiptail`" ] ; then dnf install newt -y ; fi
DIALOG=whiptail
if [ ! -x "`which "$DIALOG"`" ] ; then DIALOG=newt ; fi

ar_tabl_db=($(sqlite3 $DB_FILE "SELECT tbl_name FROM "main".sqlite_master WHERE type='table'") )
TabForm



