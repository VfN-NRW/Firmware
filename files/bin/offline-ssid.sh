#!/bin/sh
# fnetstat by RubenKelevra 2013 - cyrond@gmail.com
# Lizenz: AGPL 3.0 

#Warning: This script will immediately set the ssid configured in uci if its changed.

#This script expect that an temporary SSID is set on boot. The Script will read ssid_online and set it when node is online.

#Options
SLEEP=4 # wait time in seconds before rechecking
ACTIVE_CHECK=1 # do pinging selected gateway via L2-ping, if last-seen is to high
SSID_PHY0="wireless.wifi_freifunk.ssid_online"
SSID_PHY0_BOOT="wireless.wifi_freifunk.ssid"
HOSTAPD_PHY0="/var/run/hostapd-phy0.conf"
SSID_PHY1="wireless.wifi_freifunk5.ssid_online" #if phy1.conf is not found, this will be not used
SSID_PHY1_BOOT="wireless.wifi_freifunk5.ssid"
HOSTAPD_PHY1="/var/run/hostapd-phy1.conf" 
PING_CNT=3 #Ping-Packets for ACTIVE_CHECK: 3 is recommented, 5-10 for lossy connections
OGM_INT_MULT=2 #Tolerable missing OGMs, before pinging (if ACTIVE_CHECK=1): 1 for fast responsive, 2 for slower reactions, 3-4 for lossy connections
LED_STATUS=1

#vars
RUNTIME=60 #default runtime in seconds
MODE=1
END=0
GWQ=0
GWM=""
GWLS=0
GWL=0
OFFLINE=0
ISOFFLINE=0
RADIOONE=0
SSID_0=""
SSID_1=""
SSID_0_BOOT=""
SSID_0_ONLINE=""
SSID_0_OFFLINE=""
SSID_1_BOOT=""
SSID_1_ONLINE=""
SSID_1_OFFLINE=""
DEVICE=`cat /proc/sys/kernel/hostname`
CHANGED=0
FORCE_CHANGE=0

#checking batctl
if [ $ACTIVE_CHECK -eq 1 ]; then
	batctl -v >/dev/null 2>&1 || { echo >&2 "batctl is required for Active-Checking, but it's not installed.  Aborting."; exit 1; }
fi

#Parameter Checking
if ! [ $# -eq 1 -o "$1" -eq "$1" ] 2>/dev/null; then
	echo "Error: Please define a runtime in seconds" && exit 2 
else
	RUNTIME=$1
	echo "Debug: Runtime will be $RUNTIME seconds, please restart me after this time"
fi

#Checking Files and Options
if [ ! -f $HOSTAPD_PHY0 ]; then 
	echo "Error: PHY0 Hostapd-File not found" && exit 2

elif [ "$(uci get $SSID_PHY0_BOOT 2>/dev/null)" == "" ]; then
	echo "Error: UCI can't find Boot-SSID for Radio0 Append them with:
uci set $SSID_PHY0_BOOT=x
uci commit" && exit 2

elif [ "$(uci get $SSID_PHY0 2>/dev/null)" == "" ]; then
	echo "Error: UCI can't find SSID for Radio0. Append them with:
uci set $SSID_PHY0=x
uci commit" && exit 2

elif [ -f $HOSTAPD_PHY1 -a "$(uci get $SSID_PHY1_BOOT 2>/dev/null)" == "" ]; then
	echo "Error: UCI can't find Boot-SSID for Radio1 Append them with:
uci set $SSID_PHY1_BOOT=x
uci commit" && exit 2

elif [ -f $HOSTAPD_PHY1 -a "$(uci get $SSID_PHY1 2>/dev/null)" == "" ]; then
	echo "Error: UCI can't find SSID for Radio1. Append them with:
uci set $SSID_PHY1=x
uci commit" && exit 2

elif ! [ -f /etc/diag.sh ]; then
	if [ $LED_STATUS -eq 1 ]; then
		echo "Error: /etc/diag.sh not found." && exit 2
	fi
fi

if [ $LED_STATUS -eq 1 ]; then
	. /etc/diag.sh
	get_status_led
fi

START=`cat /proc/uptime | cut -d"." -f1`
END=$(( $START + $RUNTIME ))
END=$(( $END - 1 ))

while [ `cat /proc/uptime | cut -d"." -f1` -lt $END ]
do
	case $MODE in
	1) #check: batman knows an gateway
		GWQ=`cat /sys/kernel/debug/batman_adv/bat0/gateways | egrep ' \([\ 0-9]+\) ' | cut -d\( -f2 | cut -d\) -f1 | sort -n | tail -n1`
		if ! [ "$GWQ" -eq "$GWQ" ] 2>/dev/null; then
			GWQ=0
		fi
		echo -n "Debug: Gateway-Quality is $GWQ"
		if [ $GWQ -lt 10 ]; then
			echo " - this is not okay, we're offline"
			OFFLINE=1
			MODE=4
		else
			echo " - this seem fine"
			OFFLINE=0
			MODE=2
			continue
		fi
		;;
	2) #check: Gateways Last-Seen
		GWM=`cat /sys/kernel/debug/batman_adv/bat0/gateways | grep "^=>" | cut -d" " -f2`
		if [ "$GWM" == "" ]; then
			GWM="00:00:00:00:00"
		fi
		GWLS=`cat /sys/kernel/debug/batman_adv/bat0/originators | grep "^$GWM" | cut -d" " -f3-5 | cut -d"s" -f1 | cut -d"." -f1`
		if ! [ "$GWLS" -eq "$GWLS" ] 2>/dev/null; then
			GWLS=65535
		fi
		if [ $GWLS -eq 65535 ] ; then #if no gateway found, skipping active ACTIVE_CHECK
			MODE=4
			OFFLINE=1
			echo "Debug: No Gateway in Originators found - we're offline."
		else
			echo -n "Debug: Gateways Last-Seen is $GWLS seconds"
			if [ $GWLS -gt $(( `cat /sys/devices/virtual/net/bat0/mesh/orig_interval` / 1000 * $OGM_INT_MULT)) ]; then
				echo " - this is not okay, we seem to be offline"
				OFFLINE=1
				MODE=3
				continue
			else
				echo " - this is fine, we're online"
				OFFLINE=0
				MODE=4
			fi
		fi
		;;
	3) #check: gateway is reachable 
		if [ $ACTIVE_CHECK -eq 1 ]; then
			echo -n "Debug: Active-Checking enabled, pinging Gateway..."
			GWL=`batctl ping -c$PING_CNT $GWM | grep "packet loss" | cut -d" " -f6 | cut -d"%" -f1`
			if [ "$GWL" == "" ]; then
				GWL=404
			fi
			if ! [ "$GWL" -eq "$GWL" ] 2>/dev/null; then
				GWL=404
			fi
			if [ $GWL -eq 404 ]; then
				echo " ERROR: Pinging-Command failed"
				OFFLINE=1
			else
				echo " done."
				echo -n "Debug: Packetloss ($GWL %) " 
				if [ $GWL -lt 100 ]; then
					OFFLINE=0
					echo "fine."
				else
					OFFLINE=1
					echo "to high."
				fi
			fi
			MODE=4
		else
			echo "Debug: Active-Checking disabled. Skipping"
			MODE=4
		fi
		;;
	4) #sleep
		echo "Debug: Sleeping now for $SLEEP seconds"
		sleep $SLEEP
		echo ""
		MODE=1
		continue
		;;
	*)
		echo "Error: fatal error." && exit 2
		;;
	esac
	
	#get hostap-status
	FORCE_CHANGE=0
	ISOFFLINE=0
	SSID_0_BOOT=""
	SSID_0_ONLINE=""
	SSID_0_OFFLINE=""
	RADIOONE=0 
	SSID_1_BOOT=""		      
	SSID_1_ONLINE=""
	SSID_1_OFFLINE=""
	CHANGED=0

	
	if ! [ -f $HOSTAPD_PHY0 ]; then
		echo "ERROR: Hostapd-phy0.conf missing. Skipping any SSID change."
		continue
	fi	

	### RADIO 0 ###

	SSID_0_BOOT="$(uci get $SSID_PHY0_BOOT)"
	SSID_0_ONLINE="$(uci get $SSID_PHY0)"
	#Generate Offline-SSID
	if [ ${#SSID_0_ONLINE} -gt $(( 23 - ${#DEVICE} )) ]; then  #cut ssid to the maximum
		SSID_0_OFFLINE="${SSID_0_ONLINE:0:$(( 20 - ${#DEVICE} ))}..."
	else
		SSID_0_OFFLINE=$SSID_0_ONLINE
	fi
	SSID_0_OFFLINE="Offline-$SSID_0_OFFLINE-$DEVICE"

	SSID_0=`cat $HOSTAPD_PHY0 | grep "^ssid="`
	SSID_0=${SSID_0:5} #rm ssid=
	
#	echo "Debug: RADIO0:"
#	echo "      SSID for boot   : '$SSID_0_BOOT'"
#	echo "      SSID for online : '$SSID_0_ONLINE'"
#	echo "      SSID for offline: '$SSID_0_OFFLINE'"

	if [ "$SSID_0_BOOT" == "" -o "$SSID_0_ONLINE" == "" -o "$SSID_0_OFFLINE" == "" ]; then
		echo "ERROR: fetching / generating of SSIDs was wrong"
		continue
	fi
	
	echo -n "Debug: Hostap gave us SSID_0='$SSID_0', "

	if [ "$SSID_0" == "$SSID_0_ONLINE" ]; then
		ISOFFLINE=0
		echo "our online-SSID"
	elif [ "$SSID_0" == "$SSID_0_OFFLINE" ]; then		
		ISOFFLINE=1
		echo "our offline-SSID"
	elif [ "$SSID_0" == "$SSID_0_BOOT" ]; then
		FORCE_CHANGE=1
		echo "our boot-SSID"
	else
		FORCE_CHANGE=1
		echo "WARNING this seems wrong, we're changing it now."
	fi

	### RADIO 1 ###
	
	if [ -f $HOSTAPD_PHY1 ]; then
		RADIOONE=1

		SSID_1_BOOT="$(uci get $SSID_PHY1_BOOT)"
		SSID_1_ONLINE="$(uci get $SSID_PHY1)"
		#Generate Offline-SSID
		if [ ${#SSID_1_ONLINE} -gt $(( 23 - ${#DEVICE} )) ]; then  #cut ssid to the maximum
			SSID_1_OFFLINE="${SSID_1_ONLINE:0:$(( 20 - ${#DEVICE} ))}..."
		else
			SSID_1_OFFLINE=$SSID_1_ONLINE
		fi
		SSID_1_OFFLINE="Offline-$SSID_1_OFFLINE-$DEVICE"

		SSID_1=`cat $HOSTAPD_PHY1 | grep "^ssid="`
		SSID_1=${SSID_1:5} #rm ssid=
	
#		echo "Debug: RADIO1:"
#		echo "      SSID for boot   : '$SSID_1_BOOT'"
#		echo "      SSID for online : '$SSID_1_ONLINE'"
#		echo "      SSID for offline: '$SSID_1_OFFLINE'"

		if [ "$SSID_1_BOOT" == "" -o "$SSID_1_ONLINE" == "" -o "$SSID_1_OFFLINE" == "" ]; then
			echo "ERROR: fetching / generating of SSIDs was wrong"
			continue
		fi
	
		echo -n "Debug: Hostap gave us SSID_1='$SSID_1', "

		if [ $ISOFFLINE -eq 0 -a "$SSID_1" != "$SSID_1_ONLINE" -a $FORCE_CHANGE -eq 0 ]; then
			FORCE_CHANGE=1
			echo "WARNING SSID for Radio1 not in the same status, forcing change."
		elif [ $ISOFFLINE -eq 1 -a "$SSID_1" != "$SSID_1_OFFLINE" -a $FORCE_CHANGE -eq 0 ]; then		
			FORCE_CHANGE=1
			echo "WARNING SSID for Radio1 not in the same status, forcing change."
		elif [ $FORCE_CHANGE -eq 0 -a "$SSID_1" == "$SSID_1_BOOT" ]; then
			FORCE_CHANGE=1
			echo "WARNING SSID for Radio1 still in booting status, forcing change."
		else
			echo "ok."
		fi
	fi
	
	### Checking if update is needed ###
	
	echo "Debug: OFFLINE=$OFFLINE ISOFFLINE=$ISOFFLINE FORCE_CHANGE=$FORCE_CHANGE"
	
	if ! [ $FORCE_CHANGE -eq 1 ]; then
		
		if [ $OFFLINE -eq 1 -a $ISOFFLINE -eq 0 ]; then
			echo "Debug: our check says, we're offline, need to change SSIDs"
			CHANGED=1
		elif [ $OFFLINE -eq 0 -a $ISOFFLINE -eq 1 ]; then
			echo "Debug: our check says, we're back online, need to change SSIDs"
			CHANGED=1
		fi
	else
		echo "Debug: need to change SSIDs."
	fi
	
	### getting right SSIDs ###

	if [ $CHANGED -eq 1 -o $FORCE_CHANGE -eq 1 ]; then
		if [ $OFFLINE -eq 1 ]; then
			SSID_0=$SSID_0_OFFLINE
			if [ $LED_STATUS -eq 1 ]; then
				status_led_set_timer 60 400
			fi
		else
			SSID_0=$SSID_0_ONLINE
			if [ $LED_STATUS -eq 1 ]; then
				status_led_on
			fi
		fi

		SSID_0="ssid=$SSID_0"
		
		if [ $RADIOONE -eq 1 ]; then
			if [ $OFFLINE -eq 1 ]; then
				SSID_1=$SSID_1_OFFLINE
			else
				SSID_1=$SSID_1_ONLINE
			fi
			
			SSID_1="ssid=$SSID_1"
		fi
		
		if ! [ -f $HOSTAPD_PHY0 ]; then
			echo "ERROR: Hostapd-phy0.conf gone. Skipping the SSID change."
			continue
		fi	
		
		rm /tmp/hostapd-phy0.conf.temp 2>/dev/null
		cat /var/run/hostapd-phy0.conf | grep -v "^ssid=" > /tmp/hostapd-phy0.conf.temp
		echo "$SSID_0" >> /tmp/hostapd-phy0.conf.temp
		mv /tmp/hostapd-phy0.conf.temp /var/run/hostapd-phy0.conf
		
		if [ $RADIOONE -eq 1 ]; then
		
			if [ -f $HOSTAPD_PHY1 ]; then
				rm /tmp/hostapd-phy1.conf.temp 2>/dev/null
				cat /var/run/hostapd-phy1.conf | grep -v "^ssid=" > /tmp/hostapd-phy1.conf.temp
				echo "$SSID_1" >> /tmp/hostapd-phy1.conf.temp
				mv /tmp/hostapd-phy1.conf.temp /var/run/hostapd-phy1.conf
			else
				echo "Error: hostapd-phy1.conf is gone ... we cant process the SSID-Change for Radio1"
			fi
		fi
		
		echo -n "Debug: HUPing hostapd now..."
		killall -HUP hostapd
		echo "done."
	fi
done
