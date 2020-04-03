#!/bin/bash

# Takes Environment Manager CSV and creates IPs_pubpriv.csv with the following format:
# 417157-db01,GW01,ro,Public ,5.79.8.0*,172.30.8.4,172.30.8.0/24

cat $1 | 
gawk -F',' '
/Public|Private/ {
	split($9, aTmp1, "\."); 
	split(aTmp1[1], aHOST, "-");
    HOST	= tolower(aTmp1[1]);
    DEVNO   = $7
}

/Public/ {
	split($11, aTmp2, " ");
    if (aTmp2[1] != "")
    {
        PubIP	= $2;
        PubNet  = $4
        PUBPRIV	= $3;
        PrivIP	= aTmp2[1];
        PrivNet	= aTmp2[3];

        aIP[PrivIP]["PubIP"]    = PubIP;
        aIP[PrivIP]["PubNet"]   = PubNet;
        aIP[PrivIP]["DEVNO"]    = DEVNO;
        aIP[PrivIP]["PrivNet"]  = PrivNet;
        aIP[PrivIP]["Host"]     = HOST;

        if (aHOST[3] == "") {
            GW	= aTmp1[2];
            REGION	= aTmp1[3];
        } else {
            GW      = gensub("^(gw[0-9]{2,3}).*$", "\\1", "g", aHOST[5]);
            REGION  = aHOST[4];
        }
        #print DEVNO "," tolower(HOST) "," tolower(GW) "," tolower(REGION) "," PUBPRIV "," PubIP "," PrivIP "," PrivNet;
        }
}
/Private/ {
    PrivIP  = $2;
    PrivNet = $4
    aIP[PrivIP]["PrivNet"]  = PrivNet;
    aIP[PrivIP]["DEVNO"]    = DEVNO;
    aIP[PrivIP]["Host"]     = HOST;
}

END {
    for (PIP in aIP) {
        print "INSERT INTO IP_new (devno,pubIP,pubNet,privIP,privNet) values (" aIP[PIP]["DEVNO"] ",#" aIP[PIP]["PubIP"] "#,#" aIP[PIP]["PubNet"] "#,#" PIP "#,#" aIP[PIP]["PrivNet"] "#);"
    }
}
'
