#!/bin/bash -x

DDI=$1
ACCT=$2
REGION=$3


FAWS=~/Downloads/faws-darwin/faws
echo "auth ${DDI} $(printf '%012s\n' ${ACCT})"
#eval "$($FAWS env -r ${DDI} -a $(printf '%012s\n' ${ACCT}))"

if ENV=$($FAWS env -r ${DDI} -a $(printf '%012s\n' ${ACCT}))
then
  echo "Authenticated"
  eval "$ENV"
  env | grep AWS
else
   echo "${DDI}  $(printf '%012s\n' ${ACCT}) not authenticated!"
   exit
fi

echo $REGION
PREFIX="./data/$(printf '%012s\n' ${ACCT})_${REGION}"
DETECTOR=`aws --region=$REGION guardduty list-detectors | jq -r '.DetectorIds[0]'`
 if [ $DETECTOR !=  "null" ]
  then 
      echo $DETECTOR
      aws  --region $REGION guardduty list-members --detector-id $DETECTOR > ${PREFIX}_gd_members.json
   else 
     echo "no Detector in region"; 
 fi

