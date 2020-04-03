#!/bin/bash
cat  $1 |
awk '
/^### / {DEVICENO=gensub("::[0-9]+-.*$","","g",$2);INT=""; };
/^[0-9]{1,2}:[ 	]+[a-z]+[0-9]/ {INT=gensub(":", "", "g", $2)};
/link/ {MAC=$2}
/inet / { 
	if (INT != "") {
		split($2, aTMP, "/");
		IP=aTMP[1];
		"ipcalc -m " $2 | getline MASK;
		close("ipcalc -m " $2);
		split(MASK, aTMP, "=");
		MASK=aTMP[2];
	print "INSERT INTO interfaces VALUES (#" DEVICENO "#,#" MAC "#,#" INT "#,#" IP "#,#" MASK "#,##);";
	IP = 0;
	NETMASK = 0;
	} 
}
'
