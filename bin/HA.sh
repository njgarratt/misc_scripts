#!/bin/bash

cat $1 | 
awk --posix -F':' '
/^[0-9]{6}/ {
	HOST=$1; 
	TSTAMP=$2; 
	aETIME[HOST,"pollcnt"] = 0;
	if (aSTIME[HOST] == "") 
	{
		aSTIME[HOST] = TSTAMP
	} else 
	{
		aETIME[HOST] = TSTAMP
	}
};
/^POLL/ {
	for (IDX in aSTIME)
	{
		aETIME[IDX,"pollcnt"] += 1;
		if (aETIME[IDX,"pollcnt"] == 2)
		{
			# we have a successful poll for this one
			if (aETIME[IDX] != "")
				ETIME = aETIME[IDX];
			else
				ETIME = $2;
			FD="date -d @" aSTIME[IDX] " \"+%Y-%m-%d %H:%M:%S\"" | getline SSTRING;
			close("date -d @" aSTIME[IDX] " \"+%Y-%m-%d %H:%M:%S\"");
			FD="date -d @" ETIME  " \"+%Y-%m-%d %H:%M:%S\"" | getline ESTRING;
			close("date -d @" ETIME " \"+%Y-%m-%d %H:%M:%S\"");
			#print IDX "," aSTIME[IDX] "," ETIME "," ETIME - aSTIME[IDX];
			print IDX "," SSTRING "," ESTRING "," ETIME - aSTIME[IDX];
			delete aSTIME[IDX];
			delete aETIME[IDX];
			aETIME[IDX,"pollcnt"] = 0;
		}
	}
}
'

