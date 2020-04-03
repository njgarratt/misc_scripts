#!/bin/bash
DIR=$1

find "${DIR}" -name "*.nar" | 
while read F; do echo $F; N=`echo ${F} | sed 's/\.nar//'`; echo ${N}; ionice -c 3 /opt/Navisphere/bin/naviseccli analyzer -archivedump -data "${F}" -object s,l,ml,rg,pl,hl,tl -out "${N}.csv" -overwrite y; done
