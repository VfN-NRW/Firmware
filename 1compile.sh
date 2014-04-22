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
    cd openwrt || exit 1
    git clean -fdX || exit 1
    ln -s ../dl
    cp feeds.conf.default feeds.conf
    echo src-git fastd git://git.metameute.de/lff/pkg_fastd >> feeds.conf
    echo src-link custom `pwd`/../custom-feed >> feeds.conf

    scripts/feeds update
    scripts/feeds install kmod-batman-adv
    scripts/feeds install fastd
    scripts/feeds install curl
    scripts/feeds install ecdsautils

    echo CONFIG_TARGET_$1=y > .config || exit1
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
    setConfig PACKAGE_6relayd n
    setConfig PACKAGE_odhcp6c n
    setConfig PACKAGE_hostapd m
    setConfig PACKAGE_hostapd-utils m
    setConfig PACKAGE_ppp m
    setConfig PACKAGE_ecdsautils m
    make defconfig || exit 1

    setConfig PACKAGE_kmod-ebtables-ipv4 m
    setConfig PACKAGE_kmod-ebtables-ipv6 m
    setConfig PACKAGE_ebtables-utils m
    make defconfig || exit 1

    make download || exit 1

    make || exit 1
    cp bin/*/OpenWrt-ImageBuilder* ../imagebuilder/ || exit 1

  ) || exit 1
}

buildOwrt ar71xx 
buildOwrt x86_64

