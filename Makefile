current_dir = $(shell pwd)

SOURCE = ../chrono_kernel
BUILD = ../obj
PACKAGE = $(current_dir)

VERSION = $(shell git -C $(SOURCE) describe --tags --exact-match --match 'r[0-9]*')
KERNEL_NAME=chrono_kernel_$(VERSION).zip
ARM_CC = ../arm-eabi-5.1/bin/arm-eabi-

AUTOLOAD_LIST = bfq-iosched cpufreq_zenx cpufreq_ondemandplus logger

all: codina

codina: build package-full

codina-light: build package-light

build: $(SOURCE)
	-mkdir $(BUILD);
	make -C $(SOURCE) O=$(BUILD) ARCH=arm codina_defconfig
	make -C $(SOURCE) O=$(BUILD) ARCH=arm CROSS_COMPILE=$(ARM_CC) -k -j5

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

	zip -9r $(KERNEL_NAME) META-INF system ramdisk boot.img tmp

install: $(KERNEL_NAME)
	adb push $(KERNEL_NAME) /storage/sdcard0/$(KERNEL_NAME)
