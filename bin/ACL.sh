#! /bin/bash
cat $1 | sed -n 's/^.*: access-list \(.*\)$/\1/p' | 
awk '{
	ACLNO 	= $1;
	ACTION	= $2;
	PROTO	= $3
	split($4, aTMP, "[/()]");
	SRC_INT	= aTMP[1];
	SRC_IP	= aTMP[2];
	if (aTMP[3] > 1023) 
	{SRC_PORT = "HIGHPORT"} 
	else
	{SRC_PORT	= aTMP[3]};
	split($6, aTMP, "[/()]");
	DST_INT	= aTMP[1];
	DST_IP	= aTMP[2]
	DST_PORT= aTMP[3];

	SEP = " ";
	print ACLNO SEP ACTION SEP PROTO SEP SRC_INT SEP SRC_IP SEP SRC_PORT SEP DST_INT SEP DST_IP SEP DST_PORT; 
	}'	| sort | uniq -c | sed 's/\//        /g; s/^[        ]\+//g; s/ \+/  /g; s/(/        /g; s/)//g'

