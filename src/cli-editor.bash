#!/bin/bash
# Модификация консоли (done)

echo "Hello, people! Select format"

all_console=('user@host' '' '[user@host]' '' '(user@host)')
type_console=('' '' '[' ']' '(' ')')

for ((i=0; i<${#all_console[@]}; i++)); do echo "type $i: ${all_console[@]:$i:1}" ; done
read allconsole

echo "SELECTED: ${all_console[$allconsole]}"

atlas_command=('Date full, example, THU, OCT, 17.'
'Short hostname'
'Full hostname'
'Time in 24h - HH:MM:SS'
'Time in 12h - am/pm'
'Shortly time - HH:MM'
'Username'
'Active directory (full address)'
'Active directory (short, only active dir)'
'Symbol permission ($ or #)'
'New line'
'Shell name'
'Number command')

atlascommand=(d h H t @ A u w W '$' n s '#')

Chooser () {
echo "Choose $number of 5 value"
for ((i=0; i<${#atlas_command[@]}; i++)); do echo "type $i: ${atlas_command[@]:$i:1}" ; done
read valueatlas
for ((i=90; i<99; i++)); do
    #sleep 1
    echo -e "\e[${i}mColor $i for your script... \e[00m"
    #wait
done
read coloratlas
echo -e "${type_console[allconsole]}$var1$sep_var1$var2$sep_var2$var3$sep_var3$var4$sep_var4$var5${type_console[*]:${allconsole}+1:1} $sep_end\e[${colorcon}m "

}

number=1 ; Chooser
var1="\e[${coloratlas}m\\${atlascommand[$valueatlas]}"
echo "Enter separate (if not need, press ENTER)"
read sep_var1

number=2 ; Chooser
var2="\e[${coloratlas}m\\${atlascommand[$valueatlas]}"
echo "Enter separate (if not need, press ENTER)"
read sep_var2

number=3 ; Chooser
var3="\e[${coloratlas}m\\${atlascommand[$valueatlas]}"
echo "Enter separate (if not need, press ENTER)"
read sep_var3

number=4 ; Chooser
var4="\e[${coloratlas}m\\${atlascommand[$valueatlas]}"
echo "Enter separate (if not need, press ENTER)"
read sep_var4

number=5 ; Chooser
var5="\e[${coloratlas}m\\${atlascommand[$valueatlas]}"

echo "Enter symbol for END of prompt"
read read sep_end
echo ""
echo Select color for other console
for ((c=90; c<99; c++)); do
    echo -e "\e[${c}mColor $c for other console: \e[00m"
done
read colorcon
echo "Copy follow text in file \'/home/$USER/.bashrc\' and update env - 'source /home/$USER/.bashrc\' " ; echo 
echo PS1=\"${type_console[allconsole]}$var1$sep_var1$var2$sep_var2$var3$sep_var3$var4$sep_var4$var5${type_console[*]:${allconsole}+1:1} $sep_end\\e[${colorcon}m \"
echo 
echo "------------BYE------------"
# my variant cli: PS1="[\e[90m\A \e[92m\u@\e[92m\h:\e[93m\#: \e[94m(\w]) > \e[98m\e[00m"
exit 0

