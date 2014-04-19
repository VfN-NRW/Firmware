function makeimage {
  packages="$1"
  target=$2
  profile=$3
  factory=$4
  sysupgrade=$5
  (
    cd OpenWrt-ImageBuilder-${target}-for-linux-x86_64/
    make clean
    rm -rf myfiles/

    mkdir myfiles
    cp ../files/_all/* myfiles/ -r -v
    echo '	option filename ff-nrw-'${sysupgrade} >> myfiles/etc/config/freifunk
    make image FILES="./myfiles/" PROFILE="${profile}" PACKAGES="$packages"
    cp bin/*/openwrt-${sysupgrade} ../images
    cp bin/*/openwrt-${factory} ../images
  ) 2>&1 | tee logs/makeimage-${profile}
}

rm images/*

BUILD=$(cat build.txt) 
BUILD=$(($BUILD+1))
echo $BUILD > build.txt


CFGBASE='-6relayd -kmod-wpad -odhcp6c -odhcpd -wpad-mini fastd kmod-batman-adv ip curl ecdsautils'
CFGHOTSPOT='hostapd'

echo $BUILD > files/_all/build
makeimage "$CFGBASE $CFGHOTSPOT" ar71xx_generic 'TLWR740' ar71xx-generic-tl-wr740n-v4-squashfs-factory.bin ar71xx-generic-tl-wr740n-v4-squashfs-sysupgrade.bin
makeimage "$CFGBASE $CFGHOTSPOT" ar71xx_generic 'TLMR3020' ar71xx-generic-tl-mr3020-v1-squashfs-factory.bin ar71xx-generic-tl-mr3020-v1-squashfs-sysupgrade.bin
makeimage "$CFGBASE $CFGHOTSPOT" ar71xx_generic 'TLMR3040' ar71xx-generic-tl-mr3040-v1-squashfs-factory.bin ar71xx-generic-tl-mr3040-v1-squashfs-sysupgrade.bin
makeimage "$CFGBASE $CFGHOTSPOT" mpc85xx_generic 'TLWDR4900' mpc85xx-generic-tl-wdr4900-v1-squashfs-factory.bin mpc85xx-generic-tl-wdr4900-v1-squashfs-sysupgrade.bin
makeimage "$CFGBASE $CFGHOTSPOT" ar71xx_generic 'MYNETN750' ar71xx-generic-mynet-n750-squashfs-factory.bin ar71xx-generic-mynet-n750-squashfs-sysupgrade.bin 
rename.ul openwrt- ff-nrw- images/*
