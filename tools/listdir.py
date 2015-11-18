'''
List the directory of a PEDISK disk image
Usage: list_dir.py <image.img>
'''
import os
import sys

import imageutil

if len(sys.argv) != 2:
    sys.stderr.write(__doc__)
    sys.exit(1)
imagename = sys.argv[1]

size = os.path.getsize(imagename)
if size == 256256: # 8"
    img = imageutil.EightInchDiskImage()
elif size == 146944: # 5.25"
    img = imageutil.FiveInchDiskImage()
else:
    sys.stderr.write("Unrecognized image: %r" % imagename)
    sys.exit(1)

with open(imagename, 'rb') as f:
    img.data = bytearray(f.read())

fs = imageutil.Filesystem(img)
for filename in fs.list_dir():
    print(filename.decode('utf-8'))
