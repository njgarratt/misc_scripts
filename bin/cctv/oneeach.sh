#! /bin/bash
find . -maxdepth 1 -type d -name "20[12][0-9]_*" | sort | while read DIR; do NO_=`echo ${DIR} | sed 's/\.\/\|_//g'`; ls -1 ${DIR}/192.168.168.64_01_${NO_}1[234]* | head -5 2> /dev/null | while read FILE; do if [ -f $FILE ]; then cp ${FILE} ./oneeach/; fi; done; done
