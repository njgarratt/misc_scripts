#! /bin/bash
ls *_gd.json | 
while read FILE
  do 
    ROW=`echo $FILE | awk -F'_' '{print $1 "," $2}'`
    cat $FILE  | jq -r '.FindingStatistics.CountBySeverity|keys[] as $x | "\($x),\(.[$x])"' | 
      while read TOTALS
      do 
        echo "${ROW},${TOTALS}"
      done
    done
