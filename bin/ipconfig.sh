#!/bin/bash

cat $1 |  awk -F ':' '
/Windows IP Configuration/ { 
	HOST="";
	NIC=""; 
	MASK=""; 
	IP="";
	MAC="";
	}; 
/Host Name/ {split($2,aHOST, "-")}; 
/Ethernet adapter/ {NIC=gensub("Ethernet adapter ","", "g", $1)}; 
/IP(v4)? Address/ {IP=gensub("\\(.*$","","g",$2)}; 
/Description/ {DESC=$2}; 
/Physical Address/ {MAC=tolower(gensub("-", ":", "g", $2))}
/Subnet Mask/{
	MASK=$2; 
	print "INSERT INTO interfaces VALUES (#" aHOST[1] "#,#" MAC "#,#" NIC "#,#" IP "#,#" MASK "#,##);";
}; 
END {print "INSERT INTO interfaces VALUES (#" aHOST[1] "#,#" MAC "#,#" NIC "#,#" IP "#,#" MASK "#,##);"}'
