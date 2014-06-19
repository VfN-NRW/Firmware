#!/bin/bash

setConfig () {
  key=$1
  value=$2
  echo Config: $key = $value
  grep -q "CONFIG_$key" .config || exit 1
  sed -i "/CONFIG_$key[\=\ ]/d" .config
  echo "CONFIG_$key=$value" >> .config
}

buildOwrt() {
  (
    TARGET=$1
    cd openwrt || exit 1
    git clean -fdX || exit 1
    ln -s ../dl
    cp feeds.conf.default feeds.conf
    echo src-git fastd git://git.metameute.de/lff/pkg_fastd >> feeds.conf
    echo src-link custom `pwd`/../custom-feed >> feeds.conf

    scripts/feeds update
    scripts/feeds install kmod-batman-adv
    scripts/feeds install batctl
    scripts/feeds install fastd
    scripts/feeds install ecdsautils
    scripts/feeds install haveged
    scripts/feeds install socat

    echo CONFIG_TARGET_$TARGET=y > .config || exit1
    make defconfig || exit 1

    setConfig IB y
    setConfig TARGET_ROOTFS_SQUASHFS n
    setConfig PACKAGE_kmod-batman-adv m
    setConfig PACKAGE_kmod-bridge m
    setConfig PACKAGE_curl m
    setConfig PACKAGE_ebtables m
    setConfig PACKAGE_ip6tables m
    setConfig PACKAGE_iptables m
    setConfig PACKAGE_ip m
    setConfig PACKAGE_fastd m
    setConfig PACKAGE_odhcp6c n
    setConfig PACKAGE_hostapd m
    setConfig PACKAGE_ppp m
    setConfig PACKAGE_ecdsautils m
    setConfig PACKAGE_haveged m
    setConfig PACKAGE_socat m
    #[ $TARGET == "ar71xx" ] && setConfig PACKAGE_kmod-ath m
    setConfig PACKAGE_tc m
    setConfig PACKAGE_kmod-sched-core m
    setConfig PACKAGE_kmod-sched m
    make defconfig || exit 1

    setConfig PACKAGE_batctl m
    setConfig PACKAGE_kmod-ebtables-ipv4 m
    setConfig PACKAGE_kmod-ebtables-ipv6 m
    setConfig PACKAGE_ebtables-utils m
    setConfig PACKAGE_hostapd-utils m
    #[ $TARGET == "ar71xx" ] && setConfig ATH_USER_REGD y
    #[ $TARGET == "ar71xx" ] && setConfig PACKAGE_ATH_DFS y
    make defconfig || exit 1

    make download || exit 1
    make defconfig || exit 1

    make V=s || exit 1
    cp bin/*/OpenWrt-ImageBuilder* ../imagebuilder/ || exit 1

  ) || exit 1
}

buildOwrt ar71xx 
#buildOwrt x86_64

