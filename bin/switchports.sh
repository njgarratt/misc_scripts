#!/bin/bash

cat $1 | 
awk '
/^Device: / {DEVICE=$2};
/^Interface:/ {
	split($1, aINT, ":"); 
	INT=aINT[2]; 
	aINTNO[INT]++;
	NICINDEX=INT aINTNO[INT];
}
/^Switch Location:/ {
	split($2, aSWITCH, ":");
	split(aSWITCH[3], aCAB, "-");
	DC=aSWITCH[2];
	CAB=aCAB[1];
	SWITCH=aCAB[2];
	aNICS[NICINDEX] = aSWITCH[2] "-" aSWITCH[3];
}
/^Port:/ {
	split($1, aPORT, ":");
	PORT=aPORT[2];
	aNICS[NICINDEX] = aNICS[NICINDEX] "-" aPORT[2];
	print "INSERT INTO switch_ports VALUES (##,#" DEVICE "#,#" NICINDEX "#,#" DC "#,#" CAB "#,#" SWITCH "#,#" PORT "#);"; 
} 
/^Link/ {
	DEVICE="";
	INTNO=0;
	NICINDEX="";
	SWITCH="";
	delete aSWITCH;
	delete aCAB;
	delete aPORT;
	delete aINTNO;
	};
'
