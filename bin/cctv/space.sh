#! /bin/bash 

FREE_GB=30

FREESPACE=$(echo "${FREE_GB} * 1024 ^ 2" | bc -l)
AVAIL=$(df -k . | tail -1 | awk '{printf("%d", $4)}')
export DELTAX=$( echo $FREESPACE - $AVAIL | bc -l)
DELTA=$( echo $FREESPACE - $AVAIL | bc -l)
DELTA_GB=`echo "${DELTA} / 1024 ^2" | bc -l`

if [ $AVAIL -le $FREESPACE ]
then
	echo "Attempting to free ~$( printf  '%.2f' ${DELTA_GB})G of space"
	for D in $(find . -maxdepth 1 -type d -name "20[10]*[0-9]" | sort | head -20)
	do 
		T=${T:-0}
		T=$(echo $T + $(du -sk $D| awk '{printf("%d", $1)}') | bc -l )
		echo "T=${T} and DELTA=${DELTAX}"
		if [ $( echo "$T >= ${DELTA}" | bc -l ) -eq 1 ]
		then 
			echo "enough!"
			break
		fi
		# be very careful
		if [ ! $( echo $D | grep -qE './20[12][0-9]_[0-9]{2}_[0-9]{2}') ]
		then
			echo rm -rf ${D}/
			rm -rf ${D}/
		fi
	done
fi
