#!/bin/sh
# fnetstat by RubenKelevra 2013 - cyrond@gmail.com
# Lizenz: AGPL 3.0 

#Warning: This script will immediately set the ssid configured in uci if its changed.

#Options
SLEEP=4
ACTIVE_CHECK=1
SSID_PHY0="wireless.wifi_freifunk.ssid"
HOSTAPD_PHY0="/var/run/hostapd-phy0.conf"
SSID_PHY1="wireless.wifi_freifunk5.ssid" #if phy1.conf is not found, this will be not used
HOSTAPD_PHY1="/var/run/hostapd-phy1.conf" 

#vars
RUNTIME=60 #default runtime in seconds
MODE=1
END=0
GWQ=0
OFFLINE=0
ISOFFLINE=0
SSID_0=""
SSID_1=""
DEVICE=`cat /proc/sys/kernel/hostname`
CHANGED=0

#Parameter Checking
if ! [ $# -eq 1 -o "$1" -eq "$1" ] 2>/dev/null; then
	echo "Error: Please define a runtime in seconds" && exit 2 
else
	RUNTIME=$1
	echo "Debug: Runtime will be $RUNTIME seconds, please restart me after this time"
fi

if [ ! -f $HOSTAPD_PHY0 ]; then 
	echo "Error: PHY0 Hostapd-File not found" && exit 2
else
	echo "Debug: Found hostapd-phy0.conf"
fi

START=`cat /proc/uptime | cut -d"." -f1`
END=$(( $START + $RUNTIME ))
END=$(( $END - 1 ))

while [ `cat /proc/uptime | cut -d"." -f1` -lt $END ]
do
	case $MODE in
	1) #check: batman knows an gateway
		GWQ=$(cat /sys/kernel/debug/batman_adv/bat0/gateways | egrep ' \([\ 0-9]+\) ' | cut -d\( -f2 | cut -d\) -f1 | sort -n | tail -n1)
		if ! [ "$GWQ" -eq "$GWQ" ] 2>/dev/null; then
                        GWQ=0
                fi
		echo -n "Debug: Gateway-Quality is $GWQ"
		if [ $GWQ -lt 10 ]; then
			echo " - this is not okay, we're offline"
			OFFLINE=1
			MODE=3
		else
			echo " - this is fine, we're online"
			OFFLINE=0
			MODE=2
			continue
		fi
		;;
	2) #check: gateway is reachable 
		if [ $ACTIVE_CHECK -eq 1 ]; then
			#check via ping
			MODE=3
		else
			MODE=3
		fi
		;;
	3) #sleep
		echo "Debug: Sleeping now for $SLEEP seconds"
		sleep $SLEEP
		MODE=1
		continue
		;;
	*)
		echo "Error: fatal error." && exit 2
		;;
	esac
	
	#get hostap-status
	SSID_0=`cat $HOSTAPD_PHY0 | grep "^ssid="`
	SSID_0=${SSID_0:5} #rm ssid=
	
	if [ "$SSID_0" == `uci get $SSID_PHY0` ]; then
		ISOFFLINE=0
	else
		ISOFFLINE=1
		SSID_0=`uci get $SSID_PHY0`
	fi
	
	if [ -f $HOSTAPD_PHY1 ]; then
		SSID_1=`uci get $SSID_PHY1`
	fi
	
	CHANGED=0
	if [ $OFFLINE -eq 1 -a $ISOFFLINE -eq 0 ]; then
		echo "Debug: Our check says, were offline, now changing SSIDs"
		CHANGED=1
		SSID_0="ssid=Offline-$SSID_0-$DEVICE"
		if [ -f $HOSTAPD_PHY1 ]; then
			SSID_1="ssid=Offline-$SSID_1-$DEVICE"
		fi
	elif [ $OFFLINE -eq 0 -a $ISOFFLINE -eq 1 ]; then
		echo "Debug: Our check says, were back online, now changing SSIDs"
		CHANGED=1
		SSID_0="ssid=$SSID_0"
		if [ -f $HOSTAPD_PHY1 ]; then
			SSID_1="ssid=$SSID_1"
		fi
	fi
	if [ $CHANGED -eq 1 ]; then
		rm /tmp/hostapd-phy0.conf.temp 2>/dev/null
		cat /var/run/hostapd-phy0.conf | grep -v "^ssid=" > /tmp/hostapd-phy0.conf.temp
		echo "$SSID_0" >> /tmp/hostapd-phy0.conf.temp
		mv /tmp/hostapd-phy0.conf.temp /var/run/hostapd-phy0.conf
		if [ -f $HOSTAPD_PHY1 ]; then
			rm /tmp/hostapd-phy1.conf.temp 2>/dev/null
			cat /var/run/hostapd-phy1.conf | grep -v "^ssid=" > /tmp/hostapd-phy1.conf.temp
			echo "$SSID_1" >> /tmp/hostapd-phy1.conf.temp
			mv /tmp/hostapd-phy1.conf.temp /var/run/hostapd-phy1.conf
		fi
		
		killall -HUP hostapd
	fi
done
