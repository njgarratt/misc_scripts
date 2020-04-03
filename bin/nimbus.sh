#!/bin/bash
# nimbus.txt is simply core-cli output of cat /opt/nimbus/probes/system/cdm/cdm.cfg on all servers
# ---------------------
#echo "<<<<<"
#cat /opt/nimbus/probes/system/cdm/cdm.cfg
#echo ">>>>>"
# ---------------------

rm -f [0-9]*

# split this file up by device
cat nimbus.txt | awk '/^### / {DEV=gensub("[0-9]+::","","g",$2)}; /<<</ {print "<nimbus>" >> DEV; next}; />>>/ {print "</nimbus>" >> DEV; next}; /^[^#]/ {print $0 >> DEV}'

# the nimbus config is not quite XML; we fix it here
ls -1 [0-9]* | while read F; do cat ${F} | sed '/<\/\?[^>]\+ [^>]\+/s/\(<\/\?[^>]\+\) \([^>]\+\)/\1_\2/g; /<.*#.*>/s/<\(\/\?\)\(.*\)>/<\1filesystem value = "\2">/; /<.*#.*>/s/<\/\(.*\)>/<\/filesystem>/; /^[ 	]*[A-Z_a-z]\+[ 	]*=/s/\([A-Z_a-z]\+\)[ 	]* = [ 	]*\(.*\)$/<\1 value="\2" \/>/' > ${F}.SED; mv ${F}.SED ${F};done
