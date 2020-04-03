#!/bin/bash
awk -F':' '
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

/Virtual/ {
    # we have a new VM stanza
    # [0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}
	if ($1 ~ "+") {
		print HYP ";" NAME ";" OS ";" CPU ";" RAM ";" STATE ";" collapse(aNET, ";", 3) ";" DISK; 
		NAME=""; CPU=0; RAM=""; STATE=""; DISK=""; I=0; delete(aNET);
		NAME = $2;
	}; 
	if ($1 ~ "OS") {OS = $2}; 
	if ($1 ~ "CPU") {CPU = $2}; 
	if ($1 ~ "Mem") {RAM = $2}; 
	if ($1 ~ "Disk") {DISK = DISK ";" $2}; 
	if ($1 ~ "State") {STATE = $2}
	if ($1 ~ "Network") {aNET[I++] = $2};
}; 
#/Cluster Datastore/ {
#	print gensub("\( - \)| \\(|\\)", ";", "g", $2)
#	}
/Cluster Name:/ {
	CLUSTER=$2;
	while ($0 !~ "HostSystem") {
		if ($0 ~ "CPUs") {CORES=$1};
		if ($0 ~ "Memory:") {MEM=$1};
		if ($0 ~ "Network:") {
                while ($0 !~ "Datastores:") {
                    getline;
                    aCNET[I++] = $0};
                    print "net";
        }
		if ($0 ~ "Datastores:") {
            while ($0 !~ "HostSystem") {
                getline;
                DATASORES=DATASORES "\n" gensub("\( - \)| \\(|\\)", ";", "g", $2)
                print "dstore " $0;
            }
            exit;
        };
        getline;
	}
	print CLUSTER "; ESX;" CORES ";" MEM ";" collapse(aCNET, ";", 3);
	print DATASORES;
	CLUSTER=""; CORES=0; MEM=0; delete(aCNET); DATASORES="";
}

/Host:/ {
	print HYP ";" NAME ";" OS ";" CPU ";" RAM ";" STATE ";" collapse(aNET, ";", 3) ";" DISK; 
	HYP	= $2;
	NAME	= "";
	OS	= "";
	CPU	= "";
	RAM	= "";
	STATE	= "";
	DISK	= "";
	delete aNET;
};

END {
	print HYP ";" NAME ";" OS ";" CPU ";" RAM ";" STATE ";" collapse(aNET, ";", 3) ";" DISK; 
}
' $1
