#!/bin/bash

cat $1 | 
awk --posix -F':' '
/^[0-9]{6}/ {
	HOST=$1; 
	TSTAMP=$3; 
	aETIME[HOST,"pollcnt"] = 0;
	if (aSTIME[HOST]["TS"] == "") 
	{
		aSTIME[HOST]["TS"] = TSTAMP
		aSTIME[HOST]["SP"] = $2
	} else 
	{
		aETIME[HOST] = TSTAMP
	}
    #print "????" HOST " " aSTIME[HOST]["TS"] "###" aETIME[HOST] "???";
};
/^POLL/ {
	for (IDX in aSTIME)
	{
        #print "###########" IDX;
		aETIME[IDX,"pollcnt"] += 1;
		if (aETIME[IDX,"pollcnt"] == 2)
		{
			# we have a successful poll for this one
			if (aETIME[IDX] != "")
				ETIME = aETIME[IDX];
			else
				ETIME = $2;
            #print ">>>>" IDX " " aSTIME[IDX]["TS"] "###" ETIME "<<<<";
			"date -d @" aSTIME[IDX]["TS"] " \"+%Y-%m-%d %H:%M:%S\"" | getline SSTRING;
			close("date -d @" aSTIME[IDX]["TS"] " \"+%Y-%m-%d %H:%M:%S\"");
			"date -d @" ETIME  " \"+%Y-%m-%d %H:%M:%S\"" | getline ESTRING;
			close("date -d @" ETIME " \"+%Y-%m-%d %H:%M:%S\"");
			#print IDX "," aSTIME[IDX]["TS"] "," ETIME "," ETIME - aSTIME[IDX]["TS"];
			print IDX "," SSTRING "," ESTRING "," ETIME - aSTIME[IDX]["TS"] "," aSTIME[IDX]["SP"];
			delete aSTIME[IDX];
			delete aETIME[IDX];
			aETIME[IDX,"pollcnt"] = 0;
		}
	}
}
'

