#!/bin/bash

WD=`pwd`
IPs=$1

while [ -f ${WD}/run ];
do
	echo -n "POLL:" >> ${WD}/HA.out; 
	date '+%s' >> ${WD}/HA.out;
	cat ${IPs} | 
	while read NAME IP; 
		do 
			if ! ping -q -W2 -c 1 ${IP} > /dev/null ; 
			then 
				echo -n "${NAME}:" >> ${WD}/HA.out 
				date '+%s' >> ${WD}/HA.out; 
			fi; 
		done
	sleep 5;
done
echo 'Run cancelled' >> ${WD}/HA.out
