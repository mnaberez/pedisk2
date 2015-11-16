import sys

import imageutil

if len(sys.argv) != 3:
    sys.stderr.write("Usage: peformat.py <5|8> <image.img>\n")
    sys.exit(1)

disktype, imagename = sys.argv[1:]

if disktype == '8': # 8"
    img = imageutil.EightInchDiskImage()
elif disktype == '5': # 5.25"
    img = imageutil.FiveInchDiskImage()
else:
    sys.stderr.write("Bad disk type: %r" % disktype)
    sys.exit(1)

# ensure image is initialized to E5
img.home()
img.write(b'\xe5' * img.TOTAL_SIZE)

# fill all directory entries
img.home()
img.write(b'\xff' * img.SECTOR_SIZE * 8)

# write directory header
img.home()
img.write(b'12345678')
img.write(b'\x00') # number of files
img.write(b'\x00') # next open track (track 0)
img.write(b'\x09') # next open sector (sector 9)
img.write(b'\x20' * 5) # unused bytes, always 0x20

# write image file to disk
with open(imagename, 'wb') as f:
    f.write(img.data)
