#! /bin/bash

# Automatically create Game World object-groups and ACEs
# CSV input comes from envmgr.sh, we only want the Public lines, e.g.
# 417133-db01,GW01,ger,Public,89.234.31.168,172.30.0.166

CSV=$1

if [ ! -d ${PWD}/working ]
then
	mkdir ${PWD}/working
fi

export WORK=${PWD}/working
export CWD=${PWD}

cat $CSV | awk -F',' '
/game[0-9]|gs[0-9]/ {
	REGION=$3; 
	PUB=$5; 
	PRIV=$6; 
	print "network-object host " PUB >> ENVIRON["WORK"] "/" REGION "_gs_pub"; 
	print "network-object host " PRIV >> ENVIRON["WORK"] "/" REGION "_gs_priv"
	}; 
/chat[0-9]/ {
	REGION=$3; 
	PUB=$5; 
	PRIV=$6; 
	print "network-object host " PUB >> ENVIRON["WORK"] "/" REGION "_chat_pub"; 
	print "network-object host " PRIV >> ENVIRON["WORK"] "/" REGION "_chat_priv"
	}; 
/bb[0-9]/ {
	REGION=$3; 
	PUB=$5; 
	PRIV=$6; 
	print "network-object host " PUB >> ENVIRON["WORK"] "/" REGION "_bb_pub"; 
	print "network-object host " PRIV >> ENVIRON["WORK"] "/" REGION "_bb_priv";
	}'

cd ${WORK} && ls -1 *_pub *_priv | 
while IFS="_" read REGION ROLE PV; 
do 
	echo $REGION >> regions.txt

	if [ "$ROLE" = "gs" ]
	then 
		if [ "$PV" = "pub" ] 
		then 
			echo object-group network GameSrv_pub_${REGION} >> ${CWD}/fw.cfg; 
			echo "description Game Server public IPs for ${REGION}" >> ${CWD}/fw.cfg
			cat ${REGION}_${ROLE}_${PV} >> ${CWD}/fw.cfg
			echo "" >> ${CWD}/fw.cfg
		fi
		if [ "$PV" = "priv" ] 
		then 
			echo object-group network GameSrv_prv_${REGION} >> ${CWD}/fw.cfg
			echo "description Game Server private IPs for ${REGION}" >> ${CWD}/fw.cfg
			cat ${REGION}_${ROLE}_${PV} >> ${CWD}/fw.cfg
			echo "" >> ${CWD}/fw.cfg
		fi; 
	fi

	if [ "$ROLE" = "chat" ]
	then
		if [ "$PV" = "pub" ] 
		then 
			echo object-group network ChatSrv_pub_${REGION} >> ${CWD}/fw.cfg; 
			echo "description Chat Server public IPs for ${REGION}" >> ${CWD}/fw.cfg
			cat ${REGION}_${ROLE}_${PV} >> ${CWD}/fw.cfg
			echo "" >> ${CWD}/fw.cfg
		fi
		if [ "$PV" = "priv" ] 
		then 
			if [ ! -w chatprivfw.cfg ]
			then
				echo object-group network ChatSrv_prv >> chatprivfw.cfg
				echo "description Chat Server private IPs for all regions" >> chatprivfw.cfg
				CHAT=1
			fi
			cat ${REGION}_${ROLE}_${PV} >> chatprivfw.cfg
		fi; 

	fi
	if [ "$ROLE" = "bb" ]
	then
		if [ "$PV" = "pub" ] 
		then 
			echo object-group network BBSrv_pub_${REGION} >> ${CWD}/fw.cfg; 
			echo "description Big Brother public IPs for ${REGION}" >> ${CWD}/fw.cfg
			cat ${REGION}_${ROLE}_${PV} >> ${CWD}/fw.cfg
			echo "" >> ${CWD}/fw.cfg
		fi
		if [ "$PV" = "priv" ] 
		then 
			if [ ! -w bbprivfw.cfg ]
			then
				echo object-group network BBSrv_prv >> bbprivfw.cfg
				echo "description Big Brother private IPs for all regions" >> bbprivfw.cfg
				BB=1
			fi
			cat ${REGION}_${ROLE}_${PV} >> bbprivfw.cfg
		fi; 

	fi
		
done

cat chatprivfw.cfg bbprivfw.cfg >> ${CWD}/fw.cfg
echo "" >> ${CWD}/fw.cfg

cat regions.txt | sort | uniq | while read REGION;
do
	echo access-list 101 extended permit tcp object-group BB_Public object-group ChatSrv_pub_${REGION} object-group Openfire >> ${CWD}/fw.cfg
	echo access-list 101 extended permit udp object-group BB_Public object-group ChatSrv_pub_${REGION} object-group Openfire >> ${CWD}/fw.cfg
	echo access-list 101 extended permit tcp object-group BB_Public object-group ChatSrv_pub_${REGION} object-group Openfire_Admin >> ${CWD}/fw.cfg
	echo access-list 101 extended permit tcp host 87.119.203.70 object-group ChatSrv_pub_${REGION} object-group Openfire_Admin >> ${CWD}/fw.cfg
	echo access-list 101 extended permit tcp any object-group GameSrv_pub_${REGION} eq www >> ${CWD}/fw.cfg
	echo access-list 101 extended permit tcp any object-group ChatSrv_pub_${REGION} object-group Openfire >> ${CWD}/fw.cfg
	echo access-list 101 extended permit udp any object-group ChatSrv_pub_${REGION} object-group Openfire >> ${CWD}/fw.cfg
	echo access-list 101 extended permit tcp any object-group BBSrv_pub_${REGION} eq www >> ${CWD}/fw.cfg
done
