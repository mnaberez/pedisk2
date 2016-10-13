'''
Make a bootable PEDISK disk image using the files from the 5.25" version.

This can be used to make a 5.25" or an 8" PEDISK disk.  The files from
the 5.25" system will boot up on 8" hardware but will not be
fully functional due to hardcoded sector constants.  These will
need to be fixed to produce a working 8" system.

Usage: makeboot.py <5|8> <imgname>
'''
import os
import sys

import imageutil

if len(sys.argv) != 3:
    sys.stderr.write(__doc__)
    sys.exit(1)
size_in_inches, imagename = sys.argv[1:]

# get an absolute path for a binary file that will be included in the image
def binfile(basename):
    dirname = os.path.join(os.path.dirname(__file__), '..', 'bin')
    return os.path.abspath(os.path.join(dirname, basename))

# make and format the image
img = imageutil.DiskImage.make_for_physical_size(size_in_inches)
fs = imageutil.Filesystem(img)
fs.format(diskname=b'BOOTDISK')

# write the special boot file into the image
data = bytearray()
with open(binfile('dos_t00_s09_7800.bin'), 'rb') as f:
    data.extend(f.read())
with open(binfile('dos_t00_s22_7a00.bin'), 'rb') as f:
    data.extend(f.read())
fs.write_file(filename=b'******', filetype=imageutil.FileTypes.LD,
    load_address=0x7800, entry_address=0x7800, data=data)

# write all the other files into the image
files = (
    (b'*****H', 0x7c00, binfile('dos_t00_s26_7c00_h_help.bin')),
    (b'*****P', 0x7c00, binfile('dos_t01_s01_7c00_p_directory.bin')),
    (b'*****U', 0x7c00, binfile('dos_t01_s05_7c00_u_disk_utility.bin')),
    (b'*****4', 0x7c00, binfile('dos_t01_s07_7c00_4_read_or_write.bin')),
    (b'*****3', 0x7c00, binfile('dos_t01_s09_7c00_3_disk_format_5inch.bin')),
    (b'*****2', 0x7c00, binfile('dos_t01_s15_7c00_2_disk_copy.bin')),
    (b'*****1', 0x7c00, binfile('dos_t01_s19_7c00_1_disk_compression.bin')),
    (b'*****D', 0x7c00, binfile('dos_t01_s25_7c00_d_dump_disk_or_mem.bin')),
    (b'*****N', 0x7c00, binfile('dos_t01_s28_7c00_n_file_rename.bin')),
    )
for name, address, filename in files:
    with open(filename, 'rb') as f:
        fs.write_file(filename=name, filetype=imageutil.FileTypes.LD,
            load_address=address, entry_address=address, data=f.read())

# save image file
with open(imagename, 'wb') as f:
    f.write(img.data)
