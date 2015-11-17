'''
Make a boot disk image using the files from the 5.25" version.

This can be used to make a 5.25" or a 8" disk.  The files from
the 5.25" system will boot up on 8" hardware but will not be
fully functional due to hardcoded sector constants.  These will
need to be fixed to produce a working 8" system.

Usage: makeboot.py <5|8> <imgname>
'''
import sys

import imageutil

if len(sys.argv) != 3:
    sys.stderr.write(__doc__)
    sys.exit(1)

disktype, imagename = sys.argv[1:]

if disktype == '8': # 8"
    img = imageutil.EightInchDiskImage()
elif disktype == '5': # 5.25"
    img = imageutil.FiveInchDiskImage()
else:
    sys.stderr.write("Bad disk type: %r" % disktype)
    sys.exit(1)

# format the image
fs = imageutil.Filesystem(img)
fs.format(diskname=b'boot')

# write the special boot file into the image
data = bytearray()
with open('../bin/dos_t00_s09_7800.bin', 'rb') as f:
    data.extend(f.read())
with open('../bin/dos_t00_s22_7a00.bin', 'rb') as f:
    data.extend(f.read())
fs.write_ld_file(b'******', 0x7800, 0x7800, data)

# write all the other files into the image
filenames = [
    '../bin/dos_t00_s26_7c00_h.bin',
    '../bin/dos_t01_s01_7c00_p.bin',
    '../bin/dos_t01_s05_7c00_u.bin',
    '../bin/dos_t01_s07_7c00_4.bin',
    '../bin/dos_t01_s09_7c00_3.bin',
    '../bin/dos_t01_s15_7c00_2.bin',
    '../bin/dos_t01_s19_7c00_1.bin',
    '../bin/dos_t01_s25_7c00_d.bin',
    '../bin/dos_t01_s28_7c00_n.bin',
]
for filename in filenames:
    parts = filename.split('_')
    load_address = int(parts[-2], 16) # 0x7800
    entry_address = load_address
    menu_key = parts[-1][0].upper() # "H" from "h.bin"

    with open(filename, 'rb') as f:
        data = f.read()
        name = bytearray([42,42,42,42,42,ord(menu_key)]) # "*****H"
        fs.write_ld_file(name, load_address, entry_address, data)

# save image file
with open(imagename, 'wb') as f:
    f.write(img.data)
