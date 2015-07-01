current_dir = $(shell pwd)

SOURCE = ../android_kernel
BUILD = ../obj
PACKAGE = $(current_dir)

VERSION = $(shell git -C $SOURCE describe --tags --exact-match --match 'R[0-9]*')
KERNEL_NAME=chrono_kernel_$(VERSION).zip

AUTOLOAD_LIST = bfq-iosched cpufreq_interactive cpufreq_zenx cpufreq_ondemandplus logger

all: codina

codina: build package-full

codina-light: build package-light

build: $(SOURCE)
	-mkdir $(BUILD);
	make -C $(SOURCE) O=$(BUILD) ARCH=arm codina_defconfig
	make -C $(SOURCE) O=$(BUILD) ARCH=arm -k -j2

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
	adb push $(KERNEL_NAME) /external_sd/$(KERNEL_NAME)
