#!/bin/bash
if [ "$(whoami)" != 'root' ]; then
        echo "Start ROOT";
        sudo bash $0
        exit 0
fi

echo "Hello! Enter the name of the package you want to find. If you just need to update - press ENTER
And then I will do everything."
read start_step

#Ведем учет установленных программ
machine_name=`uname -n`

Updater ()
{
    echo "Начинаем обновление!"
    if [ -x "`which dnf`" ]
      then dnf upgrade -y ; exit
    fi

    echo "\n --START CLEAN--"
    apt autoclean ; sudo apt autoremove -y
    echo "\n --START UPGRADE--"
    apt update ;  apt dist-upgrade -y ;  apt autoclean ;  apt autoremove -y
    echo "---DONE!---"
}

Installer ()
{
    echo "Работаем пакетами!"
    packs=$start_step
    if [ ! -x "`which dnf`" ]
      then SIN=apt
      else SIN=dnf
    fi
    $SIN search $packs
    sleep 10
    echo -n "Install -- $packs ? "
    read InsPack
    if [ -z "$InsPack" ]
      then InsPack=$packs
    fi
    $SIN install $InsPack -y
    echo "$InsPack #$machine_name" >> installed-list.txt
}

if [ -z "$start_step" ]
     then Updater
     else Installer
fi

echo "==================> Completed!"
#sleep 5
