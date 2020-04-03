#!/bin/bash

cat $1 | 
gawk '
ORS="";
/^Account/ {ACC=$2}
/^Device: / {DEVICE=$2; HOST=$3};
/^Platform: / {PLATFORM=gensub("Platform: ", "", "g", $0)};
/^Type: / {OS=$2};
/^Primary IP: / {IP=$3};
/^DataCenter: / {LOC=$2};
/^Interface:/ {
	INT=$2
	aINTNO[INT]++;
	NICINDEX=INT aINTNO[INT];
}
/^Online: / {ONLINE=$2 " " $3};
/^Status:/ {switch ($0) {
	case /Suspended VM-Replication/: {STATUS=0; break;}
	case /Online\/Complete/: {STATUS=1; break;}
	case /Ready for Account Team/: {STATUS=2; break;}
	case /Segment Configuration/: {STATUS=4; break;}
	case /Ready for Account Team/: {STATUS=8; break;}
	default: STATUS=1;
	}
}
/^Switch Name:/ { split($3, aSWITCH, ":"); DC=aSWITCH[1]; SWITCH=aSWITCH[2]; aNICS[NICINDEX] = DC "-" SWITCH}
/^Port:/ {PORT=$2; aNICS[NICINDEX] = aNICS[NICINDEX] "-" PORT;} 
/^Device URL/ {
	print DEVICE "," HOST "," PLATFORM "," ; 
	print OS "," IP; 
	for (NIC in aNICS) {
		print "," NIC "-" aNICS[NIC];
		split(aNICS[NIC], aSTMP, "-");
		iE=length(aSTMP);
		DC=aSTMP[1]; 
		SEP=""; CAB=""; for (i=2; i<iE-1; i++) {CAB=CAB SEP aSTMP[i]; SEP="_"}
		SWITCH=aSTMP[iE-1]; 
		PORT=aSTMP[iE];
		print "INSERT INTO switch_ports VALUES (##,#" DEVICE "#,#" NIC "#,#" DC "#,#" CAB "#,#" SWITCH "#,#" PORT "#,##,##,##);\n" >> "./switch_ports.sql";
		
		};
	print "INSERT INTO host VALUES (#" DEVICE "#,#" ACC "#,#" HOST "#,#" IP "#,#" ONLINE "#,#" STATUS "#,#" LOC "#);\n" >> "./hosts.sql";
	print "\n";
	ACC="";
	HOST=""; 
	ONLINE="";
	DEVICE="";
    LOC="";
	IP=""; 
	OS=""; 
	PLATFORM=""; 
	PSWITCH0=""; 
	PSWITCH2=""; 
	MBUSWITCH=""; 
	INTNO=0;
	NICINDEX="";
	delete aNICS;
	delete aSWITCH;
	delete aPORT;
	delete aINTNO;
	delete aSTMP;
	};
END {
	print DEVICE "," HOST "," PLATFORM "," ; 
	print OS "," IP; 
	for (NIC in aNICS) {
		print "," NIC "-" aNICS[NIC];
		split(aNICS[NIC], aSTMP, "-");
		iE=length(aSTMP);
		DC=aSTMP[1]; 
		SEP=""; CAB=""; for (i=2; i<iE-1; i++) {CAB=CAB SEP aSTMP[i]; SEP="_"}
		SWITCH=aSTMP[iE-1]; 
		PORT=aSTMP[iE];
		print "INSERT INTO switch_ports VALUES (##,#" DEVICE "#,#" NIC "#,#" DC "#,#" CAB "#,#" SWITCH "#,#" PORT "#,##,##,##);\n" >> "./switch_ports.sql";
		
		};
	print "INSERT INTO host VALUES (#" DEVICE "#,#" ACC "#,#" HOST "#,#" IP "#,#" ONLINE "#,#" STATUS "#,#" LOC "#);\n" >> "./hosts.sql";
	print "\n";
}
'
# host SQL
#awk -F',' '{print "INSERT INTO host VALUES (#" $1 "#,#33826#,#" $2 "#,#" $5 "#,#1#,##,##);"}'  | sed "s/#/'/g"
