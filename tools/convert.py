'''
Convert a PEDISK image from one size to another.
Usage: convert.py <source.img> <5|8> <dest.img>
'''
import os
import sys

import imageutil

if len(sys.argv) != 4:
    sys.stderr.write(__doc__)
    sys.exit(1)
srcname, desttype, destname = sys.argv[1:]

# read source image
size = os.path.getsize(srcname)
if size == 256256: # 8"
    srcimg = imageutil.EightInchDiskImage()
elif size == 146944: # 5.25"
    srcimg = imageutil.FiveInchDiskImage()
else:
    sys.stderr.write("Unrecognized image: %r" % srcname)
    sys.exit(1)
with open(srcname, 'rb') as f:
    srcimg.data = f.read()
srcfs = imageutil.Filesystem(srcimg)

# make destination image
if desttype == '8': # 8"
    destimg = imageutil.EightInchDiskImage()
elif desttype == '5': # 5.25"
    destimg = imageutil.FiveInchDiskImage()
else:
    sys.stderr.write("Bad disk type: %r" % desttype)
    sys.exit(1)
destfs = imageutil.Filesystem(destimg)
destfs.format(srcfs.diskname)

# copy files from source into destination
for entry in [ e for e in srcfs.read_dir() if e.used ]:
    data = srcfs.read_file(entry.filename)
    destfs.write_file(
        filename=entry.filename,
        filetype=entry.filetype,
        load_address=entry.load_address,
        entry_address=entry.entry_address,
        data=data
        )

# write destination image
with open(destname, 'wb') as f:
    f.write(destimg.data)
