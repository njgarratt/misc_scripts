#!/bin/bash 

DDI=$1
ACCT=$2
INSIGHT='{ "Name": "Severity_Count", "Filters": { "ProductName": [ { "Value": "Security Hub", "Comparison": "EQUALS" } ], "RecordState": [ { "Value": "ACTIVE", "Comparison": "EQUALS" } ] , "LastObservedAt": [{"DateRange": {"Value": 30, "Unit": "DAYS" }}] }, "GroupByAttribute": "SeverityLabel" }'

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


aws ec2 describe-regions | jq -r '.Regions[].RegionName' |
while read REGION; 
do
    echo $REGION
    PREFIX="./data/$(printf '%012s\n' ${ACCT})_${REGION}"
    DETECTOR=`aws --region=$REGION guardduty list-detectors | jq -r '.DetectorIds[0]'`
     if [ $DETECTOR !=  "null" ]
      then 
          echo $DETECTOR
          aws  --region $REGION guardduty list-members --detector-id $DETECTOR > ${PREFIX}_gd_members.json
          aws  --region $REGION guardduty get-findings-statistics --detector-id $DETECTOR --finding-statistic-types COUNT_BY_SEVERITY > ${PREFIX}_gd.json
       else 
         echo "NO Detector in region"; 
     fi

     # is Security Hub enabled in this region?
     if aws --region $REGION securityhub describe-hub > /dev/null 2>&1
     then 
       # We have SH enabled here
        echo "Security Hub enabled"
        aws --region $REGION securityhub list-members > ${PREFIX}_sh_members.json
        aws --region $REGION securityhub get-findings --filter='{  "ProductName": [ { "Value": "Security Hub", "Comparison": "EQUALS" } ], "RecordState": [ { "Value": "ACTIVE", "Comparison": "EQUALS" } ], "LastObservedAt": [{"DateRange": {"Value": 30, "Unit": "DAYS" }}], "SeverityLabel": [{"Value": "HIGH", "Comparison": "EQUALS"}, {"Value": "CRITICAL", "Comparison": "EQUALS"}, {"Value": "MEDIUM", "Comparison": "EQUALS"}, {"Value": "LOW", "Comparison": "EQUALS"}]}' | jq -r '.Findings[].ProductFields."aws/securityhub/SeverityLabel"' | sort | uniq -c > ${PREFIX}_sechub.txt

        # create a temporary insight to gather the stats. more efficient, but requires a change
        #ARN=`aws --region $REGION securityhub create-insight --name sevlabel_statistics --cli-input-json "$INSIGHT" | jq -r '.InsightArn'`
        #aws --region $REGION securityhub get-insight-results --insight-arn $ARN
        #aws --region $REGION securityhub delete-insight  --insight-arn $ARN
     else 
        echo "Security Hub NOT enabled"
     fi

done

#aws --region eu-west-1 securityhub get-findings --filter='{ "LastObservedAt": [{"DateRange": {"Value": 30, "Unit": "DAYS" }}], "SeverityLabel": [{"Value": "HIGH", "Comparison": "EQUALS"}, {"Value": "CRITICAL", "Comparison": "EQUALS"}]}' | jq '.Findings[].Severity.Normalized' | sort | uniq -c
# aws --region eu-west-1 securityhub get-findings --filter='{ "LastObservedAt": [{"DateRange": {"Value": 30, "Unit": "DAYS" }}], "SeverityLabel": [{"Value": "HIGH", "Comparison": "EQUALS"}, {"Value": "CRITICAL", "Comparison": "EQUALS"}]}' | jq '.Findings[].ProductFields."aws/securityhub/SeverityLabel"' | sort | uniq -c
#aws --region eu-west-1 securityhub get-findings --filter='{  "ProductName": [ { "Value": "Security Hub", "Comparison": "EQUALS" } ], "LastObservedAt": [{"DateRange": {"Value": 30, "Unit": "DAYS" }}], "SeverityLabel": [{"Value": "HIGH", "Comparison": "EQUALS"}, {"Value": "CRITICAL", "Comparison": "EQUALS"}, {"Value": "MEDIUM", "Comparison": "EQUALS"}]}' | jq -r '.Findings[].ProductFields."aws/securityhub/SeverityLabel"' | sort | uniq -c
