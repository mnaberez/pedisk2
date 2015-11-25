'''
Format a PEDISK disk image
Usage: peformat.py <5|8> <image.img>
'''

import sys

import imageutil

def make_image(physical_size):
    if str(physical_size)[0] == '8': # 8"
        img = imageutil.EightInchDiskImage()
    elif str(physical_size)[0] == '5': # 5.25"
        img = imageutil.FiveInchDiskImage()
    else:
        raise Exception("Bad disk type: %r" % physical_size)
    return img

if __name__ == '__main__':
    def main():
        if len(sys.argv) != 3:
            sys.stderr.write(__doc__)
            sys.exit(1)
        disktype, imagename = sys.argv[1:]

        # make an image and format a filesystem on it
        img = make_image(disktype)
        fs = imageutil.Filesystem(img)
        fs.format(diskname=b'12345678')

        # write image file to disk
        with open(imagename, 'wb') as f:
            f.write(img.data)
    main()
