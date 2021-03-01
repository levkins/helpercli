#!/bin/bash

if [ "$(whoami)" != 'root' ]; then
        echo "Start ROOT";
        sudo bash $0
        exit 0
fi

ServiceDisable ()
{
systemctl list-unit-files --type=service | grep enabled
echo "--Начинаем отключение сервисов--"

ar_service=(libvirtd.service
spice-vdagentd.service
vgauthd.service
vmtoolsd.service
avahi-daemon.service
brltty.service
whoopsie.service
abrt-ccpp.service
abrt-oops.service
abrt-vmcore.service
abrt-xorg.service
abrtd.service
bluetooth.service
lvm2-monitor.service
dmraid-activation.service
iscsi.service
mdmonitor.service
multipathd.service
ModemManager.service
cups.service
cups-browsed.service
anacron-resume.service
anacron.service
cron.service
atd.service
)

for ups in ${ar_service[*]};
do
    echo "Работаем с: $ups"
    systemctl stop $ups ; systemctl disable $ups
done
sleep 5
echo "--Запущенные процессы: "
systemctl list-unit-files --type=service | grep enabled
echo "--Отключаю ускорение поиска"
systemctl --user mask tracker-store.service
systemctl --user mask tracker-miner-fs.service
systemctl --user mask tracker-miner-rss.service
systemctl --user mask tracker-extract.service
systemctl --user mask tracker-miner-apps.service
systemctl --user mask tracker-writeback.service
}

SoftClean ()
{
echo "--Начинаем очистку от мусора"
dnf erase orca -y
pkcon refresh force
rm -v -f ~/.cache/thumbnails/*/*.png ~/.thumbnails/*/*.png
rm -v -f ~/.cache/thumbnails/*/*/*.png ~/.thumbnails/*/*/*.png
sed -i 's/installonly_limit=3/installonly_limit=2/' /etc/dnf/dnf.conf
journalctl --vacuum-size=32M
echo "--Завершена очистка от мусора"
}

HardOptimization ()
{
echo "--Аппаратная настройка"
echo "--Качество файла подкачки" ; cat /proc/sys/vm/swappiness
sh -c "echo 'vm.swappiness=2' >> /etc/sysctl.d/95-sysctl.conf"
sysctl -p /etc/sysctl.d/95-sysctl.conf
sh -c "echo 'vm.vfs_cache_pressure=50' >> /etc/sysctl.d/96-sysctl.conf"
sysctl -p /etc/sysctl.d/96-sysctl.conf 
echo "--Новое качество файла подкачки: " ; cat /proc/sys/vm/swappiness
}


Maintence ()
{
    echo "=========Добро пожаловать========="
    echo "1. Службы"
    echo "2. Очистка ПО"
    echo "3. Настройка аппаратная"
    echo "4. "
    echo "5. "
    echo "6. "
    echo "7. "
    echo "8. "
    echo "9. Выход"
    echo "--------------------------"
    echo "Select next step: "
read NextStep

case $NextStep in
   1) ServiceDisable ;;
   2) SoftClean ;;
   3) HardOptimization ;;
   4)  ;;
   5)  ;;
   6)  ;;
   7)  ;;
   8)  ;;
   9) exit 0 ;;
    *) echo "You entered: $NextStep but this not corrected" ;;
esac
Maintence
}


Maintence

