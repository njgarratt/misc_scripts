#!/bin/bash
cat $1 | 
awk '/[[:blank:]]*virtual/ {
	DST=""; POOL=""; RULE=""; 
	VS=$2;
	while ($0 !~ "^}") {
		getline;
		if ($1 ~ "pool") {POOL=$2};
		if($1 ~ "destination") {DST=$2};
		if ($1 ~ "rules") {RULES=$2};
		if ($1 ~ "httpclass") {CLASS=$2};
		if ($0 ~ "ip protocol") {PROTO=$3};
		#print $0;
	}

	print "VIP," VS "," DST "," PROTO "," POOL "," RULES "," CLASS; 
}
/^pool/ {
	#print "in POOL";
	POOL=$2; LB="round-robin"; 
	while ($0 !~ "^}") {
		getline; 
		if ($0 ~ "method") {LB = gensub("^[[:blank:]]+lb method ", "", "g", $0);};
		if ($0 ~ "monitor") {HEALTH = gensub("^[[:blank:]]+monitor ", "", "g", $0);};
		if ($0 ~ "members" && $3 != "{}") {
			INDENT=0;
			M="true"; 
			while (M == "true")  {
				if ($0 ~ "{") {INDENT++};
				if ($0 ~ "}") {INDENT--};
				#if ($1 ~ "^}" {break};
				#print "INDENT is " INDENT;
				getline; 
				#print $0;
				if ($0 ~ "[0-9]+\.[0-9]+\.") {
					MEM=MEM $1","; 
				}
				if (INDENT==0) {
					M="false"; 
					#print "INDENT is 0";
				}
            }
        } else if ($0 ~ "members" && $3 == "{}") {
                MEM=MEM $2",";
        }
	}
	print "pool,"POOL "," LB "," HEALTH "," MEM; POOL=""; MEM=""; HEALTH=""; 
}'
