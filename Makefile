current_dir := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

SOURCE ?= ../ck
BUILD ?= ../obj
BUILD_NODEBUG ?=../obj_nodebug
BUILD_SELINUX ?=../obj_selinux
BUILD_CM13 ?=../obj_cm13

PACKAGE ?= $(current_dir)

export USE_CCACHE=1
export CCACHE_DIR=../ck_ccache

#ARM_CC = /home/chrono/tools/opt/armv7a-linux-gnueabihf-gcc-5.2.0_i686/bin/armv7a-linux-gnueabihf-
#ARM_CC = /media/chrono/Other/cross/gcc-linaro-arm-linux-gnueabihf-4.9-2014.09_linux/bin/arm-linux-gnueabihf-
#ARM_CC = /home/chrono/arm-cortexa9_neon-linux-gnueabihf-6.1.0/bin/arm-cortexa9_neon-linux-gnueabihf-
ARM_CC ?= ../armv7a-linux-gnueabihf-5.2/bin/armv7a-linux-gnueabihf-
#ARM_CC = ../LinaroMod-arm-eabi-5.1/bin/arm-eabi-
#ARM_CC = ../arm-cortex_a9-linux-gnueabihf-linaro_4.9.4-2015.06/bin/arm-eabi-
#ARM_CC = ../arm-eabi-5.1/bin/arm-eabi-

VERSION=$(shell git -C $(SOURCE) tag | grep 'r[0-9].[0-9]' | sort -V | tail -n1)
KERNEL_NAME=chrono_kernel_$(VERSION).zip
KERNEL_NAME_NODEBUG=chrono_kernel_$(VERSION)-nodebug.zip
KERNEL_NAME_SELINUX=chrono_kernel_$(VERSION)-selinux.zip
KERNEL_NAME_CM13=chrono_kernel_$(VERSION)-cm13.zip
KERNEL_NAME_PRIVATE=chrono_kernel_$(VERSION)-private.zip

ZIP_LINE_FULL=META-INF genfstab boot.img ramdisk.7z tmp modules.7z scripts init.d
ZIP_LINE_LIGHT=META-INF boot.img modules.7z tmp scripts/main.sh \
		scripts/remove_modules.sh scripts/unpack_modules.sh scripts/update_modules.sh \
		scripts/check_ramdisk_partition.sh scripts/initd_install.sh init.d

HIDE=@

PACKAGE_COMPLETED_LINE="Package is completed and installed to"

AUTOLOAD_LIST = cpufreq_zenx cpufreq_ondemandplus logger pn544
SYSTEM_MODULE_LIST = hw_random param fuse sdcardfs j4fs exfat f2fs startup_reason #\
	             #display-ws2401_dpi display-s6d27a1_dpi

NUMBER_JOBS?=2

all: codina upload codina-nodebug upload-nodebug

codina: build package-full
codina-light: build package-light
codina-nodebug: build-nodebug package-full-nodebug
codina-nodebug-light: build-nodebug package-light-nodebug
codina-selinux: build-selinux package-full-selinux
codina-selinux-light: build-selinux package-light-selinux
codina-cm13: build-cm13 package-full-cm13 
codina-cm13: build-cm13 package-light-cm13
codina-private: update-private-config build-private package-private

update-private-config: $(SOURCE)/arch/arm/configs/codina_nodebug_defconfig
	cp $(SOURCE)/arch/arm/configs/codina_nodebug_defconfig $(SOURCE)/arch/arm/configs/private_defconfig
	sed -ie "s,CONFIG_LIVEOPP_CUSTOM_BOOTUP_FREQ_MIN=[0-9]*,# bootup min freq\nCONFIG_LIVEOPP_CUSTOM_BOOTUP_FREQ_MIN=1200000," $(SOURCE)/arch/arm/configs/private_defconfig
	sed -ie "s,CONFIG_LIVEOPP_CUSTOM_BOOTUP_FREQ_MAX=[0-9]*,# bootup max freq\nCONFIG_LIVEOPP_CUSTOM_BOOTUP_FREQ_MAX=1200000," $(SOURCE)/arch/arm/configs/private_defconfig

build-private: $(SOURCE)
	mkdir -p $(BUILD_NODEBUG);
	make -C $(SOURCE) O=$(BUILD_NODEBUG) ARCH=arm private_defconfig
	-make -C $(SOURCE) O=$(BUILD_NODEBUG) ARCH=arm CROSS_COMPILE=$(ARM_CC)  -j$(NUMBER_JOBS) -k

build: $(SOURCE)
	mkdir -p $(BUILD);
	make -C $(SOURCE) O=$(BUILD) ARCH=arm codina_defconfig
	-make -C $(SOURCE) V=0 O=$(BUILD) ARCH=arm CROSS_COMPILE=$(ARM_CC)  -j$(NUMBER_JOBS) -k

build-nodebug: $(SOURCE)
	mkdir -p $(BUILD_NODEBUG);
	make -C $(SOURCE) O=$(BUILD_NODEBUG) ARCH=arm codina_nodebug_defconfig
	-make -C $(SOURCE) O=$(BUILD_NODEBUG) ARCH=arm CROSS_COMPILE=$(ARM_CC)  -j$(NUMBER_JOBS) -k

build-selinux: $(SOURCE)
	mkdir -p $(BUILD_SELINUX);
	make -C $(SOURCE) O=$(BUILD_SELINUX) ARCH=arm codina_selinux_defconfig
	-make -C $(SOURCE) O=$(BUILD_SELINUX) ARCH=arm CROSS_COMPILE=$(ARM_CC)  -j$(NUMBER_JOBS) -k

build-cm13: $(SOURCE)
	mkdir -p $(BUILD_CM13);
	make -C $(SOURCE) O=$(BUILD_CM13) ARCH=arm codina_cm13_defconfig
	-make -C $(SOURCE) O=$(BUILD_CM13) ARCH=arm CROSS_COMPILE=$(ARM_CC)  -j$(NUMBER_JOBS) -k

clean:
	rm -fr system/lib/modules/*
	mkdir -p system/lib/modules/autoload
	touch system/lib/modules/autoload/.placeholder
	rm -fr ramdisk/modules/*
	mkdir -p ramdisk/modules/autoload
	touch ramdisk/modules/autoload/.placeholder
	rm -f boot.img
	rm -f modules.7z
	rm -f ramdisk.7z
	

modules-install: modules-net-order
	-make -C $(SOURCE) O=$(BUILD) modules_install INSTALL_MOD_PATH=$(PACKAGE)/system/

modules-install-nodebug: modules-net-order-nodebug
	-make -C $(SOURCE) O=$(BUILD_NODEBUG) modules_install INSTALL_MOD_PATH=$(PACKAGE)/system/

modules-install-selinux:
	-make -C $(SOURCE) O=$(BUILD_SELINUX) modules_install INSTALL_MOD_PATH=$(PACKAGE)/system/

modules-install-cm13:
	-make -C $(SOURCE) O=$(BUILD_CM13) modules_install INSTALL_MOD_PATH=$(PACKAGE)/system/

modules-net-order: $(BUILD)/net/modules.order
	cp $(BUILD)/net/modules.order $(PACKAGE)/net_modules.order

modules-net-order-nodebug: $(BUILD_NODEBUG)/net/modules.order
	cp $(BUILD_NODEBUG)/net/modules.order $(PACKAGE)/net_modules.order

get_module_list: $(PACKAGE)/net_modules.order
	sh $(PACKAGE)/get_modules_list.sh $(PACKAGE)/net_modules.order $(PACKAGE)/ramdisk/modules_list.txt

package-modules: get_module_list
	$(foreach module,$(shell cat $(PACKAGE)/ramdisk/modules_list.txt), \
                        if test -f $(PACKAGE)/system/lib/modules/$(module).ko; then \
				cp $(PACKAGE)/system/lib/modules/$(module).ko \
                         $(PACKAGE)/ramdisk/modules/$(module).ko; \
			fi;)

	$(foreach module,$(SYSTEM_MODULE_LIST), \
                        if test -f $(PACKAGE)/system/lib/modules/$(module).ko; then \
				cp $(PACKAGE)/system/lib/modules/$(module).ko \
                         $(PACKAGE)/ramdisk/modules/$(module).ko; \
			fi;)

	$(foreach module,$(AUTOLOAD_LIST), \
			if test -f $(PACKAGE)/system/lib/modules/$(module).ko; then \
                        	cp $(PACKAGE)/system/lib/modules/$(module).ko \
                         $(PACKAGE)/ramdisk/modules/autoload/$(module).ko; \
	fi;)

	rm -f modules.7z

	7za a -t7z modules.7z -m0=lzma2 -mx=2 -md=16m -m1=LZMA2:d=16m -mhe ramdisk system

package-ramdisk:
	rm -f ramdisk.7z
	7za a -t7z ramdisk.7z -m0=lzma2 -mx=2 -md=16m -m1=LZMA2:d=16m -mhe osfiles recovery

package-full:
	make -C $(current_dir) clean modules-install package-ramdisk package-modules
	cp -f $(BUILD)/arch/arm/boot/zImage $(PACKAGE)/boot.img
	rm -f $(KERNEL_NAME);
	zip -9r $(KERNEL_NAME) $(ZIP_LINE_FULL)
	$(HIDE)echo "$(PACKAGE_COMPLETED_LINE) $(current_dir)/$(KERNEL_NAME)"

package-full-selinux:
	make -C $(current_dir) clean modules-install-selinux package-ramdisk package-modules
	cp -f $(BUILD_SELINUX)/arch/arm/boot/zImage $(PACKAGE)/boot.img
	rm -f $(KERNEL_NAME_SELINUX);
	zip -9r $(KERNEL_NAME_SELINUX) $(ZIP_LINE_FULL)
	$(HIDE)echo "$(PACKAGE_COMPLETED_LINE) $(current_dir)/$(KERNEL_NAME_SELINUX)"

package-full-cm13:
	make -C $(current_dir) clean modules-install-cm13 package-ramdisk package-modules
	cp -f $(BUILD_CM13)/arch/arm/boot/zImage $(PACKAGE)/boot.img
	rm -f $(KERNEL_NAME_CM13);
	zip -9r $(KERNEL_NAME_CM13) $(ZIP_LINE_FULL)
	$(HIDE)echo "$(PACKAGE_COMPLETED_LINE) $(current_dir)/$(KERNEL_NAME_CM13)"

package-full-nodebug: 
	make -C $(current_dir) clean modules-install-nodebug package-modules package-ramdisk
	cp -f $(BUILD_NODEBUG)/arch/arm/boot/zImage $(PACKAGE)/boot.img
	rm -f $(KERNEL_NAME_NODEBUG);
	zip -9r $(KERNEL_NAME_NODEBUG) $(ZIP_LINE_FULL)
	$(HIDE)echo "$(PACKAGE_COMPLETED_LINE) $(current_dir)/$(KERNEL_NAME_NODEBUG)"

package-light:
	make -C $(current_dir) clean modules-install package-modules
	cp -f $(BUILD)/arch/arm/boot/zImage $(PACKAGE)/boot.img
	rm -f $(KERNEL_NAME);
	zip -9r $(KERNEL_NAME) $(ZIP_LINE_LIGHT)
	$(HIDE)echo "$(PACKAGE_COMPLETED_LINE) $(current_dir)/$(KERNEL_NAME)"

package-light-nodebug: 
	make -C $(current_dir) clean modules-install-nodebug package-modules
	cp -f $(BUILD_NODEBUG)/arch/arm/boot/zImage $(PACKAGE)/boot.img
	rm -f $(KERNEL_NAME_NODEBUG);
	zip -9r $(KERNEL_NAME_NODEBUG) $(ZIP_LINE_LIGHT)
	$(HIDE)echo "$(PACKAGE_COMPLETED_LINE) $(current_dir)/$(KERNEL_NAME_NODEBUG)"

package-light-selinux: 
	make -C $(current_dir) clean modules-install-nodebug package-modules
	cp -f $(BUILD_SELINUX)/arch/arm/boot/zImage $(PACKAGE)/boot.img
	rm -f $(KERNEL_NAME_SELINUX);
	KERNEL_NAME_ACTUAL=$(KERNEL_NAME_SELINUX)
	zip -9r $(KERNEL_NAME_SELINUX) $(ZIP_LINE_LIGHT)
	$(HIDE)echo "$(PACKAGE_COMPLETED_LINE) $(current_dir)/$(KERNEL_NAME_SELINUX)"

package-light-cm13: 
	make -C $(current_dir) clean modules-install-nodebug package-modules
	cp -f $(BUILD_CM13)/arch/arm/boot/zImage $(PACKAGE)/boot.img
	rm -f $(KERNEL_NAME_CM13);
	zip -9r $(KERNEL_NAME_CM13) $(ZIP_LINE_LIGHT)
	$(HIDE)echo "$(PACKAGE_COMPLETED_LINE) $(current_dir)/$(KERNEL_NAME_CM13)"

package-private: 
	make -C $(current_dir) clean modules-install-nodebug package-modules
	cp -f $(BUILD_NODEBUG)/arch/arm/boot/zImage $(PACKAGE)/boot.img
	rm -f $(KERNEL_NAME_PRIVATE);
	zip -9r $(KERNEL_NAME_PRIVATE) $(ZIP_LINE_LIGHT)
	$(HIDE)echo "$(PACKAGE_COMPLETED_LINE) $(current_dir)/$(KERNEL_NAME_PRIVATE)"

modules:
	-make -C $(SOURCE) O=$(BUILD) CROSS_COMPILE=$(ARM_CC) modules
	-make -C $(SOURCE) O=$(BUILD) modules_install INSTALL_MOD_PATH=$(PACKAGE)/system/

modules_nodebug:
	-make -C $(SOURCE) O=$(BUILD_NODEBUG) CROSS_COMPILE=$(ARM_CC) modules
	-make -C $(SOURCE) O=$(BUILD_NODEBUG) modules_install INSTALL_MOD_PATH=$(PACKAGE)/system/


install: $(KERNEL_NAME)
	adb push $(KERNEL_NAME) /storage/sdcard0/

install-private: $(KERNEL_NAME_PRIVATE)
	adb push $(KERNEL_NAME_PRIVATE) /storage/sdcard0/

upload: $(KERNEL_NAME)
	up $(KERNEL_NAME)

upload-nodebug: $(KERNEL_NAME_NODEBUG)
	up $(KERNEL_NAME_NODEBUG)

upload-selinux: $(KERNEL_NAME_SELINUX)
	up $(KERNEL_NAME_SELINUX)

upload-cm13: $(KERNEL_NAME_CM13)
	up $(KERNEL_NAME_CM13)

upload-private: $(KERNEL_NAME_PRIVATE)
	up $(KERNEL_NAME_PRIVATE)
