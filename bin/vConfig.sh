#!/bin/bash
cat $1 | awk -F':' '
function collapse(aArray, sSEP, iPLACE)
{
	S="";
	sOUT="";
	for (I=0; I < iPLACE; I++ )
	{
		sOUT = sOUT S aArray[I];
		S=sSEP;
	}
	return sOUT;

}
#/Cluster Datastore/ {
#	print gensub("\( - \)| \\(|\\)", ";", "g", $2)
#	}
END {
		print "VM;" NAME ";" OS ";" OSCONT ";" CPU ";" RAM ";" STATE  ";" ID
}
/Cluster Name:/ {
	CLUSTER=$2;
	while ($0 !~ "Host:") {
        #print "CN";
		if ($0 ~ "CPUs") {CORES=$2};
		if ($0 ~ "Memory:") {MEM=$2};
		if ($0 ~ "Network") {
            while ($0 !~ "Datastores:") {
                print "Network;" CLUSTER ";" gensub("_","","g",$0);
                getline;
            }
        }
		if ($0 ~ "Datastores:") {
            while ($0 !~ "HostSystem")
            {
                #print "DS";
                split($0, aTMP, "\( -- \)|:");
                print "Datastore;" CLUSTER ";" gensub("_","","g",aTMP[1]) ";" aTMP[5] ";" aTMP[3];
                getline;
            }
        }
		getline; 
	}
	print "Cluster:" CLUSTER "; ESX;" CORES ";" MEM;
	CLUSTER=""; CORES=0; MEM=0; delete(aCNET); DATASORES="";
}
/Host:/ {
	HOST=$2;
	while ($0 !~ "Virtual") {
        #print "CN";
		if ($0 ~ "Cores:") {CORES=$2};
		if ($0 ~ "Memory Total:") {MEM=$2};
		if ($0 ~ "Network") {
            while ($0 !~ "Datastores:") {
                print "Network;" HOST ";" gensub("_","","g",$0);
                getline;
            }
        }
		if ($0 ~ "Datastores:") {
            while ($0 !~ "Virtual")
            {
                #print "DS";
                split($0, aTMP, "\( -- \)|:");
                print "Datastore;" HOST ";" gensub("_","","g",aTMP[1]) ";" aTMP[5] ";" aTMP[3];
                getline;
            }
        }
		getline; 
	}
	print "Host;" HOST ";" CORES ";" MEM;
	HOST=""; CORES=0; MEM=0;
}
/Virtual Machine/ {
	if ($2 ~ "[0-9]{6}") {
		print "VM;" NAME ";" OS ";" OSCONT ";" CPU ";" RAM ";" STATE ";" ID
		NAME=""; CPU=0; RAM=""; STATE=""; OSCONT=""; I=0; delete(aNET);
        split($2, aTMP, " ");
		NAME = aTMP[1];
        ID=gensub("[\(\)]", "", "g", aTMP[2]);
	}; 
	if ($0 ~ "OS:") {OS = $3}; 
	if ($2 ~ "OS Container") {OSCONT = $3}; 
	if ($2 ~ "CPU") {CPU = $3}; 
	if ($2 ~ "Mem") {RAM = $3}; 
	if ($2 ~ "State") {STATE = $3}
	if ($1 ~ "Networks") {
        while ($0 !~ "Disks") {
            if ($0 ~ "Network Name:") {print "Network;" NAME ";" $2};  
            getline;
        }
    }
    if ($1 ~ "Disks") {
        while (length($0)) {
            if ($0 ~ "Hard disk") {
                split($0, aTMP, " ");
                print "Disk;" NAME ";" aTMP[2] " " aTMP[3] ";" aTMP[5] ";" gensub("[\\[\\]]","","g",aTMP[6]);
            }
            getline;
        }
    }
}; 
'
