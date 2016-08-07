#!/usr/bin/python

# 
# Copyright (c) 2015, Shilin Victor <chrono.monochrome@gmail.com>
# 
# This software is licensed under the terms of the GNU General Public
# License version 2, as published by the Free Software Foundation, and
# may be copied, distributed, and modified under those terms.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# General Public License for more details.
#
# 

import sys, os

DEBUG = 1
VERBOSE_DEBUG = 0	
FILE="./%s" % sys.argv[1]
DIR = "".join(FILE.split("/")[:-1]) + "/"

GZIP_MAGIC = "\x1F\x8B\x08"
LZO_MAGIC = "\x89LZO\x00"
LZ4_LEGACY_MAGIC = '\x02\x21'

GZIP = 'gzip'
LZO = 'lzo'
LZ4 = 'lz4'
UNKNOWN = '?'

EXT = {LZO:LZO, LZ4:LZ4, GZIP:"gz"}

def debug_print(s, verbose_debug_flag = 1):
	if DEBUG and verbose_debug_flag:
		os.system('echo %s'%s)
		
def is_gziped(s):
	if s.find(GZIP_MAGIC) != -1:
		return 1
	return 0

def is_lzod(s):
	if s.count(LZO_MAGIC) == 5:
		return 1
	return 0
	
def is_lz4d(s):
	if s.count(LZ4_LEGACY_MAGIC) > 1:
		return 1
	return 0

def find_zimage_start(s):
	if is_lzod(s):
		res = s.find(LZO_MAGIC,
		      s.find(LZO_MAGIC)+1), LZO
	elif is_lz4d(s):
		res = s.find(LZ4_LEGACY_MAGIC), LZ4 
	elif is_gziped(s):
		res = s.find(GZIP_MAGIC), GZIP
	else:
		return -1, UNKNOWN
	return res


def get_custom_cmdline(hwmem_size):
	return "hwmem=%dM@256M mem=%dM@%dM" % (hwmem_size, 127 - hwmem_size, 256 + hwmem_size)

def repack_kernel(input_file):
	try:
		bootimg = open(input_file,'rb').read()
	except:
		debug_print('error occured when reading %s' % input_file)
		return -1
		
	ZIMAGE_START, FORMAT = find_zimage_start(bootimg)

	if FORMAT != LZ4:
		debug_print("sorry, only lz4 compressed zImage supported")
		exit()

	zimage_file = 'kernel.%s' % EXT[FORMAT]
	if (ZIMAGE_START >= 0): 
		debug_print('found zImage at %d'%ZIMAGE_START)
		open(zimage_file,'wb').write(bootimg[ZIMAGE_START:])
		
		if FORMAT == LZO:
			os.system("lzop -d ./%s ./kernel" % zimage_file)
		elif FORMAT == LZ4:
			os.system("lz4c -dy ./%s ./kernel" % zimage_file)
		elif FORMAT == GZIP:
			os.system("gunzip -qf %s" % zimage_file)
		else:
			debug_print('Unknown format')
			return -2
		
		kernel = open('./kernel','rb').read()
		debug_print('%sd zImage was successfully unpacked' % FORMAT)
	else:
		debug_print('zImage is not found')
		return -4

	try:
		image = open('./kernel','rb').read()
	except:
		debug_print('error occured when reading %s' % input_file)
		return -1

	image_chunk_start = image.find("samsungcodina")
	if (image_chunk_start == -1):
		debug_print('error, specific patch is not found in kernel')
		return -1

	custom_param = "samsungcodina"

	open(DIR + "kernel_mod", "wb").write(
                      image[:image_chunk_start] + 
                      custom_param + 
		      image[image_chunk_start + len(custom_param):] )

	debug_print('added cmdline param with custom hwmem size to uncompressed file kernel_mod')

	os.system("lz4c -l -c1 %skernel_mod %skernel_mod.lz4" % (DIR, DIR))

	debug_print('kernel_mod packed to kernel_mod.lz4')

	debug_print('%d - %d' % (os.stat("kernel_mod.lz4").st_size, len(bootimg[ZIMAGE_START:])))
	end_chunk = bootimg[os.stat("kernel_mod.lz4").st_size - len(bootimg[ZIMAGE_START:]) : ]

	open(DIR + "start_chunk", "wb").write(bootimg[:ZIMAGE_START])
	open(DIR + "end_chunk", "wb").write(end_chunk)
	#open(DIR + "boot_mod.img", "wb").write(
        #              bootimg[:ZIMAGE_START] + 
        #              open(DIR + "kernel_mod.lz4", "rb").read() + end_chunk )

	debug_print('start chunk: written %d bytes' % (os.stat("start_chunk").st_size))
	debug_print('end chunk: written %d bytes' % (os.stat("end_chunk").st_size))


def clean():
	for i in EXT.values():
	      if os.path.exists(DIR + "kernel.%s" % i):
		    debug_print("file kernel.%s removed" % i, VERBOSE_DEBUG)
		    os.remove(DIR + "kernel.%s" % i)
		    
	#if os.path.exists(DIR + "kernel"):
	#	    debug_print("file kernel removed", VERBOSE_DEBUG)
	#	    os.remove(DIR + "kernel")

	if os.path.exists(DIR + "kernel_mod"):
		    debug_print("file kernel_mod removed", VERBOSE_DEBUG)
		    os.remove(DIR + "kernel_mod")

	for i in EXT.values():
	      if os.path.exists(DIR + "kernel_mod.%s" % i):
		    debug_print("file kernel_mod.%s removed" % i, VERBOSE_DEBUG)
		    os.remove(DIR + "kernel_mod.%s" % i)
		    
def pre_clean():
	clean()
	
pre_clean()	
repack_kernel(FILE)
clean()
