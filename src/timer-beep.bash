#!/bin/bash

echo "Enter time in sec: "
read TimeSec
for ((i=$TimeSec ; i>0; i--)); do
    sleep 1
    printf "$i> "
    #wait
done
speaker-test -t sine -p 500 -f 1000 -l 1

