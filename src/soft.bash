#!/bin/bash

#Работа с моим софтом в среде CHROOT

array_soft=($(cat ./installed-list.txt | awk {'print $1'}))
for ((i=0; i<${#array_soft[@]}; i++)); do echo "$i: ${array_soft[@]:$i:1}" ; done
echo -n "Выбор проги: " ; read NameSoft
echo Start: ${array_soft[$NameSoft]} ; sleep 3
${array_soft[$NameSoft]} &
sleep 10
