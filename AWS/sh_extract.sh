#! /bin/bash
ls -1 *_sechub.txt | 
while read FILE
  do 
    ROW=`echo $FILE | awk -F'_' '{print $1 "," $2}'`
    cat $FILE  | awk '{print $2 "," $1}' |
      while read TOTALS
      do 
        echo "${ROW},${TOTALS}"
      done
    done

ls -1 *members.json |
  while read FILE
  do
    ROW=`echo $FILE | awk -F'_' '{print $1 "," $2}'`
    cat $FILE | jq '.Members[].AccountId' |
      while read AID
      do
        echo "${ROW},member,${AID}"
      done
   done
