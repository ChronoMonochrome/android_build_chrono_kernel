# android_build_chrono_kernel
The build system that generate flashable zips with chrono kernel.

Before compilation, specify path to the kernel sources in Makefile, e.g.

`SOURCE = $(current_dir)/../android_kernel`. Adjust other paths (such as path to the compiler etc.), if needed.

Two build variants are supported:

1) make janice

Full version, genfstab and ramdisks are included.

2) make janice-light

Light version, genfstab and ramdisks aren't included. This is useful for those ROMs that use specific ramdisk, or if fstab shouldn't be overriden after kernel installation.
