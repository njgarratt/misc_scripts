#!/bin/bash

# summarise running config from a catalyst switch

cat $1 | awk '
/^vlan [0-9]/ {VID=$2; getline; aVLANS[$2] = VID};
/hostname/ {

    for (VLABEL in aVLANS) {
        print HOST ",," VLABEL ",,," aVLANS[VLABEL];
    }
    delete aVLANS;
    HOST=$2

	split(HOST, aTMP, "[-.]"); 
	CAB=toupper(aTMP[1]); 
	SWITCH=toupper(aTMP[2]); 
    DC=toupper(aTMP[3]);
};
/^[ 	]*interface/ {
	print HOST "," INT "," DESC "," SHUT "," MODE "," VLAN "," ALLOWED "," PO;
    print "update switch_ports set mode=#" MODE "#, VLAN=#" VLAN "#, allowed_VLAN=#" ALLOWED "# where cabinet=#" CAB "# and switch=#" SWITCH "# and portno=#" PORTNO "#;"
	INT=$2;
	split($2, aTMP, "\/"); 
    PORTNO=aTMP[length(aTMP)];
	DESC="";
	VLAN="";
	MODE="";
	ALLOWED="";
	SHUT="N";
	PO="";
	DESC="";
}; 
/description/ {for (i=2; i <= NF; i++) {DESC = DESC " " $i}}; 
/switchport access/ {VLAN=$4; MODE="access"}; 
/switchport mode/ {MODE=$3}; 
/switchport trunk allowed/ {ALLOWED=gensub(",", ";", "g", $5)}; 
/shutdown/ {SHUT="Y"}; 
/channel-group/ {PO=$2};
END {
    print HOST "," INT "," DESC "," SHUT "," MODE "," VLAN "," ALLOWED "," PO;
    for (VLABEL in aVLANS) {
        print HOST ",," VLABEL ",,," aVLANS[VLABEL];
    }
}'

