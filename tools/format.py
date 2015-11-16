'''
Format a PEDISK disk image
Usage: peformat.py <5|8> <image.img>
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

# format filesystem on the image
fs = imageutil.Filesystem(img)
fs.format(diskname=b'12345678')

# write image file to disk
with open(imagename, 'wb') as f:
    f.write(img.data)
