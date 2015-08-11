import sys

if len(sys.argv) != 3:
    sys.stderr.write("Usage: peformat.py <5|8> <image.img>\n")
    sys.exit(1)

disktype, imagename = sys.argv[1:]

if disktype == '8': # 8"
    tracks = 77 # numbered 0-76
    sectors = 26 # numbered 1-26
    sector_size = 128 # bytes
elif disktype == '5': # 5.25"
    tracks = 41 # numbered 0-40
    sectors = 28 # numbered 1-28
    sector_size = 128 # bytes
else:
    sys.stderr.write("Bad disk type: %r" % disktype)
    sys.exit(1)

with open(imagename, 'wb') as f:
    # create image
    f.write(chr(0xE6) * sector_size * tracks * sectors)

    # fill all directory entries
    f.seek(0)
    f.write(chr(0xFF) * sector_size * 8)

    # write directory header
    f.seek(0)
    f.write("12345678") # disk name
    f.write(chr(0x00)) # number of files
    f.write(chr(0x00)) # next open track (track 0)
    f.write(chr(0x09)) # next open sector (sector 9)
    f.write(chr(0x20) * 5) # unused bytes, always $20
