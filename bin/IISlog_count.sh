cat  *.log | awk '{DATE=$1; LOG=$3; URI=$6; SRC=$10; RESP=$12; BYTES=$15; aLOG[LOG][URI][DATE]["count"]++; aLOG[LOG][URI][DATE]["bytes"]+=BYTES}; END {for (LOG in aLOG) {for (URI in aLOG[LOG]){for (DATE in aLOG[LOG][URI]) {print LOG "," URI "," DATE "," aLOG[LOG][URI][DATE]["count"] "," aLOG[LOG][URI][DATE]["bytes"]}}}}'