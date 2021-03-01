#!/bin/bash

userdir=/home/$USER
cd $userdir

StartSubSystem () {
    echo "---- Работаем с $mydir ----"
    sudo mount --bind /dev/ $mydir/dev/
    sudo mount --bind /dev/pts/ $mydir/dev/pts/
    sudo mount --bind /dev/shm/ $mydir/dev/shm/
    sudo mount --bind /run/ $mydir/run/
    sudo mount --bind /sys/ $mydir/sys/
    sudo mount --bind /proc/ $mydir/proc/
    xhost + > /dev/null 
    sudo mount -l | grep $mydir
    echo "---Start?---" ; read next
    sudo chroot $mydir /usr/bin/env -i HOME=/root TERM="$TERM" /bin/bash --login
}


Exited () {
    echo "start umount $mydir/dev/ Its OK?"
    #echo "Need: $userdir/mnt/fed-leo "
    read mydir /home/leo/mnt/fed-leo
    sudo umount -l /home/leo/mnt/fed-leo/sys/ ; sleep 5
    sudo umount -l /home/leo/mnt/fed-leo/run/ ; sleep 5
    sudo umount -l /home/leo/mnt/fed-leo/proc/ ; sleep 5
    sudo umount -l /home/leo/mnt/fed-leo/dev/pts/ ; sleep 5
    sudo umount -l /home/leo/mnt/fed-leo/dev/shm/ ; sleep 5
    sudo umount -l /home/leo/mnt/fed-leo/dev/ ; sleep 5
    #sudo umount -l /home/leo/mnt/fed-leo
    echo "---Проверка выхода из окружения---"
    echo "mount> $mydir "
    sudo mount -l | grep $mydir
    xhost -
    StartForm
}

MountDir () {
    if [ "$seldistr" -eq 3 ];
        then mydir=$userdir/mnt/fed-leo ;  sudo tar -xf $userdir/my-fedora.tar -C ./ ; StartSubSystem
    elif [ "$seldistr" -eq 4 ];
        then lsblk ; echo "---- Выбираем с диск /dev/xxx " ; read newdrive ; \
            sudo mount /dev/$newdrive $userdir/mnt/mint ; mydir="$userdir/mnt/mint" ; StartSubSystem
    fi
}

Arc () {
    echo "---Архивирование, ждите---"
    sudo tar -cf $userdir/my-fedora.tar ./mnt/fed-leo
    sudo rm -rf $userdir/mnt/
    ls -lh $userdir/my-fedora.tar
    echo "---Архивирование завершено---"
    StartForm
}

SelectDistro () {
    echo "Вход/выход fed-leo"
    echo "1. Вход FED"
    echo "2. Вход MINT"
    echo "3. Старт FED"
    echo "4. Старт MINT"
    echo "5. Выход из окружения"
    echo "--------------------"
    read seldistr
    
    if [ "$seldistr" -eq 1 ] ; then sudo chroot $userdir/mnt/fed-leo
    elif [ "$seldistr" -eq 2 ] ; then sudo chroot $userdir/mnt/mint
    elif [ "$seldistr" -eq 3 ] ; then MountDir
    elif [ "$seldistr" -eq 4 ] ; then MountDir
    elif [ "$seldistr" -eq 5 ] ; then Exited
    fi
    StartForm
}


StartForm () {

    echo "Монтирование/размонтирование"
    echo "1. Подключить/войти"
    echo "2. Архивирование FED"
    echo "3. Выход из окружения"
    echo ""
    echo "9. Выход из консоли"
    echo "--------------------"
    read zipfs


if [ "$zipfs" -eq 1 ] ;
        then SelectDistro #MountDir
    elif [ "$zipfs" -eq 2 ] ; 
        then Arc
    elif [ "$zipfs" -eq 3 ] ; 
        then Exited
    else exit 0
fi

}

StartForm



