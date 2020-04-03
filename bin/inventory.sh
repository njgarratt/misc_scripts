#!/bin/bash

cat $1 | 
gawk '
/^Device URL: / {print "INSERT INTO hinv VALUES (#" DEVICE "#,#" PLAT "#,#" OS "#,#" CPU "#,#" RAM "#);"; 
DEVICE=""; 
PLAT=""; 
CPU=""; 
RAM="";
OS="";
HDD="";
}
/^Device: / {DEVICE=$2; HOST=$3};
/^Platform: / {PLAT=gensub("Platform:[ 	]+", "", "g", $0)};
/[Pp]rocess.*: / {CPU=gensub("^.*[Pp]rocessor.*: ", "", "g", $0)};
/[0-9]{1,7} [Mm]emory.*: / {RAM=$4};
/Operating System/ {OS=gensub("^.*Operating System.*: ", "", "g", $0)};
/OS Version/ {OS=gensub("^.*OS Version.*: ", "", "g", $0)};
/Hard Drive.*[0-9]/ {HDD=gensub("^.*Hard Drive.*: ", "", "g", $0); print "INSERT INTO disk VALUES (##,#" DEVICE "#,#" HDD "#);"};
'
