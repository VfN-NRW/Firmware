#!./runByLine
rm -rf OpenWrt-ImageBuilder-ar71xx_generic-for-linux-x86_64/
tar xvjf imagebuilder/OpenWrt-ImageBuilder-ar71xx_generic-for-linux-x86_64.tar.bz2

#rm -rf OpenWrt-ImageBuilder-mpc85xx_generic-for-linux-x86_64/
#tar xvjf openwrt/bin/mpc85xx/OpenWrt-ImageBuilder-mpc85xx_generic-for-linux-x86_64.tar.bz2
#cp ./openwrt/build_dir/target-powerpc_*/linux-mpc85xx_generic/linux-*/scripts/ OpenWrt-ImageBuilder-mpc85xx_generic-for-linux-x86_64/build_dir/target-powerpc_*/linux-mpc85xx_generic/linux-*/ -r
#cp ./openwrt/build_dir/target-powerpc_*/linux-mpc85xx_generic/linux-*/arch/ OpenWrt-ImageBuilder-mpc85xx_generic-for-linux-x86_64/build_dir/target-powerpc_*/linux-mpc85xx_generic/linux-*/ -r

#rm -rf OpenWrt-ImageBuilder-x86_kvm_guest-for-linux-x86_64
#tar xvjf openwrt/bin/x86/OpenWrt-ImageBuilder-x86_kvm_guest-for-linux-x86_64.tar.bz2
#cp -R ./openwrt/staging_dir/host/lib/ OpenWrt-ImageBuilder-x86_kvm_guest-for-linux-x86_64/staging_dir/host/

sed -i 's/# CONFIG_TARGET_ROOTFS_SQUASHFS is not set/CONFIG_TARGET_ROOTFS_SQUASHFS=y/' OpenWrt-ImageBuilder-*/.config 
