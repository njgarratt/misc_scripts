#!/bin/bash


cat | 
gawk -F',' 'BEGIN {iHEAD=0}; {
iHEAD++;
iFIELDS=1
CNT=0; 
split($0, aLINE); 
DATE=aLINE[1]; 
iLEN=asorti(aLINE, aTMP);
sLINE="";
iSET=1;

for (I=2; I <= iLEN+1; I++) 
{
	if (CNT == iFIELDS) 
	{
		CNT=0; 
		#print sLINE >> "LUN-" aSET[iSET]; 
		#print "LUN-" aSET[iSET]; 
		sLINE=aSET[iSET]","DATE sLINE;
		print sLINE; 
		sLINE="";
		iSET++;
	} 

	# this is a header Line
	if (iHEAD == 1)
	{
		split(aLINE[I], aTMP, " ");
		sLUN	= gensub("\"", "", "g", aTMP[1]);

		# we assume sed will be greedy here and do longest match
		"echo " aLINE[I] " | sed s/^.\\*-//g" |& getline sCOUNTER;
		#print ">>>> " sCOUNTER;

		aSET[iSET]	= sLUN":"sCOUNTER
	} else
	{
		sLINE = sLINE "," aLINE[I];
	}

	CNT++; 
}
}
END {
		#print sLINE >> "LUN-" aSET[iSET]; 
		#print "LUN-" aSET[iSET]; 
		sLINE=aSET[iSET]","DATE sLINE;
		print sLINE; 
}'

#cat LUNs.txt | while read LUN; do DEVNO=`(echo ${LUN} | sed 's/^.*-33826-\([0-9]\+\)-.*$/\1/')`; if [[ $DEVNO =~ '^[0-9]+$' ]]; then true; else DEVNO=0; fi; echo "INSERT INTO LUNs VALUES ('','$DEVNO', '$LUN', 1)"; done > LUNS.sql

#cat LUNS.csv | while read LUNNO LUNNAME; do cat sperf.csv | sed "/^${LUNNAME}/s/^${LUNNAME}:/${LUNNO},/g" > sperf.csv.SED; mv sperf.csv.SED sperf.csv; done

# cat sperf.csv | gawk -F',' '{print "INSERT INTO LUN_counters VALUES (#" $1 "#, str_to_date(" $3 ",#%a %b %d %T GMT %Y#), #" $2 "#, #" $4 "#);"}' > LUN_counters.sql
