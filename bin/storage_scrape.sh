#!/bin/bash
cat storage_devices.txt | while read DEVNO; do curl -o ${DEVNO}_stortab.txt -b "rackspace_admin_session=167baa6b47132e6360b9a72887e2ad9d"  "https://core.rackspace.com/py/core/server/server_managed_storage.pt?computer_number=${DEVNO}"; done
ls -1 *_stortab.txt | while read FILE; do export DEVNO=`echo $FILE | cut -d '_' -f 1`; cat ${FILE} | awk 'BEGIN {LINE=ENVIRON["DEVNO"]}; /<td>/ {LINE=LINE ";" gensub(" \*</\?td>", "", "g", $0)}; /<\/tr>/ {if (LINE!=ENVIRON["DEVNO"]) {print LINE; LINE=ENVIRON["DEVNO"]}};';done > storage_summary.csv 
