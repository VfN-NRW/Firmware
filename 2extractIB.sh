#!./runByLine
rm -rf OpenWrt-ImageBuilder-ar71xx_generic.linux-x86_64/
tar xvjf imagebuilder/OpenWrt-ImageBuilder-ar71xx-generic.Linux-x86_64.tar.bz2

rm -rf OpenWrt-ImageBuilder-atheros.linux-x86_64/
tar xvjf imagebuilder/OpenWrt-ImageBuilder-atheros.Linux-x86_64.tar.bz2

rm -rf OpenWrt-ImageBuilder-mpc85xx_generic.linux-x86_64/
tar xvjf imagebuilder/OpenWrt-ImageBuilder-mpc85xx_generic.Linux-x86_64.tar.bz2

rm -rf OpenWrt-ImageBuilder-x86_64.linux-x86_64
tar xvjf imagebuilder/OpenWrt-ImageBuilder-x86_64.Linux-x86_64.tar.bz2
#cp -R ./openwrt/staging_dir/host/lib/ OpenWrt-ImageBuilder-x86_64.linux-x86_64/staging_dir/host/

#sed -i 's/# CONFIG_TARGET_ROOTFS_SQUASHFS is not set/CONFIG_TARGET_ROOTFS_SQUASHFS=y/' OpenWrt-ImageBuilder-*/.config 
