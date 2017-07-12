#!/bin/sh
make mrproper
rm -rf out/
export USE_CCACHE=1
export CCACHE_DIR=~/.ccache-kagura-aosp
export ARCH=arm64
export PATH=~/Sony-copy-left/llvm-Snapdragon_LLVM_for_Android_6.0/prebuilt/linux-x86_64/bin:~/Sony-copy-left/aarch64-linux-android-4.9/bin:$PATH
export CC=clang
export CLANG_TRIPLE=aarch64-linux-gnu-
export CROSS_COMPILE=aarch64-linux-android-
make kagura-rytek_defconfig O=./out |& tee log_generic.txt
make -j$(grep -c ^processor /proc/cpuinfo) O=./out |& tee -a log_generic.txt

echo "checking for compiled kernel..."
if [ -f out/arch/arm64/boot/Image.gz-dtb ]
then

	echo "DONE"
	rm -f ~/Sony-copy-left/final_files/boot_kagura.img

	~/Sony-copy-left/final_files/mkbootimg.py \
	--kernel out/arch/arm64/boot/Image.gz-dtb \
	--ramdisk ~/Sony-copy-left/final_files/newrd.gz \
	--cmdline "androidboot.hardware=qcom user_debug=31 msm_rtb.filter=0x237 ehci-hcd.park=3 lpm_levels.sleep_disabled=1 cma=16M@0-0xffffffff coherent_pool=2M nr_cpus=4" \
	--base 0x80000000 \
	--pagesize 4096 \
	--ramdisk_offset 0x02200000 \
	--tags_offset 0x02000000 \
	--output ~/Sony-copy-left/final_files/boot_kagura.img

	cd ~/Sony-copy-left/final_files/

	if [ -e boot_kagura.img ]
	then
		cp boot_kagura.img boot.img
		zip RyTek_Kernel.zip boot.img
		rm -f boot.img
	fi
fi
