#!/bin/bash
#cat switches.csv | awk -F';' '
cat $1 | awk -F';' '
/access|trunk/ {
	split($1, aTMP, "-"); 
	CAB=toupper(aTMP[1]); 
	SWITCH=toupper(aTMP[2]); 
	split($2, aTMP, "\/"); 
	PORTNO=aTMP[length(aTMP)]; 
}
/access/ {
	if ($6 != "") {
		print "update switch_ports set mode=#access#, VLAN=#" $6 "# where cabinet=#" CAB "# and switch=#" SWITCH "# and portno=#" PORTNO "#;"
		}
	}
/trunk/ {
	if ($7 != "") {
		print "update switch_ports set mode=#trunk#, allowed_VLAN=#" $7 "# where cabinet=#" CAB "# and switch=#" SWITCH "# and portno=#" PORTNO "#;"
		}
	}'
