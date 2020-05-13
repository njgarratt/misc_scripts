#!/bin/bash -x

#export MAGICK_TMPDIR=/data/Camera/Stills/tmp
export MAGICK_TMPDIR=/hgst/tmp/

function to_movie() {
	local THISDIR=$1
	if [ -d ${THISDIR} ]
	then
		# ls -1 2019_10_31 | wc -l | while read A; do I=$(($A/4500|1)); echo $I; for (( i=$I;i < 0;i-- )); do echo $i; done; done 
		#local I=$((`ls -1 | wc -l`/4500|1))
		echo ">>>>>>> ${THISDIR} <<<<<<<<"
		pushd ${THISDIR}

		# split file list into manageable chunks
		ls -1 | split -l 4500 - files

		# iterator
		local I=0

		for FILE in `ls files*`
		do 
			echo "processing ${FILE}"
			convert -define registry:temporary-path=${MAGICK_TMPDIR} @${FILE} -resize 30% +adjoin ../temp/%05d.jpg &&
			ffmpeg -y -f image2 -framerate 25 -pattern_type sequence -i ../temp/%05d.jpg -pix_fmt yuv420p  -r 25 ../${THISDIR}_$((I++)).mp4
			#ffmpeg -y -f image2 -r 25  -i ../temp/%05d.jpg ../${THISDIR}.mp4
			echo "exit code1: $?"
			rm -f ../temp/*.jpg
			rm -f ${MAGICK_TMPDIR}/magick-*
			echo "exit code2: $?"
		done

		# back to where we started
		popd
	else
		echo "${THISDIR} does not exist!"
	fi

}

#cat ./dirs.txt |
#find . -maxdepth 1 -type d -name "201*" |

if [ $# -ge 1 ]
then
	for DIR in "$@"
	do
		echo "<<<<<< ${DIR} >>>>>>"
		to_movie $DIR
	done
else
	cd /data/Camera/Stills &&
	for DIR in `find . -maxdepth 1 -mtime +1 -type d -name "202*" | sort`
	do
		if [ ! -f ${DIR}.mp4 -a ! -f ${DIR}_0.mp4 ]
		then 
			to_movie $DIR
		fi
	done
fi
