#!/bin/bash
# ИИзменение базы из CLI

exiter=1
head_param=('Select TABLE: ' 'Select ROW: ' 'Select COLUMN for change: ')
sql_viewer="sqlite3 $DB_FILE"

GetScript () {
    SelecterDatabase
    echo "Get value on table: "
    echo "----------------------------------"
    columnDB=txt
    SQLget
    mv /tmp/helpercli/my_edit.bash ./$rowDB.bash
    echo
    echo "File saved on ===>: $PWD/$rowDB.bash"
    #$like_editor $PWD/$rowDB.sh
}
AddValue () {
    GetTable
    columnHeader=($($sql_viewer "pragma table_info('$tableDB')" | awk -F"|" {'print $2'}) )
    echo Table \'$tableDB\' has column: ${columnHeader[*]}
    for i in ${!columnHeader[*]}; do 
        echo "Text in: ${columnHeader[$i]}"
        read nextValue 
        if [ ${columnHeader[*]:(-1)} == ${columnHeader[$i]} ]
          then tst2+=\'$nextValue\'
          else tst2+=\'$nextValue\'\,
    fi ; done
    for i in ${!columnHeader[*]} ; do
        if [ ${columnHeader[*]:(-1)} == ${columnHeader[$i]} ]
          then tst1+=${columnHeader[$i]}
          else tst1+=${columnHeader[$i]}\,
        fi ; done

    $sql_viewer "INSERT INTO ${tableDB} ($tst1) VALUES ($tst2)"
    echo DONE: "INSERT INTO ${tableDB} ($tst1) VALUES ($tst2)"

}

GetTable () {
    ar_view=(rootpage name sqlite_master)
    cont=0
    ViewInSql
    tableDB=$arr_param
}

AddTable () {
    echo -n "New Table name:  "
    read tableDBnew
    $sql_viewer "CREATE TABLE IF NOT EXISTS ${tableDBnew} (
	    node_id INTEGER,
	    name TEXT,
	    txt TEXT,
	    tag TEXT,
	    other TEXT,
	    menu TEXT
        )"
    $sql_viewer --table --header "SELECT * FROM ${tableDBnew} "

}

SQLget () {
    $sql_viewer "SELECT ${columnDB} FROM ${tableDB} \
        WHERE name='${rowDB}'" > /tmp/helpercli/my_edit.bash
}

SQLsave () {
    $sql_viewer "UPDATE ${tableDB} \
        SET '${columnDB}'=readfile('/tmp/helpercli/my_edit.bash') \
        WHERE name='${rowDB}'"
}

InsertTXT () {
    echo "--- ATTENTION! For new row, need ADD SCRIPT first. ---"
    sleep 3
    exiter=2
    SelecterDatabase
    echo "Enter filename for insert in ${tableDB}.${rowDB} : "
    read ins_file
    $sql_viewer "UPDATE ${tableDB} SET 'txt'=readfile('$ins_file') WHERE name='${rowDB}'"
    echo DONE: 
	$sql_viewer "SELECT txt FROM ${tableDB} WHERE name='${rowDB}'"
}

Debuger () {
    SQLget
    debugim=yes
    echo -e "\e[32m  For exit - write Y (in upper) \e[m"
	while [ "$debugim" != "Y" ] ; do
		$like_editor /tmp/helpercli/my_edit.bash
		bash /tmp/helpercli/my_edit.bash
		echo
		echo -e "\e[33mSave changes? \e[m"
		read debugim
	done
	SQLsave
}

ViewInSql () {
    $sql_viewer --table --header "SELECT ${ar_view[0]},${ar_view[1]} FROM ${ar_view[2]} "
    if [ $? == 1 ]; then $sql_viewer --column --header "SELECT ${ar_view[0]},${ar_view[1]} FROM ${ar_view[2]} " ; fi
    echo -n ${head_param[$cont]} ; read sel_sort
    arr_param=$($sql_viewer "SELECT ${ar_view[1]} FROM ${ar_view[2]} WHERE ${ar_view[0]}='$sel_sort'")
}

SelecterDatabase () {
    GetTable
    # get row
    ar_view=(_rowid_ name $tableDB)
    cont=1
    ViewInSql
    rowDB=$arr_param

    [ $exiter == 2 ] && return

    # get column
    columnDB=($($sql_viewer "pragma table_info('$tableDB')" | awk -F"|" {'print $2'}) )
    cont=2
    for i in ${!columnDB[@]}; do echo "COL $i: ${columnDB[@]:$i:1}" ; done
    echo -n ${head_param[$cont]} ; read change_name
    columnDB=${columnDB[$change_name]}
}

echo "----Select task----"
echo "0. Show script
1. Get script
2. Edit script
3. Debug script
4. Add Script
5. Add Table
6. Insert TXT from file
7. 
8. Compact DB
9. Exit"
read select_task

echo "Enter editor."
echo "nano (default)"
echo "============================="
read like_editor
if [ -z $like_editor ]; then like_editor=nano ; fi
echo -e "\n \n  Please, DO NOT PRESS Ctrl+C - if you needed save changes \n \n"

case $select_task in
  0 ) GetScript ; $like_editor $PWD/$rowDB.sh ; rm -f $PWD/$rowDB.sh ; bash $0 ;;
  1 ) GetScript ; exit ;;
  2 ) SelecterDatabase ; SQLget ; $like_editor /tmp/helpercli/my_edit.bash ; SQLsave ;;
  3 ) SelecterDatabase ; Debuger ;;
  4 ) AddValue ;;
  5 ) AddTable ;;
  6 ) InsertTXT ;;
  7 ) ;;
  8 ) $sql_viewer "VACUUM main"; exit ;;
  9 ) exit 0 ;;
  * ) echo oops! - $ANSWER ;;
esac

echo "==--> GOOD BYE<---=="

