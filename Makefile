current_dir = $(shell pwd)

SOURCE = ../chrono_kernel
BUILD = ../obj
PACKAGE = $(current_dir)

VERSION = $(shell git -C $(SOURCE) describe --tags --exact-match --match 'r[0-9]*')
KERNEL_NAME=chrono_kernel_$(VERSION).zip
#ARM_CC = /media/chrono/AMV/linux/gcc_4.9/bin/arm-eabi-
#ARM_CC = ../gcc-linaro-arm-linux-gnueabihf-4.9-2014.09_linux/bin/arm-linux-gnueabihf-
#ARM_CC = /home/chrono/tools/opt/armv7a-linux-gnueabihf-gcc-5.2.0_i686/bin/armv7a-linux-gnueabihf-
ARM_CC = /home/chrono/tools/opt/armv7a-linux-gnueabihf-linaro-gcc-4.9.4/bin/armv7a-linux-gnueabihf-
#ARM_CC = ../arm-eabi-5.1/bin/arm-eabi-
#ARM_CC = ../gcc-linaro-4.9-2015.05-x86_64_arm-linux-gnueabihf/bin/arm-linux-gnueabihf-

AUTOLOAD_LIST = bfq-iosched cpufreq_zenx cpufreq_ondemandplus logger

all: codina

codina: build package-full

codina-light: build package-light

build: $(SOURCE)
	-mkdir $(BUILD);
	make -C $(SOURCE) O=$(BUILD) ARCH=arm codina_defconfig
	-make -C $(SOURCE) O=$(BUILD) ARCH=arm CROSS_COMPILE=$(ARM_CC) -j5 -k

clean:
	rm -fr system/lib/modules/*
	mkdir system/lib/modules/autoload
	rm -fr ramdisk/modules/*
	mkdir ramdisk/modules/autoload
	rm -f boot.img
	
package-full: clean
	-make -C $(SOURCE) O=$(BUILD) modules_install INSTALL_MOD_PATH=$(PACKAGE)/system/

	rm -f $(PACKAGE)/system/lib/modules/ecryptfs.ko
	cp -f $(PACKAGE)/system/lib/modules/param.ko $(PACKAGE)/ramdisk/modules/param.ko
	cp -f $(PACKAGE)/system/lib/modules/j4fs.ko $(PACKAGE)/ramdisk/modules/j4fs.ko

	$(foreach module,$(AUTOLOAD_LIST), \
			mv $(PACKAGE)/system/lib/modules/$(module).ko \
			 $(PACKAGE)/ramdisk/modules/autoload/$(module).ko;)

	cp -f $(BUILD)/arch/arm/boot/zImage $(PACKAGE)/boot.img

	rm -f $(KERNEL_NAME);

	zip -9r $(KERNEL_NAME) META-INF system ramdisk osfiles recovery boot.img tmp init.d

package-light: clean
	-make -C $(SOURCE) O=$(BUILD) modules_install INSTALL_MOD_PATH=$(PACKAGE)/system/

	rm -f $(PACKAGE)/system/lib/modules/ecryptfs.ko
	cp -f $(PACKAGE)/system/lib/modules/param.ko $(PACKAGE)/ramdisk/modules/param.ko
	cp -f $(PACKAGE)/system/lib/modules/j4fs.ko $(PACKAGE)/ramdisk/modules/j4fs.ko

	$(foreach module,$(AUTOLOAD_LIST), \
			mv $(PACKAGE)/system/lib/modules/$(module).ko \
			 $(PACKAGE)/ramdisk/modules/autoload/$(module).ko;)

	cp -f $(BUILD)/arch/arm/boot/zImage $(PACKAGE)/boot.img

	rm -f $(KERNEL_NAME);

	zip -9r $(KERNEL_NAME) META-INF system ramdisk boot.img tmp init.d

modules:
	-make -C $(SOURCE) O=$(BUILD) CROSS_COMPILE=$(ARM_CC) modules
	-make -C $(SOURCE) O=$(BUILD) modules_install INSTALL_MOD_PATH=$(PACKAGE)/system/

install: $(KERNEL_NAME)
	adb push $(KERNEL_NAME) /storage/sdcard0/$(KERNEL_NAME)

upload: $(KERNEL_NAME)
	../../u.sh $(KERNEL_NAME)
