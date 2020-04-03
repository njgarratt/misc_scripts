#!/bin/bash

cat $1 | 
awk '
BEGIN {INT=""};
/^### / { 
	for (PEER in PEERS) {print "INSERT INTO peers VALUES (#" DEVICENO "#,#" PEER "#);"}
	HOST=$2;
	print ">>>>>>>> " HOST;
	DEVICENO=gensub("::[a-z0-9]+.*$", "", "g", HOST);
};
/^[a-z]+[0-9]/ {INT=$1};
/inet addr/ { if (INT != "") {
	IP=gensub("addr:" ,"", "g",  $2);
	NETMASK=gensub("Mask:", "", "g", $4);
	print "INSERT INTO interfaces VALUES (#" DEVICENO "#,#" INT "#,#" IP "#,#" NETMASK "#);";
	IP = 0;
	NETMASK = 0;
	INT="";
	}
}
/^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+[ 	]+[1-9]/ {print "INSERT INTO routes VALUES (#" DEVICENO "#, #" $1 "#,#" $3 "#,#" $2 "#);";}
/^tcp/ {PEERS[gensub(":[0-9]+", "", "g", $5)]++}
'
