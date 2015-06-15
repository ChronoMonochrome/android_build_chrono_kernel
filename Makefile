current_dir = $(shell pwd)

SOURCE = $(current_dir)/../android_kernel
BUILD = $(current_dir)/../obj
PACKAGE = $(current_dir)
VERSION = 3.0
KERNEL_NAME=chrono_kernel_r$(VERSION).zip
CC = /media/chrono/AMV/linux/gcc_4.9/bin/arm-eabi-

AUTOLOAD_LIST = bfq-iosched cpufreq_interactive cpufreq_zenx cpufreq_ondemandplus logger

all: codina

codina: build package-full

codina-light: build package-light

build: $(SOURCE)
	-mkdir $(BUILD);
	make -C $(SOURCE) O=$(BUILD) ARCH=arm codina_defconfig
	make -C $(SOURCE) O=$(BUILD) ARCH=arm CROSS_COMPILE=$(CC) -k

clean:
	rm -fr system/lib/modules/*
	mkdir system/lib/modules/autoload
	rm -fr ramdisk/modules/*
	mkdir ramdisk/modules/autoload
	rm -f boot.img
	
package-full: clean
	make -C $(SOURCE) O=$(BUILD) modules_install INSTALL_MOD_PATH=$(PACKAGE)/system/

	rm -f $(PACKAGE)/system/lib/modules/ecryptfs.ko
	cp -f $(PACKAGE)/system/lib/modules/param.ko $(PACKAGE)/ramdisk/modules/param.ko
	cp -f $(PACKAGE)/system/lib/modules/j4fs.ko $(PACKAGE)/ramdisk/modules/j4fs.ko

	$(foreach module,$(AUTOLOAD_LIST), \
			mv $(PACKAGE)/system/lib/modules/$(module).ko \
			 $(PACKAGE)/ramdisk/modules/autoload/$(module).ko;)

	cp -f $(BUILD)/arch/arm/boot/zImage $(PACKAGE)/boot.img

	rm -f $(KERNEL_NAME);

	zip -9r $(KERNEL_NAME) META-INF system ramdisk genfstab osfiles recovery boot.img tmp

package-light: clean
	make -C $(SOURCE) O=$(BUILD) modules_install INSTALL_MOD_PATH=$(PACKAGE)/system/

	rm -f $(PACKAGE)/system/lib/modules/ecryptfs.ko
	cp -f $(PACKAGE)/system/lib/modules/param.ko $(PACKAGE)/ramdisk/modules/param.ko
	cp -f $(PACKAGE)/system/lib/modules/j4fs.ko $(PACKAGE)/ramdisk/modules/j4fs.ko

	$(foreach module,$(AUTOLOAD_LIST), \
			mv $(PACKAGE)/system/lib/modules/$(module).ko \
			 $(PACKAGE)/ramdisk/modules/autoload/$(module).ko;)

	cp -f $(BUILD)/arch/arm/boot/zImage $(PACKAGE)/boot.img

	rm -f $(KERNEL_NAME);

	zip -9r $(KERNEL_NAME) META-INF system ramdisk recovery boot.img tmp

install: $(KERNEL_NAME)
	adb push $(KERNEL_NAME) /storage/sdcard1/$(KERNEL_NAME)
