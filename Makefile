current_dir = $(shell pwd)

SOURCE = ../chrono_kernel
BUILD = ../obj
PACKAGE = $(current_dir)

#ARM_CC = /home/chrono/tools/opt/armv7a-linux-gnueabihf-gcc-5.2.0_i686/bin/armv7a-linux-gnueabihf-
#ARM_CC = /media/chrono/Other/cross/gcc-linaro-arm-linux-gnueabihf-4.9-2014.09_linux/bin/arm-linux-gnueabihf-
#ARM_CC = /home/chrono/tools/opt/armv7a-linux-gnueabihf-gcc-5.2.0_with_isl_x86/bin/armv7a-linux-gnueabihf-
ARM_CC = ../LinaroMod-arm-eabi-5.1/bin/arm-eabi-

VERSION=$(shell git -C $(SOURCE) describe --tags --exact-match --match 'r[0-9]*')
ifeq ("$(VERSION)", "")
   VERSION=$(shell git -C $(SOURCE) tag | grep "r3" | tail -n 1 )
endif
KERNEL_NAME=chrono_kernel_$(VERSION).zip


AUTOLOAD_LIST = bfq-iosched cpufreq_zenx cpufreq_ondemandplus logger 
#lowmemorykiller_sony

all: codina

codina: build package-full

codina-light: build package-light

build: $(SOURCE)
	mkdir -p $(BUILD);
	make -C $(SOURCE) O=$(BUILD) ARCH=arm codina_defconfig
	-git -C $(SOURCE) checkout 77be6cb arch/arm/crypto/Makefile
	-make -C $(SOURCE) O=$(BUILD) ARCH=arm CROSS_COMPILE=$(ARM_CC) -j5 -k
	-git -C $(SOURCE) checkout HEAD arch/arm/crypto/Makefile

clean:
	rm -fr system/lib/modules/*
	mkdir -p system/lib/modules/autoload
	touch system/lib/modules/autoload/.placeholder
	rm -fr ramdisk/modules/*
	mkdir -p ramdisk/modules/autoload
	touch ramdisk/modules/autoload/.placeholder
	rm -f boot.img
	
package-full: clean
	-make -C $(SOURCE) O=$(BUILD) modules_install INSTALL_MOD_PATH=$(PACKAGE)/system/

	rm -f $(PACKAGE)/system/lib/modules/ecryptfs.ko
	cp -f $(PACKAGE)/system/lib/modules/param.ko $(PACKAGE)/ramdisk/modules/param.ko
	cp -f $(PACKAGE)/system/lib/modules/j4fs.ko $(PACKAGE)/ramdisk/modules/j4fs.ko
	cp -f $(PACKAGE)/system/lib/modules/exfat.ko $(PACKAGE)/ramdisk/modules/exfat.ko
	cp -f $(PACKAGE)/system/lib/modules/f2fs.ko $(PACKAGE)/ramdisk/modules/f2fs.ko

	$(foreach module,$(AUTOLOAD_LIST), \
			cp $(PACKAGE)/system/lib/modules/$(module).ko \
			 $(PACKAGE)/ramdisk/modules/autoload/$(module).ko;)

	cp -f $(BUILD)/arch/arm/boot/zImage $(PACKAGE)/boot.img

	rm -f $(KERNEL_NAME);

	zip -9r $(KERNEL_NAME) META-INF system genfstab ramdisk osfiles recovery boot.img scripts init.d

package-light: clean
	-make -C $(SOURCE) O=$(BUILD) modules_install INSTALL_MOD_PATH=$(PACKAGE)/system/

	rm -f $(PACKAGE)/system/lib/modules/ecryptfs.ko
	cp -f $(PACKAGE)/system/lib/modules/param.ko $(PACKAGE)/ramdisk/modules/param.ko
	cp -f $(PACKAGE)/system/lib/modules/j4fs.ko $(PACKAGE)/ramdisk/modules/j4fs.ko
	cp -f $(PACKAGE)/system/lib/modules/exfat.ko $(PACKAGE)/ramdisk/modules/exfat.ko
	cp -f $(PACKAGE)/system/lib/modules/f2fs.ko $(PACKAGE)/ramdisk/modules/f2fs.ko


	$(foreach module,$(AUTOLOAD_LIST), \
			mv $(PACKAGE)/system/lib/modules/$(module).ko \
			 $(PACKAGE)/ramdisk/modules/autoload/$(module).ko;)

	cp -f $(BUILD)/arch/arm/boot/zImage $(PACKAGE)/boot.img

	rm -f $(KERNEL_NAME);

	zip -9r $(KERNEL_NAME) META-INF system ramdisk boot.img scripts/main.sh \
		scripts/check_ramdisk_partition.sh scripts/initd_install.sh init.d

modules:
	-make -C $(SOURCE) O=$(BUILD) CROSS_COMPILE=$(ARM_CC) modules
	-make -C $(SOURCE) O=$(BUILD) modules_install INSTALL_MOD_PATH=$(PACKAGE)/system/

install: $(KERNEL_NAME)
	adb push $(KERNEL_NAME) /storage/sdcard0/$(KERNEL_NAME)

upload: $(KERNEL_NAME)
	../../u.sh $(KERNEL_NAME)
