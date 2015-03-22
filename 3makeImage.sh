#!/bin/bash

mt_kf='files/_all/etc/dropbear/authorized_keys.FFNRW_maintain'
mt_comm_switch='files/_all/etc/NO_COMMUNITY_MAINTAIN_KEYS'

if [ "$1" = "with_FFNRW_maintainkeys" ]; then
  cp authorized_keys.default "$mt_kf"
  echo "Building image with FFNRW-Maintainkeys"
  if [ -f "$mt_comm_switch" ]; then
    rm "$mt_comm_switch"
  fi
else
  if [ -f "$mt_kf" ]; then
    rm "$mt_kf"
  fi
  echo "If this file exists no community-manager SSH keys will be installed" > "$mt_comm_switch"
  echo "Building image without FFNRW-Maintainkeys"
fi

#make debian-stuff portable
rename_bin=""
$(rename.ul -V)
if [ $? == 0 ] ; then
  rename_bin="rename.ul"
else
  rename_bin="rename"
fi

function makeimage {
	packages="$1"
  files="$2"
  target=$3
  profile=$4
  factory=$5
  sysupgrade=$6
  (
    _target=$(echo ${target} | tr '-' '_')
    cd OpenWrt-ImageBuilder-${_target}-for-unknown-x86_64/
    make clean
    rm -rf myfiles/

    mkdir myfiles
    cp ../files/_all/* myfiles/ -r -v
    cp ../files/$files/* myfiles/ -r -v
    tmp_str=${sysupgrade}
    sed -i -e "s/#xxxFILENAMExxx/option filename 'ff-nrw-$tmp_str'/" myfiles/etc/config/freifunk
    make image FILES="./myfiles/" PROFILE="${profile}" PACKAGES="$packages"
    cp bin/*/openwrt-${sysupgrade} ../images
    cp bin/*/openwrt-${factory} ../images
  ) 2>&1 | tee logs/makeimage-${profile}
}

rm images/*

BUILD=$(cat build.txt) 
BUILD=$(($BUILD+1))
echo $BUILD > build.txt


CFGMICRO="-6relayd -kmod-wpad -odhcp6c -odhcpd -wpad-mini -ppp-mod-pppoe -firewall -dnsmasq -ppp -iptables -kmod-ipt-nat -kmod-ipt-nathelper -ip6tables -swconfig -opkg kmod-ipv6 kmod-batman-adv hostapd ecdsautils ip"
CFGMINI="-6relayd -kmod-wpad -odhcp6c -odhcpd -wpad-mini kmod-batman-adv ip curl ecdsautils batctl"
CFGBASE="$CFGMINI ebtables ppp-mod-pppoe haveged tc kmod-sched-core kmod-sched"
CFGHOTSPOT="hostapd kmod-ath"
CFGVPN="fastd"
CFGx86="kmod-ide-core kmod-ide-generic"

echo $BUILD > files/_all/build

makeimage "$CFGBASE $CFGVPN $CFGHOTSPOT" "default" ar71xx-generic 'UBNT' ar71xx-generic-ubnt-nano-m-squashfs-factory.bin ar71xx-generic-ubnt-nano-m-squashfs-sysupgrade.bin
makeimage "$CFGBASE $CFGVPN $CFGHOTSPOT" "default" ar71xx-generic 'UBNTUNIFI' ar71xx-generic-ubnt-unifi-squashfs-factory.bin ar71xx-generic-ubnt-unifi-squashfs-sysupgrade.bin
makeimage "$CFGBASE $CFGVPN $CFGHOTSPOT" "default" ar71xx-generic 'UBNTUNIFIOUTDOOR' ar71xx-generic-ubnt-unifi-outdoor-squashfs-factory.bin ar71xx-generic-ubnt-unifi-outdoor-squashfs-sysupgrade.bin
makeimage "$CFGBASE $CFGVPN $CFGHOTSPOT" "default" ar71xx-generic 'UAPPRO' ar71xx-generic-ubnt-uap-pro-squashfs-factory.bin ar71xx-generic-ubnt-uap-pro-squashfs-sysupgrade.bin

makeimage "$CFGBASE $CFGVPN $CFGHOTSPOT" "default" ar71xx-generic 'TLWR740' ar71xx-generic-tl-wr740n-v4-squashfs-factory.bin ar71xx-generic-tl-wr740n-v4-squashfs-sysupgrade.bin
makeimage "$CFGBASE $CFGVPN $CFGHOTSPOT" "default" ar71xx-generic 'TLWR741' ar71xx-generic-tl-wr741nd-v2-squashfs-factory.bin ar71xx-generic-tl-wr741nd-v2-squashfs-sysupgrade.bin
makeimage "$CFGBASE $CFGVPN $CFGHOTSPOT" "default" ar71xx-generic 'TLWR741' ar71xx-generic-tl-wr741nd-v4-squashfs-factory.bin ar71xx-generic-tl-wr741nd-v4-squashfs-sysupgrade.bin

makeimage "$CFGBASE $CFGVPN $CFGHOTSPOT" "default" ar71xx-generic 'TLWR801' openwrt-ar71xx-generic-tl-wa801nd-v1-squashfs-factory.bin openwrt-ar71xx-generic-tl-wa801nd-v1-squashfs-sysupgrade.bin
makeimage "$CFGBASE $CFGVPN $CFGHOTSPOT" "default" ar71xx-generic 'TLWR801' openwrt-ar71xx-generic-tl-wa801nd-v2-squashfs-factory.bin openwrt-ar71xx-generic-tl-wa801nd-v2-squashfs-sysupgrade.bin

makeimage "$CFGBASE $CFGVPN $CFGHOTSPOT" "default" ar71xx-generic 'TLWR841' ar71xx-generic-tl-wr841nd-v5-squashfs-factory.bin ar71xx-generic-tl-wr841nd-v5-squashfs-sysupgrade.bin
makeimage "$CFGBASE $CFGVPN $CFGHOTSPOT" "default" ar71xx-generic 'TLWR841' ar71xx-generic-tl-wr841n-v8-squashfs-factory.bin ar71xx-generic-tl-wr841n-v8-squashfs-sysupgrade.bin
makeimage "$CFGBASE $CFGVPN $CFGHOTSPOT" "default" ar71xx-generic 'TLWR841' ar71xx-generic-tl-wr841n-v9-squashfs-factory.bin ar71xx-generic-tl-wr841n-v9-squashfs-sysupgrade.bin
makeimage "$CFGBASE $CFGVPN $CFGHOTSPOT" "default" ar71xx-generic 'TLWR841' ar71xx-generic-tl-wr841nd-v7-squashfs-factory.bin ar71xx-generic-tl-wr841nd-v7-squashfs-sysupgrade.bin

makeimage "$CFGBASE $CFGVPN $CFGHOTSPOT" "default" ar71xx-generic 'TLWR842' ar71xx-generic-tl-wr842n-v1-squashfs-factory.bin ar71xx-generic-tl-wr842n-v1-squashfs-sysupgrade.bin
makeimage "$CFGBASE $CFGVPN $CFGHOTSPOT" "default" ar71xx-generic 'TLWR842' ar71xx-generic-tl-wr842n-v2-squashfs-factory.bin ar71xx-generic-tl-wr842n-v2-squashfs-sysupgrade.bin

makeimage "$CFGBASE $CFGVPN $CFGHOTSPOT" "default" ar71xx-generic 'TLWR941' ar71xx-generic-tl-wr941nd-v4-squashfs-factory.bin ar71xx-generic-tl-wr941n-v4-squashfs-sysupgrade.bin
makeimage "$CFGBASE $CFGVPN $CFGHOTSPOT" "default" ar71xx-generic 'TLWR941' ar71xx-generic-tl-wr941nd-v6-squashfs-factory.bin ar71xx-generic-tl-wr941n-v6-squashfs-sysupgrade.bin

makeimage "$CFGBASE $CFGVPN $CFGHOTSPOT" "default" ar71xx-generic 'TLWR1043' ar71xx-generic-tl-wr1043nd-v1-squashfs-factory.bin ar71xx-generic-tl-wr1043nd-v1-squashfs-sysupgrade.bin
makeimage "$CFGBASE $CFGVPN $CFGHOTSPOT" "default" ar71xx-generic 'TLWR1043' ar71xx-generic-tl-wr1043nd-v2-squashfs-factory.bin ar71xx-generic-tl-wr1043nd-v2-squashfs-sysupgrade.bin


makeimage "$CFGBASE $CFGVPN $CFGHOTSPOT" "default" ar71xx-generic 'TLWA901' ar71xx-generic-tl-wa901nd-v2-squashfs-factory.bin ar71xx-generic-tl-wa901nd-v2-squashfs-sysupgrade.bin



makeimage "$CFGMINI $CFGVPN $CFGHOTSPOT" "default" ar71xx-generic 'TLMR3020' ar71xx-generic-tl-mr3020-v1-squashfs-factory.bin ar71xx-generic-tl-mr3020-v1-squashfs-sysupgrade.bin
#makeimage "$CFGBASE $CFGVPN $CFGHOTSPOT" "default" ar71xx-generic 'TLMR3040' ar71xx-generic-tl-mr3040-v1-squashfs-factory.bin ar71xx-generic-tl-mr3040-v1-squashfs-sysupgrade.bin

makeimage "$CFGBASE $CFGVPN $CFGHOTSPOT" "default" ar71xx-generic 'TLWDR4300' ar71xx-generic-tl-wdr3600-v1-squashfs-factory.bin ar71xx-generic-tl-wdr3600-v1-squashfs-sysupgrade.bin
makeimage "$CFGBASE $CFGVPN $CFGHOTSPOT" "default" ar71xx-generic 'TLWDR4300' ar71xx-generic-tl-wdr4300-v1-squashfs-factory.bin ar71xx-generic-tl-wdr4300-v1-squashfs-sysupgrade.bin
#makeimage "$CFGBASE $CFGVPN $CFGHOTSPOT" "default" mpc85xx-generic 'TLWDR4900' mpc85xx-generic-tl-wdr4900-v1-squashfs-factory.bin mpc85xx-generic-tl-wdr4900-v1-squashfs-sysupgrade.bin

makeimage "$CFGBASE $CFGVPN $CFGHOTSPOT" "default" ar71xx-generic 'MYNETN600' ar71xx-generic-mynet-n600-squashfs-factory.bin ar71xx-generic-mynet-n600-squashfs-sysupgrade.bin
makeimage "$CFGBASE $CFGVPN $CFGHOTSPOT" "default" ar71xx-generic 'MYNETN750' ar71xx-generic-mynet-n750-squashfs-factory.bin ar71xx-generic-mynet-n750-squashfs-sysupgrade.bin

makeimage "$CFGBASE $CFGVPN $CFGHOTSPOT" "default" ar71xx-generic 'WZRHPAG300H' ar71xx-generic-wzr-hp-ag300h-squashfs-factory.bin ar71xx-generic-wzr-hp-ag300h-squashfs-sysupgrade.bin

#makeimage "$CFGBASE $CFGVPN $CFGx86" "default" x86_64 '' x86_64-combined-ext4.img.gz x86_64-combined-ext4.img.gz
#gzip -dk images/openwrt-x86_64-combined-ext4.img.gz && qemu-img convert -f raw -O vmdk images/openwrt-x86_64-combined-ext4.img images/openwrt-x86_64-combined-squashfs.vmdk && rm images/openwrt-x86_64-combined-ext4.img

#makeimage "$CFGMICRO" "micro" atheros '' atheros-ubnt2-jffs2-64k.bin atheros-combined.jffs2-64k.img

$rename_bin openwrt- ff-nrw- images/*

