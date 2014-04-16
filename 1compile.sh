#!/bin/bash


setConfig () {
  key=$1
  value=$2
  grep -q "CONFIG_$key" .config || exit 1
  sed -i "/CONFIG_$key[\=\ ]/d" .config
  echo "CONFIG_$key=$value" >> .config
}

prepOwrt() {
  (
    cd openwrt || exit 1
    git clean -fdX || exit 1
    ln -s ../dl
    cp feeds.conf.default feeds.conf
    echo src-git fastd git://git.metameute.de/lff/pkg_fastd >> feeds.conf

    scripts/feeds update
    scripts/feeds install kmod-batman-adv
    scripts/feeds install fastd

    echo CONFIG_TARGET_$1=y > .config || exit1
    make defconfig || exit 1

    setConfig PACKAGE_kmod-batman-adv m
    setConfig PACKAGE_kmod-bridge m

    make defconfig || exit 1

    make download || exit 1

  ) || exit 1
}

prepOwrt ar71xx 
echo blub
