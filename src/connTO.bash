#!/bin/bash
tabledb=connection

AdvConn () # просто хотел сделать этот мир проще...
{
    echo -n "Укажи логин:  " ; read login_srv
    echo -n "Укажи адрес:  " ; read address_srv
    cert2conn=( `ls ~/.ssh/` )
    echo "Найдены ключи, какой использовать?"
    echo ${cert2conn[*]}
    for ((i=0; i<${#cert2conn[@]}; i++)); do echo "cert:$i-> ${cert2conn[@]:$i:1}" ; done
    read name_cert
    echo -n "Укажи особый порт:  " ; read new_port
    echo -n "Использовать Х-сервер (y/N):  " ; read x_srv
    echo -n "Добавить это подключение в таблицу (y/N):  " ; read add_srv
    echo START CONNECT ON $add2conn:$newport WHITH LOGIN $log2conn
    #ssh -v $log2conn@$add2conn
}


sqlite3 -table -header $DB_FILE "SELECT _rowid_,name,company FROM $tabledb "
if [ $? == 1 ]; then sqlite3 -column -header $DB_FILE "SELECT _rowid_,name,company FROM $tabledb " ; fi
echo -e "\e[93m===> Select type (name of the server):"
echo -e "EXIT - pres any letter \e[0m"
echo "----------------------------------"
echo -n "Number table: " ; read TypeTableDb
if [[ $TypeTableDb == D ]]; then AdvConn
elif [[ $TypeTableDb != *[[:digit:]]* ]]; then echo "OK! BYE!" ; exit ; fi
ssh2conn=($(sqlite3 $DB_FILE --column "SELECT login,address,port,key \
    FROM $tabledb WHERE _rowid_= '$TypeTableDb'"))
echo ${#ssh2conn[*]} ${ssh2conn[*]}
echo START CONNECT ON ${ssh2conn[1]}:${ssh2conn[2]} WHITH LOGIN ${ssh2conn[0]}
    case ${#ssh2conn[*]} in
        2) ssh ${ssh2conn[0]}@${ssh2conn[1]} ;;
        3) ssh -p ${ssh2conn[2]} ${ssh2conn[0]}@${ssh2conn[1]} ;;
        4) ssh -p ${ssh2conn[2]} -i ${ssh2conn[3]} ${ssh2conn[0]}@${ssh2conn[1]} ;;
        *) echo ------------NONE--------------------- ;;
    esac
exit 0

