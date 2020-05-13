#/bin/bash
 ls -1 | sed -n '/192\.168\.1/s/^.*_\([0-9]\{4\}\)\([0-9]\{2\}\)\([0-9]\{2\}\).*$/\1_\2_\3/p' | sort | uniq | 
while read DIR; 
	do 
	if [ ! -d ${DIR} ]
		then mkdir -p ${DIR} 
	fi
done
ls -1 | sed -n '/192\.168\.1/s/^.*_\([0-9]\{4\}\)\([0-9]\{2\}\)\([0-9]\{2\}\).*$/\0 \1_\2_\3/p' | 
while read FILE DIR 
do
	if [ -s ${FILE} ]
	then
		mv ${FILE} ${DIR}/
	else
		mv ${FILE} Junk/
	fi
done
#  ffmpeg -r 25 -qscale 2  -i temp/%05d.jpg output.mp4
#  ffmpeg -r 25   -i temp/%05d.jpg -qscale 2 output.mp4
