#!/bin/bash
cat $1 | sort -t',' -k2 | while read LINE; do echo -n "${LINE},"; echo $LINE | sed 's/^.*(\(.*\)).*$/\1/' | awk -F':' '{print ($1*3600) + ($2*60) + $3}'; done  | sort -t',' -k2,2 | awk -F',' 'BEGIN {ALL=""; DEVNO=""; TOTAL=0}; /[0-9]\// {if (DEVNO != $2) {print ALL ", " TOTAL; TOTAL=0} else {print ALL ","}; ALL=$0; DEVNO=$2; TOTAL = TOTAL + $4}; END {print ALL ", " TOTAL;}'
